
//Qt includes
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QProcessEnvironment>
#include <QDebug>
#include <QTimer>
#include <QApplication>

// CTK includes
#include "ctkAppLauncher.h"
#include "ctkAppLauncher_p.h"
#include "ctkAppLauncherVersionConfig.h"
#include "ctkSettingsHelper.h"

// STD includes
#include <iostream>
#include <cstdlib>

// --------------------------------------------------------------------------
// ctkAppLauncherInternal methods

// --------------------------------------------------------------------------
ctkAppLauncherInternal::ctkAppLauncherInternal()
{
  this->LauncherStarting = false;
  this->Application = 0;
  this->Initialized = false;
  this->DetachApplicationToLaunch = false;
  this->LauncherSplashScreenHideDelayMs = -1;
  this->LauncherNoSplashScreen = false;
  this->DefaultLauncherSplashImagePath = ":Images/ctk-splash.png";
  this->DefaultLauncherSplashScreenHideDelayMs = 800;
  this->LauncherSettingSubDirs << "." << "bin" << "lib";
  this->ValidSettingsFile = false;
  this->LongArgPrefix = "--";
  this->ShortArgPrefix = "-";

#if defined(WIN32) || defined(_WIN32)
  this->PathSep = ";";
  this->LibraryPathVariableName = "PATH";
#endif
#ifdef __APPLE__
  this->PathSep = ":";
  this->LibraryPathVariableName = "DYLD_LIBRARY_PATH";
#endif
#ifdef __linux__
  this->PathSep = ":";
  this->LibraryPathVariableName = "LD_LIBRARY_PATH";
#endif
//#if defined(sun) || defined(__sun)
//#endif
}

// --------------------------------------------------------------------------
void ctkAppLauncherInternal::reportError(const QString& msg)
{
  std::cerr << "error: " << qPrintable(msg) << std::endl;
}

// --------------------------------------------------------------------------
void ctkAppLauncherInternal::reportInfo(const QString& msg)
{
  if (this->verbose())
    {
    std::cout << "info: " << qPrintable(msg) << std::endl;
    }
}

// --------------------------------------------------------------------------
void ctkAppLauncherInternal::exit(int exitCode)
{
  if (this->Application)
    {
    this->Application->exit(exitCode);
    }
}

// --------------------------------------------------------------------------
bool ctkAppLauncherInternal::processSplashPathArgument()
{
  if (this->LauncherSplashImagePath.isEmpty())
    {
    this->LauncherSplashImagePath = this->DefaultLauncherSplashImagePath;
    }
  this->LauncherSplashImagePath = this->expandValue(this->LauncherSplashImagePath);
  this->reportInfo(QString("LauncherSplashImagePath [%1]").arg(this->LauncherSplashImagePath));

  // Make sure the splash image exists if a splashscreen is used
  if (!QFile::exists(this->LauncherSplashImagePath)
      && !this->disableSplash() )
    {
    this->reportError(
      QString("SplashImage does NOT exist [%1]").arg(this->LauncherSplashImagePath));
    return false;
    }
  return true;
}

// --------------------------------------------------------------------------
bool ctkAppLauncherInternal::processScreenHideDelayMsArgument()
{
  if (this->LauncherSplashScreenHideDelayMs == -1)
    {
    this->LauncherSplashScreenHideDelayMs = this->DefaultLauncherSplashScreenHideDelayMs;
    }
  this->reportInfo(QString("LauncherSplashScreenHideDelayMs [%1]").arg(this->LauncherSplashScreenHideDelayMs));

  return true;
}

// --------------------------------------------------------------------------
bool ctkAppLauncherInternal::processAdditionalSettingsArgument()
{
  if (!this->ParsedArgs.contains("launcher-additional-settings"))
    {
    return true;
    }
  QString additionalSettings = this->ParsedArgs.value("launcher-additional-settings").toString();
  if (!QFile::exists(additionalSettings))
    {
    this->reportError(QString("File specified using --launcher-additional-settings argument "
                              "does NOT exist ! [%1]").arg(additionalSettings));
    return false;
    }

  this->readSettings(additionalSettings, Self::AdditionalSettings);

  return true;
}

// --------------------------------------------------------------------------
bool ctkAppLauncherInternal::processApplicationToLaunchArgument()
{
  // Overwrite applicationToLaunch with the value read from the settings file
  this->ApplicationToLaunch = this->ParsedArgs.value("launch").toString();

  if (!this->ExtraApplicationToLaunch.isEmpty())
    {
    this->ApplicationToLaunch = this->ExtraApplicationToLaunch;
    }

  if (this->ApplicationToLaunch.isEmpty())
    {
    this->ApplicationToLaunch = this->DefaultApplicationToLaunch;
    }

  this->ApplicationToLaunch = this->expandValue(this->ApplicationToLaunch);

  if (!this->ApplicationToLaunch.isEmpty())
    {
    QFileInfo applicationToLaunchInfo(this->ApplicationToLaunch);
    if (applicationToLaunchInfo.isRelative())
      {
      QString path = applicationToLaunchInfo.path() + "/" + applicationToLaunchInfo.baseName();
      QString extension = applicationToLaunchInfo.completeSuffix();
#ifdef Q_OS_WIN32
      if (extension.isEmpty())
        {
        extension = "exe";
        }
#endif
      QString resolvedApplicationToLaunch = this->searchPaths(path, QStringList() << extension);
      if (!resolvedApplicationToLaunch.isEmpty())
        {
        this->ApplicationToLaunch = resolvedApplicationToLaunch;
        }
      }
    }

  this->reportInfo(QString("ApplicationToLaunch [%1]").arg(this->ApplicationToLaunch));

  // Make sure the program to launch exists
  if (!QFile::exists(this->ApplicationToLaunch))
    {
    this->reportError(
      QString("Application does NOT exists [%1]").arg(this->ApplicationToLaunch));

    if (!this->ParsedArgs.contains("launch") && !this->ValidSettingsFile)
      {
      this->reportError("--launch argument has NOT been specified");
      }
    return false;
    }

  // ... and is executable
  if (!(QFile::permissions(this->ApplicationToLaunch) & QFile::ExeUser))
    {
    this->reportError(
      QString("Application is NOT executable [%1]").arg(this->ApplicationToLaunch));
    return false;
    }

  if (!this->ExtraApplicationToLaunchArguments.isEmpty())
    {
    this->ApplicationToLaunchArguments =
        this->ExtraApplicationToLaunchArguments.split(" ", QString::SkipEmptyParts);
    }

  // Set ApplicationToLaunchArguments with the value read from the settings file
  if (this->ApplicationToLaunchArguments.empty())
    {
    this->ApplicationToLaunchArguments =
        this->DefaultApplicationToLaunchArguments.split(" ", QString::SkipEmptyParts);
    }

  this->reportInfo(QString("ApplicationToLaunchArguments [%1]").
                   arg(this->ApplicationToLaunchArguments.join(" ")));

  return true;
}

// --------------------------------------------------------------------------
bool ctkAppLauncherInternal::processExtraApplicationToLaunchArgument(const QStringList& unparsedArgs)
{
  foreach(const QString& extraAppLongArgument, this->ExtraApplicationToLaunchList.keys())
    {
    ctkAppLauncherInternal::ExtraApplicationToLaunchProperty extraAppToLaunchProperty =
        this->ExtraApplicationToLaunchList[extraAppLongArgument];
    QString extraAppShortArgument = extraAppToLaunchProperty.value("shortArgument");
    bool hasShortArgument = false;
    if (!extraAppShortArgument.isEmpty())
      {
      hasShortArgument = unparsedArgs.contains(this->Parser.shortPrefix() + extraAppShortArgument);
      }
    if (unparsedArgs.contains(this->Parser.longPrefix() + extraAppLongArgument) || hasShortArgument)
      {
      this->ExtraApplicationToLaunchLongArgument = extraAppLongArgument;
      this->ExtraApplicationToLaunchShortArgument = extraAppToLaunchProperty.value("shortArgument");
      this->ExtraApplicationToLaunch = extraAppToLaunchProperty.value("path");
      this->ExtraApplicationToLaunchArguments = extraAppToLaunchProperty.value("arguments");
      break;
      }
    }
  return true;
}

// --------------------------------------------------------------------------
QString ctkAppLauncherInternal::invalidSettingsMessage() const
{
  QString msg = QString("Launcher setting file [%1LauncherSettings.ini] does NOT exist in "
                        "any of these directories:\n").arg(this->LauncherName);
  foreach(const QString& subdir, this->LauncherSettingSubDirs)
    {
    msg.append(QString("%1/%2\n").arg(this->LauncherDir).arg(subdir));
    }
  return msg;
}

// --------------------------------------------------------------------------
bool ctkAppLauncherInternal::verbose() const
{
  return this->ParsedArgs.value("launcher-verbose").toBool();
}

// --------------------------------------------------------------------------
QString ctkAppLauncherInternal::splashImagePath()const
{
  if (!this->Initialized)
    {
    return this->DefaultLauncherSplashImagePath;
    }

  return this->LauncherSplashImagePath;
}

// --------------------------------------------------------------------------
bool ctkAppLauncherInternal::disableSplash() const
{
  bool hasNoSplashArgument = false;
  foreach(const QString& arg, this->LauncherAdditionalNoSplashArguments)
    {

    if (this->Parser.unparsedArguments().contains(arg) ||
        this->ParsedArgs.contains(this->trimArgumentPrefix(arg))
        )
      {
      hasNoSplashArgument = true;
      break;
      }
    }
  if (this->ParsedArgs.value("launcher-no-splash").toBool()
      || hasNoSplashArgument
      || !this->ExtraApplicationToLaunch.isEmpty()
      || this->LauncherNoSplashScreen)
    {
    return true;
    }
  return false;
}

// --------------------------------------------------------------------------
QString ctkAppLauncherInternal::searchPaths(const QString& executableName, const QStringList& extensions)
{
  QProcessEnvironment environment = QProcessEnvironment::systemEnvironment();
  QStringList paths = environment.value("PATH").split(this->PathSep);
  paths = this->ListOfPaths + paths;
  foreach(const QString& path, paths)
    {
    QString expandedPath = this->expandValue(path);
    foreach(const QString& extension, extensions)
      {
      QString executableNameWithExt = executableName;
      if (!extension.isEmpty())
        {
        executableNameWithExt.append("." + extension);
        }
      QDir pathAsDir(expandedPath);
      QString executablePath = pathAsDir.filePath(executableNameWithExt);
      this->reportInfo(QString("Checking if [%1] exists in [%2]").arg(executableNameWithExt).arg(expandedPath));
      if (QFile::exists(executablePath))
        {
        return executablePath;
        }
      }
    }
  return QString();
}

// --------------------------------------------------------------------------
QString ctkAppLauncherInternal::trimArgumentPrefix(const QString& argument) const
{
  QString trimmedArgument = argument;
  if (trimmedArgument.startsWith(this->LongArgPrefix))
    {
    trimmedArgument.remove(0, this->LongArgPrefix.length());
    }
  else if (trimmedArgument.startsWith(this->ShortArgPrefix))
    {
    trimmedArgument.remove(0, this->ShortArgPrefix.length());
    }
  return trimmedArgument;
}

// --------------------------------------------------------------------------
bool ctkAppLauncherInternal::extractLauncherNameAndDir(const QString& applicationFilePath)
{
  QFileInfo fileInfo(applicationFilePath);

  // Follow symlink if it applies
  if (fileInfo.isSymLink())
    {
    // symLinkTarget() handles links pointing to symlinks.
    fileInfo = QFileInfo(fileInfo.symLinkTarget());
    }

  // Make sure the obtained target exists and is a "file"
  if (!fileInfo.exists() && !fileInfo.isFile())
    {
    this->reportError("Failed to obtain launcher executable name !");
    return false;
    }

  // Obtain executable name
  this->LauncherName = fileInfo.baseName();

  // Obtain executable dir
  this->LauncherDir = fileInfo.absolutePath();

  return true;
}

// --------------------------------------------------------------------------
QString ctkAppLauncherInternal::expandValue(const QString& value)
{
  QHash<QString, QString> keyValueMap;
  keyValueMap["<APPLAUNCHER_DIR>"] = this->LauncherDir;
  keyValueMap["<APPLAUNCHER_NAME>"] = this->LauncherName;
  keyValueMap["<PATHSEP>"] = this->PathSep;

  QString updatedValue = value;
  foreach(const QString& key, keyValueMap.keys())
    {
    updatedValue.replace(key, keyValueMap.value(key), Qt::CaseInsensitive);
    }
  return updatedValue;
}

// --------------------------------------------------------------------------
bool ctkAppLauncherInternal::readSettings(const QString& fileName, int settingsType)
{
  if (!this->Initialized)
    {
    return false;
    }

  QString settingsTypeDesc;
  if(settingsType == Self::AdditionalSettings)
    {
    settingsTypeDesc = QLatin1String(" additional");
    }

  // Check if settings file exists
  if (!QFile::exists(fileName))
    {
    return false;
    }

  if (! (QFile::permissions(fileName) & QFile::ReadOwner) )
    {
    this->reportError(
      QString("Failed to read%1 launcher setting file [%2]").arg(settingsTypeDesc).arg(fileName));
    return false;
    }

  // Open settings file ...
  QSettings settings(fileName, QSettings::IniFormat);
  if (settings.status() != QSettings::NoError)
    {
    this->reportError(
      QString("Failed to open%1 setting file [%2]").arg(settingsTypeDesc).arg(fileName));
    return false;
    }

  // Read default launcher image path
  QString splashImagePath = settings.value("launcherSplashImagePath", ":Images/ctk-splash.png").toString();
  if (!splashImagePath.isEmpty())
    {
    this->DefaultLauncherSplashImagePath = splashImagePath;
    }

  int splashScreenHideDelayMs = settings.value("launcherSplashScreenHideDelayMs", 0).toInt();
  if (splashScreenHideDelayMs != 0)
    {
    this->DefaultLauncherSplashScreenHideDelayMs = splashScreenHideDelayMs;
    }

  bool noSplashScreen = settings.value("launcherNoSplashScreen", false).toBool();
  this->LauncherNoSplashScreen = noSplashScreen;

  // Read default application to launch
  QHash<QString, QString> applicationGroup = ctk::readKeyValuePairs(settings, "Application");
  if (applicationGroup.contains("path"))
    {
    this->DefaultApplicationToLaunch = applicationGroup["path"];
    }
  if (applicationGroup.contains("arguments"))
    {
    this->DefaultApplicationToLaunchArguments = applicationGroup["arguments"];
    }

  // Read additional launcher arguments
  QString helpShortArgument = settings.value("additionalLauncherHelpShortArgument").toString();
  if (!helpShortArgument.isEmpty())
    {
    this->LauncherAdditionalHelpShortArgument = helpShortArgument;
    }
  QString helpLongArgument = settings.value("additionalLauncherHelpLongArgument").toString();
  if (!helpLongArgument.isEmpty())
    {
    this->LauncherAdditionalHelpLongArgument = helpLongArgument;
    }
  this->LauncherAdditionalNoSplashArguments.append(
        settings.value("additionalLauncherNoSplashArguments").toStringList());

  // Read list of 'extra application to launch'
  settings.beginGroup("ExtraApplicationToLaunch");
  QStringList extraApplicationToLaunchLongArguments = settings.childGroups();
  foreach(const QString& extraApplicationLongArgument, extraApplicationToLaunchLongArguments)
    {
    this->ExtraApplicationToLaunchList[extraApplicationLongArgument] =
        ctk::readKeyValuePairs(settings, extraApplicationLongArgument);
    }
  settings.endGroup();

  // Read PATHs
  {
    QStringListIterator it(ctk::readArrayValues(settings, "Paths", "path"));
    it.toBack() ;
    while(it.hasPrevious())
      {
      this->ListOfPaths.prepend(it.previous());
      }
  }

  // Read LibraryPaths
  {
    QStringListIterator it(ctk::readArrayValues(settings, "LibraryPaths", "path"));
    it.toBack() ;
    while(it.hasPrevious())
      {
      this->ListOfLibraryPaths.prepend(it.previous());
      }
  }

  // Read additional environment variables
  QHash<QString, QString> mapOfEnvVars = ctk::readKeyValuePairs(settings, "EnvironmentVariables");
  foreach(const QString& envVarName, mapOfEnvVars.keys())
    {
    QString envVarValue = mapOfEnvVars.value(envVarName);
    envVarValue.replace(QString("<env:%1>").arg(envVarName), this->MapOfEnvVars.value(envVarName));
    this->MapOfEnvVars.insert(envVarName, envVarValue);
    }

  return true;
}

// --------------------------------------------------------------------------
void ctkAppLauncherInternal::buildEnvironment(QProcessEnvironment &env)
{
  // LD_LIBRARY_PATH (linux), DYLD_LIBRARY_PATH (mac), PATH (win) ...
  QString libPathVarName = this->LibraryPathVariableName;

  this->reportInfo(QString("<APPLAUNCHER_DIR> -> [%1]").arg(this->LauncherDir));


  // Set library paths
  {
    QStringListIterator it(this->ListOfLibraryPaths);
    it.toBack() ;
    while(it.hasPrevious())
      {
      QString path = it.previous();
      this->reportInfo(QString("Setting library path [%1]").arg(path));
      env.insert(libPathVarName, this->expandValue(path) + this->PathSep + env.value(libPathVarName));
      }
  }

  // Update Path - First path of the list will be the first on the PATH
  {
    QStringListIterator it(this->ListOfPaths);
    it.toBack() ;
    while(it.hasPrevious())
      {
      QString path = it.previous();
      this->reportInfo(QString("Setting path [%1]").arg(path));
      env.insert("PATH", this->expandValue(path) + this->PathSep + env.value("PATH"));
      }
  }

  // Set additional environment variables
  foreach(const QString& key, this->MapOfEnvVars.keys())
    {
    QString value = this->MapOfEnvVars[key];
    this->reportInfo(QString("Setting env. variable [%1]:%2").arg(key).arg(value));
    env.insert(key, this->expandValue(value));
    }
}

// --------------------------------------------------------------------------
void ctkAppLauncherInternal::runProcess()
{
  this->Process.setProcessChannelMode(QProcess::ForwardedChannels);

  QProcessEnvironment env = QProcessEnvironment::systemEnvironment();

  this->buildEnvironment(env);

  this->Process.setProcessEnvironment(env);

  this->reportInfo(QString("Starting [%1]").arg(this->ApplicationToLaunch));
  if (this->verbose())
    {
    foreach(const QString& argument, this->ApplicationToLaunchArguments)
      {
      this->reportInfo(QString("argument [%1]").arg(argument));
      }
    }

  connect(&this->Process, SIGNAL(finished(int, QProcess::ExitStatus)),
          this, SLOT(applicationFinished(int, QProcess::ExitStatus)));
  connect(&this->Process, SIGNAL(started()), this, SLOT(applicationStarted()));

  if (!this->DetachApplicationToLaunch)
    {
    this->Process.start(this->ApplicationToLaunch, this->ApplicationToLaunchArguments);
    int timeoutInMs = this->ParsedArgs.value("launcher-timeout").toInt() * 1000;
    this->reportInfo(QString("launcher-timeout (ms) [%1]").arg(timeoutInMs));
    if (timeoutInMs > 0)
      {
      QTimer::singleShot(timeoutInMs, this, SLOT(terminateProcess()));
      }
    }
  else
    {
    this->Process.startDetached(
      this->ApplicationToLaunch, this->ApplicationToLaunchArguments);
    this->exit(EXIT_SUCCESS);
    }
}

// --------------------------------------------------------------------------
void ctkAppLauncherInternal::terminateProcess()
{
  this->Process.terminate();
}

// --------------------------------------------------------------------------
void ctkAppLauncherInternal::applicationFinished(int exitCode, QProcess::ExitStatus  exitStatus)
{
  if (exitStatus == QProcess::NormalExit)
    {
    this->exit(exitCode);
    }
  else if (exitStatus == QProcess::CrashExit)
    {
    this->reportError(
      QString("[%1] exit abnormally - Report the problem.").
        arg(this->ApplicationToLaunch));
    this->exit(EXIT_FAILURE);
    }
}

// --------------------------------------------------------------------------
void ctkAppLauncherInternal::applicationStarted()
{
  this->reportInfo(
    QString("DisableSplash [%1]").arg(this->disableSplash()));
  if(!this->disableSplash())
    {
    this->SplashPixmap.reset(
      new QPixmap(this->splashImagePath()));
    this->SplashScreen = QSharedPointer<QSplashScreen>(
      new QSplashScreen(*this->SplashPixmap.data(), Qt::WindowStaysOnTopHint));
    this->SplashScreen->show();
    QTimer::singleShot(this->LauncherSplashScreenHideDelayMs,
                       this->SplashScreen.data(), SLOT(hide()));
    }
}

// --------------------------------------------------------------------------
// ctkAppLauncher methods

// --------------------------------------------------------------------------
ctkAppLauncher::ctkAppLauncher(const QCoreApplication& application, QObject* parentObject)
  : Superclass(parentObject)
{
  this->Internal = new ctkAppLauncherInternal();
  this->setApplication(application);
}

// --------------------------------------------------------------------------
ctkAppLauncher::ctkAppLauncher(QObject* parentObject)
  : Superclass(parentObject)
{
  this->Internal = new ctkAppLauncherInternal();
}

// --------------------------------------------------------------------------
ctkAppLauncher::~ctkAppLauncher()
{
  delete this->Internal;
}

// --------------------------------------------------------------------------
void ctkAppLauncher::displayEnvironment(std::ostream &output)
{
  if (this->Internal->LauncherName.isEmpty())
    {
    return;
    }
  QProcessEnvironment env;
  this->Internal->buildEnvironment(env);
  QStringList envAsList = env.toStringList();
  envAsList.sort();
  foreach (const QString& envArg, envAsList)
    {
    output << qPrintable(envArg) << std::endl;
    }
}

// --------------------------------------------------------------------------
void ctkAppLauncher::displayHelp(std::ostream &output)
{
  if (this->Internal->LauncherName.isEmpty())
    {
    return;
    }

  // Add "extra application to launch" arguments so that helpText() consider them.
  foreach(const QString& extraAppLongArgument, this->Internal->ExtraApplicationToLaunchList.keys())
    {
    ctkAppLauncherInternal::ExtraApplicationToLaunchProperty extraAppToLaunchProperty =
        this->Internal->ExtraApplicationToLaunchList[extraAppLongArgument];
    QString extraAppShortArgument = extraAppToLaunchProperty.value("shortArgument");
    this->Internal->Parser.addArgument(extraAppLongArgument, extraAppShortArgument, QVariant::Bool,
                                       extraAppToLaunchProperty.value("help"));
    }

  output << "Usage\n";
  output << "  " << qPrintable(this->Internal->LauncherName) << " [options]\n\n";
  output << "Options\n";
  output << qPrintable(this->Internal->Parser.helpText());
}

// --------------------------------------------------------------------------
void ctkAppLauncher::displayVersion(std::ostream &output)
{
  if (this->Internal->LauncherName.isEmpty())
    {
    return;
    }
  output << qPrintable(this->Internal->LauncherName) << " launcher version "CTKAppLauncher_VERSION << "\n";
}

// --------------------------------------------------------------------------
bool ctkAppLauncher::initialize(QString launcherFilePath)
{
  if (this->Internal->Initialized)
    {
    return true;
    }

  if (launcherFilePath.isEmpty() && this->Internal->Application)
    {
    launcherFilePath = this->Internal->Application->applicationFilePath();
    }
  if (!this->Internal->extractLauncherNameAndDir(launcherFilePath))
    {
    return false;
    }

  ctkCommandLineParser & parser = this->Internal->Parser;
  parser.setArgumentPrefix(this->Internal->LongArgPrefix, this->Internal->ShortArgPrefix);

  parser.addArgument("launcher-help","", QVariant::Bool, "Display help");
  parser.addArgument("launcher-version","", QVariant::Bool, "Show launcher version information");
  parser.addArgument("launcher-verbose", "", QVariant::Bool, "Verbose mode");
  parser.addArgument("launch", "", QVariant::String, "Specify the application to launch",
                     QVariant(this->Internal->DefaultApplicationToLaunch), true /*ignoreRest*/);
  parser.addArgument("launcher-detach", "", QVariant::Bool,
                     "Launcher will NOT wait for the application to finish");
  parser.addArgument("launcher-no-splash", "", QVariant::Bool,"Hide launcher splash");
  parser.addArgument("launcher-timeout", "", QVariant::Int,
                     "Specify the time in second before the launcher kills the application. "
                     "-1 means no timeout", QVariant(-1));
  parser.setExactMatchRegularExpression("launcher-timeout",
                                        "(-1)|([0-9]+)", "-1 or a positive integer is expected.");
  parser.addArgument("launcher-dump-environment", "", QVariant::Bool,
                     "Launcher will print environment variables to be set, then exit");
  parser.addArgument("launcher-additional-settings", "", QVariant::String,
                     "Additional settings file to consider");
  parser.addArgument("launcher-generate-template", "", QVariant::Bool,
                     "Generate an example of setting file");

  // TODO Should SplashImagePath and SplashScreenHideDelayMs be added as parameters ?

  this->Internal->Initialized = true;
  return true;
}

// --------------------------------------------------------------------------
void ctkAppLauncher::setApplication(const QCoreApplication& app)
{
  this->Internal->Application = app.instance();
  if (this->Internal->Application)
    {
    this->setArguments(this->Internal->Application->arguments());
    }
}

// --------------------------------------------------------------------------
QStringList ctkAppLauncher::arguments()const
{
  return this->Internal->Arguments;
}

// --------------------------------------------------------------------------
void ctkAppLauncher::setArguments(const QStringList& args)
{
  this->Internal->Arguments = args;
}

// --------------------------------------------------------------------------
int ctkAppLauncher::processArguments()
{
  if (!this->Internal->Initialized)
    {
    return Self::ExitWithError;
    }

  bool ok = false;
  this->Internal->ParsedArgs =
      this->Internal->Parser.parseArguments(this->Internal->Arguments, &ok);
  if (!ok)
    {
    std::cerr << "Error\n  "
              << qPrintable(this->Internal->Parser.errorString()) << "\n" << std::endl;
    return Self::ExitWithError;
    }

  if (this->Internal->LauncherStarting)
    {
    this->Internal->reportInfo(
        QString("LauncherDir [%1]").arg(this->Internal->LauncherDir));

    this->Internal->reportInfo(
        QString("LauncherName [%1]").arg(this->Internal->LauncherName));

    this->Internal->reportInfo(
        QString("SettingsFileName [%1]").arg(this->findSettingFile()));
    }

  if (this->Internal->ParsedArgs.value("launcher-help").toBool())
    {
    this->displayHelp();
    return Self::ExitWithSuccess;
    }

  if (this->Internal->ParsedArgs.value("launcher-version").toBool())
    {
    this->displayVersion();
    return Self::ExitWithSuccess;
    }

  if (!this->Internal->processAdditionalSettingsArgument())
    {
    return Self::ExitWithError;
    }

  if (this->Internal->ParsedArgs.value("launcher-dump-environment").toBool())
    {
      this->displayEnvironment();
      return Self::ExitWithSuccess;
    }

  this->Internal->DetachApplicationToLaunch =
      this->Internal->ParsedArgs.value("launcher-detach").toBool();
  if (this->Internal->LauncherStarting)
    {
    this->Internal->reportInfo(
        QString("DetachApplicationToLaunch [%1]").arg(this->Internal->DetachApplicationToLaunch));
    }

  QStringList unparsedArgs = this->Internal->Parser.unparsedArguments();
  if (unparsedArgs.contains(this->Internal->LauncherAdditionalHelpShortArgument) ||
      unparsedArgs.contains(this->Internal->LauncherAdditionalHelpLongArgument))
    {
    if (this->Internal->LauncherStarting)
      {
      this->displayHelp();
      }
    }

  if (this->Internal->ParsedArgs.value("launcher-generate-template").toBool())
    {
    this->generateTemplate();
    return Self::ExitWithSuccess;
    }

  if (!this->Internal->processSplashPathArgument())
    {
    return Self::ExitWithError;
    }

  if (!this->Internal->processScreenHideDelayMsArgument())
    {
    return Self::ExitWithError;
    }

  if (!this->Internal->processExtraApplicationToLaunchArgument(unparsedArgs))
    {
    return Self::ExitWithError;
    }

  if (!this->Internal->processApplicationToLaunchArgument())
    {
    return Self::ExitWithError;
    }

  return Self::Continue;
}

// --------------------------------------------------------------------------
QString ctkAppLauncher::findSettingFile()const
{
  if (!this->Internal->Initialized)
    {
    return QString();
    }

  foreach(const QString& subdir, this->Internal->LauncherSettingSubDirs)
    {
    QString fileName = QString("%1/%2/%3LauncherSettings.ini").
                       arg(this->Internal->LauncherDir).arg(subdir).
                       arg(this->Internal->LauncherName);
    if (QFile::exists(fileName))
      {
      return fileName;
      }
    }
  return QString();
}

// --------------------------------------------------------------------------
bool ctkAppLauncher::readSettings(const QString& fileName)
{
  return this->Internal->readSettings(fileName, ctkAppLauncherInternal::RegularSettings);
}

// --------------------------------------------------------------------------
bool ctkAppLauncher::writeSettings(const QString& outputFilePath)
{
  if (!this->Internal->Initialized)
    {
    return false;
    }

  // Create or open settings file ...
  QSettings settings(outputFilePath, QSettings::IniFormat);
  if (settings.status() != QSettings::NoError)
    {
    this->Internal->reportError(
      QString("Failed to open setting file [%1]").arg(outputFilePath));
    return false;
    }

  // Clear settings
  settings.clear();

  settings.setValue("launcherSplashImagePath", this->Internal->LauncherSplashImagePath);
  settings.setValue("launcherSplashScreenHideDelayMs", this->Internal->LauncherSplashScreenHideDelayMs);
  settings.setValue("launcherNoSplashScreen", this->Internal->LauncherNoSplashScreen);
  settings.setValue("additionalLauncherHelpShortArgument", this->Internal->LauncherAdditionalHelpShortArgument);
  settings.setValue("additionalLauncherHelpLongArgument", this->Internal->LauncherAdditionalHelpLongArgument);
  settings.setValue("additionalLauncherNoSplashArguments", this->Internal->LauncherAdditionalNoSplashArguments);

  QHash<QString, QString> applicationGroup;
  applicationGroup["path"] = this->Internal->ApplicationToLaunch;
  applicationGroup["arguments"] = this->Internal->ApplicationToLaunchArguments.join(" ");
  ctk::writeKeyValuePairs(settings, applicationGroup, "Application");

  settings.beginGroup("ExtraApplicationToLaunch");
  foreach(const QString& extraAppLongArgument, this->Internal->ExtraApplicationToLaunchList.keys())
    {
    ctkAppLauncherInternal::ExtraApplicationToLaunchProperty extraAppToLaunchProperty =
        this->Internal->ExtraApplicationToLaunchList.value(extraAppLongArgument);
    ctk::writeKeyValuePairs(settings, extraAppToLaunchProperty, extraAppLongArgument);
    }
  settings.endGroup();

  ctk::writeArrayValues(settings, this->Internal->ListOfPaths, "Paths", "path");
  ctk::writeArrayValues(settings, this->Internal->ListOfLibraryPaths, "LibraryPaths", "path");
  ctk::writeKeyValuePairs(settings, this->Internal->MapOfEnvVars, "EnvironmentVariables");

  return true;
}

// --------------------------------------------------------------------------
bool ctkAppLauncher::readAdditonalSettings(const QString& fileName)
{
  return this->Internal->readSettings(fileName, ctkAppLauncherInternal::AdditionalSettings);
}

// --------------------------------------------------------------------------
const QStringList& ctkAppLauncher::libraryPaths()const
{
  return this->Internal->ListOfPaths;
}

// --------------------------------------------------------------------------
void ctkAppLauncher::setLibraryPaths(const QStringList& listOfLibraryPaths)
{
  this->Internal->ListOfLibraryPaths = listOfLibraryPaths;
}

// --------------------------------------------------------------------------
const QStringList& ctkAppLauncher::paths()const
{
  return this->Internal->ListOfPaths;
}

// --------------------------------------------------------------------------
void ctkAppLauncher::setPaths(const QStringList& listOfPaths)
{
  this->Internal->ListOfPaths = listOfPaths;
}

// --------------------------------------------------------------------------
QString ctkAppLauncher::applicationToLaunch()const
{
  return this->Internal->ApplicationToLaunch;
}

// --------------------------------------------------------------------------
QString ctkAppLauncher::splashImagePath()const
{
  return this->Internal->splashImagePath();
}

// --------------------------------------------------------------------------
int ctkAppLauncher::splashScreenHideDelayMs()const
{
  if (!this->Internal->Initialized)
    {
    return this->Internal->DefaultLauncherSplashScreenHideDelayMs;
    }

  return this->Internal->LauncherSplashScreenHideDelayMs;
}

// --------------------------------------------------------------------------
bool ctkAppLauncher::disableSplash() const
{
  return this->Internal->disableSplash();
}

// --------------------------------------------------------------------------
bool ctkAppLauncher::verbose()const
{
  return this->Internal->verbose();
}

// --------------------------------------------------------------------------
void ctkAppLauncher::startApplication()
{
  if (!this->Internal->Initialized)
    {
    return;
    }
  QTimer::singleShot(0, this->Internal, SLOT(runProcess()));
}

// --------------------------------------------------------------------------
void ctkAppLauncher::generateTemplate()
{
  this->Internal->ListOfPaths.clear();
  this->Internal->ListOfPaths << "/home/john/app1"
                              << "/home/john/app2";

  this->Internal->ListOfLibraryPaths.clear();
  this->Internal->ListOfLibraryPaths << "/home/john/lib1"
                                     << "/home/john/lib2";

  this->Internal->MapOfEnvVars.clear();
  this->Internal->MapOfEnvVars["SOMETHING_NICE"] = "Chocolate";
  this->Internal->MapOfEnvVars["SOMETHING_AWESOME"] = "Rock climbing !";

  this->Internal->LauncherAdditionalHelpShortArgument = "h";
  this->Internal->LauncherAdditionalHelpLongArgument = "help";
  this->Internal->LauncherAdditionalNoSplashArguments.clear();
  this->Internal->LauncherAdditionalNoSplashArguments << "ns" << "no-splash";

  this->Internal->ExtraApplicationToLaunchList.clear();
  ctkAppLauncherInternal::ExtraApplicationToLaunchProperty extraAppToLaunchProperty;
  extraAppToLaunchProperty["shortArgument"] = "t";
  extraAppToLaunchProperty["help"] = "What time is it ?";
  extraAppToLaunchProperty["path"] = "/usr/bin/xclock";
  extraAppToLaunchProperty["arguments"] = "-digital";
  this->Internal->ExtraApplicationToLaunchList.insert("time", extraAppToLaunchProperty);

  this->Internal->ApplicationToLaunch = "/usr/bin/xcalc";
  this->Internal->LauncherSplashImagePath = "/home/john/images/splash.png";
  this->Internal->ApplicationToLaunchArguments.clear();
  this->Internal->ApplicationToLaunchArguments << "-rpn";

  QString outputFile = QString("%1/%2LauncherSettings.ini.template").
    arg(this->Internal->LauncherDir).
    arg(this->Internal->LauncherName);

  this->writeSettings(outputFile);
}

// --------------------------------------------------------------------------
bool ctkAppLauncher::configure()
{
  if (!this->initialize())
    {
    this->Internal->exit(EXIT_FAILURE);
    return false;
    }

  QString settingFileName = this->findSettingFile();

  this->Internal->ValidSettingsFile = this->readSettings(settingFileName);

  int status = this->processArguments();
  if (status == ctkAppLauncher::ExitWithError)
    {
    if (!this->Internal->ValidSettingsFile)
      {
      this->Internal->reportError(this->Internal->invalidSettingsMessage());
      }
    this->displayHelp(std::cerr);
    this->Internal->exit(EXIT_FAILURE);
    return false;
    }
  else if (status == ctkAppLauncher::ExitWithSuccess)
    {
    this->Internal->exit(EXIT_SUCCESS);
    return false;
    }

  // Append 'unparsed arguments' to list of arguments that will be used to start the application.
  // If it applies, extra 'application to launch' short and long arguments should be
  // removed from that list.
  QStringList unparsedArguments = this->Internal->Parser.unparsedArguments();
  if (!this->Internal->ExtraApplicationToLaunchShortArgument.isEmpty())
    {
    unparsedArguments.removeAll(this->Internal->Parser.shortPrefix() + this->Internal->ExtraApplicationToLaunchShortArgument);
    }
  if (!this->Internal->ExtraApplicationToLaunchLongArgument.isEmpty())
    {
    unparsedArguments.removeAll(this->Internal->Parser.longPrefix() + this->Internal->ExtraApplicationToLaunchLongArgument);
    }

  this->Internal->ApplicationToLaunchArguments.append(unparsedArguments);
  return true;
}

// --------------------------------------------------------------------------
void ctkAppLauncher::startLauncher()
{
  this->Internal->LauncherStarting = true;
  bool res = this->configure();
  if (!res)
    {
    return;
    }
  this->startApplication();
}
