
// Qt includes
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QProcessEnvironment>
#include <QRegExp>
#include <QTemporaryFile>
#include <QTimer>

// CTK includes
#include "ctkAppLauncher.h"
#include "ctkAppLauncher_p.h"
#include "ctkAppLauncherEnvironment.h"
#include "ctkAppLauncherSettings.h"
#include "ctkAppLauncherSettings_p.h"
#include "ctkAppLauncherVersionConfig.h"
#include "ctkSettingsHelper.h"

// STD includes
#include <iostream>
#include <cstdlib>

// --------------------------------------------------------------------------
// ctkAppLauncherPrivate methods

// --------------------------------------------------------------------------
ctkAppLauncherPrivate::ctkAppLauncherPrivate(ctkAppLauncher& object) : ctkAppLauncherSettingsPrivate(object)
{
  QSettings::setDefaultFormat(QSettings::IniFormat);
  this->LauncherStarting = false;
  this->Application = 0;
  this->Initialized = false;
  this->DetachApplicationToLaunch = false;
  this->LauncherSplashScreenHideDelayMs = -1;
  this->LauncherNoSplashScreen = false;
  this->LoadEnvironment = -1;
  this->DefaultLauncherSplashImagePath = ":Images/ctk-splash.png";
  this->DefaultLauncherSplashScreenHideDelayMs = 800;
  this->LauncherSettingSubDirs << "." << "bin" << "lib";

  this->ValidSettingsFile = false;
  this->LongArgPrefix = "--";
  this->ShortArgPrefix = "-";
}

// --------------------------------------------------------------------------
void ctkAppLauncherPrivate::reportError(const QString& msg) const
{
  std::cerr << "error: " << qPrintable(msg) << std::endl;
}

// --------------------------------------------------------------------------
void ctkAppLauncherPrivate::reportInfo(const QString& msg, bool force) const
{
  if (this->verbose() || force)
    {
    std::cout << "info: " << qPrintable(msg) << std::endl;
    }
}

// --------------------------------------------------------------------------
void ctkAppLauncherPrivate::exit(int exitCode)
{
  if (this->Application)
    {
    this->Application->exit(exitCode);
    }
}

// --------------------------------------------------------------------------
bool ctkAppLauncherPrivate::processSplashPathArgument()
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
bool ctkAppLauncherPrivate::processScreenHideDelayMsArgument()
{
  if (this->LauncherSplashScreenHideDelayMs == -1)
    {
    this->LauncherSplashScreenHideDelayMs = this->DefaultLauncherSplashScreenHideDelayMs;
    }
  this->reportInfo(QString("LauncherSplashScreenHideDelayMs [%1]").arg(this->LauncherSplashScreenHideDelayMs));

  return true;
}

// --------------------------------------------------------------------------
bool ctkAppLauncherPrivate::processAdditionalSettings()
{
  this->reportInfo(QString("AdditionalSettingsFilePath [%1]").arg(this->AdditionalSettingsFilePath));
  if (this->AdditionalSettingsFilePath.isEmpty())
    {
    return true;
    }
  if (!QFile::exists(this->AdditionalSettingsFilePath))
    {
    this->reportError(QString("File specified using 'additionalSettingsFilePath' settings "
                              "does NOT exist ! [%1]").arg(this->AdditionalSettingsFilePath));
    return false;
    }

  return this->readSettings(this->AdditionalSettingsFilePath, Self::AdditionalSettings);
}

// --------------------------------------------------------------------------
bool ctkAppLauncherPrivate::processAdditionalSettingsArgument()
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

  return this->readSettings(additionalSettings, Self::AdditionalSettings);
}

// --------------------------------------------------------------------------
bool ctkAppLauncherPrivate::processUserAdditionalSettings()
{
  if (this->ParsedArgs.value("launcher-ignore-user-additional-settings").toBool())
    {
    return true;
    }

  QString additionalSettings = this->findUserAdditionalSettings();
  if(additionalSettings.isEmpty())
    {
    return true;
    }
  return this->readSettings(additionalSettings, Self::UserAdditionalSettings);
}

// --------------------------------------------------------------------------
bool ctkAppLauncherPrivate::processApplicationToLaunchArgument()
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
bool ctkAppLauncherPrivate::processExtraApplicationToLaunchArgument(const QStringList& unparsedArgs)
{
  foreach(const QString& extraAppLongArgument, this->ExtraApplicationToLaunchList.keys())
    {
    ctkAppLauncherPrivate::ExtraApplicationToLaunchProperty extraAppToLaunchProperty =
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
QString ctkAppLauncherPrivate::invalidSettingsMessage() const
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
bool ctkAppLauncherPrivate::verbose() const
{
  return this->ParsedArgs.value("launcher-verbose").toBool();
}

// --------------------------------------------------------------------------
QString ctkAppLauncherPrivate::splashImagePath()const
{
  if (!this->Initialized)
    {
    return this->DefaultLauncherSplashImagePath;
    }

  return this->LauncherSplashImagePath;
}

// --------------------------------------------------------------------------
bool ctkAppLauncherPrivate::disableSplash() const
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
      || this->LauncherNoSplashScreen
      || !this->ParsedArgs.value("launch").toString().isEmpty())
    {
    return true;
    }
  return false;
}

// --------------------------------------------------------------------------
QString ctkAppLauncherPrivate::searchPaths(const QString& executableName, const QStringList& extensions)
{
  QStringList paths = this->SystemEnvironment.value(this->PathVariableName).split(this->PathSep);
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
      QString msg = QString("Checking if [%1] exists in [%2]").arg(executableNameWithExt).arg(expandedPath);
      this->reportInfo(msg);
      if (QFile::exists(executablePath))
        {
        this->reportInfo(msg + " - Found");
        return executablePath;
        }
      else
        {
        this->reportInfo(msg + " - Not found");
        }
      }
    }
  return QString();
}

// --------------------------------------------------------------------------
QString ctkAppLauncherPrivate::trimArgumentPrefix(const QString& argument) const
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
bool ctkAppLauncherPrivate::extractLauncherNameAndDir(const QString& applicationFilePath)
{
  QFileInfo fileInfo(applicationFilePath);

  // In case a symlink to the launcher is available from the PATH, resolve its location.
  if (!fileInfo.exists())
    {
    QStringList paths = this->SystemEnvironment.value(this->PathVariableName).split(this->PathSep);
    foreach(const QString& path, paths)
      {
      QString executablePath = QDir(path).filePath(fileInfo.fileName());
      QString msg = QString("Checking if [%1] exists in [%2]").arg(fileInfo.fileName()).arg(path);
      this->reportInfo(msg);
      if (QFile::exists(executablePath))
        {
        this->reportInfo(msg + " - Found");
        fileInfo = QFileInfo(executablePath);
        break;
        }
      else
        {
        this->reportInfo(msg + " - Not found");
        }
      }
    }

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
QString ctkAppLauncherPrivate::shellQuote(bool posix, QString text, const QString& trailing)
{
#ifdef Q_OS_WIN32
  if (!posix)
    {
    static QRegExp reSpecialCharacters("([\"^])");
    text.replace(reSpecialCharacters, "^\\1");
    text.replace("\n", "^\n\n");
    return text + trailing;
    }
#else
  Q_UNUSED(posix)
#endif

  static QRegExp reSpecialCharacters("([`$\"!\\\\])");
  text.replace(reSpecialCharacters, "\\\\1");
  return QString("\"%1%2\"").arg(text, trailing);
}

// --------------------------------------------------------------------------
void ctkAppLauncherPrivate::buildEnvironment(QProcessEnvironment &env)
{
  Q_Q(ctkAppLauncher);

  this->reportInfo(QString("<APPLAUNCHER_DIR> -> [%1]").arg(this->LauncherDir));
  this->reportInfo(QString("<APPLAUNCHER_NAME> -> [%1]").arg(this->LauncherName));
  this->reportInfo(QString("<APPLAUNCHER_SETTINGS_DIR> -> [%1]").arg(this->LauncherSettingsDir));
  this->reportInfo(QString("<PATHSEP> -> [%1]").arg(this->PathSep));

  if(this->LoadEnvironment >= 0)
    {
    env = ctkAppLauncherEnvironment::environment(this->LoadEnvironment);
    }

  // Regular environment variables
  QHash<QString, QString> envVars = q->envVars();
  foreach(const QString& key, envVars.keys())
    {
    this->reportInfo(QString("Setting env. variable [%1]:%2").arg(key, envVars[key]));
    env.insert(key, envVars[key]);
    }

  // Path environment variables
  QHash<QString, QStringList> pathsEnvVars = q->pathsEnvVars();
  foreach(const QString& key, pathsEnvVars.keys())
    {
    QString value = pathsEnvVars[key].join(this->PathSep);
    this->reportInfo(QString("Setting env. variable [%1]:%2").arg(key, value));
    if (env.contains(key))
      {
      value = QString("%1%2%3").arg(value, this->PathSep, env.value(key));
      }
    env.insert(key, value);
    }

  // Do not save environment if one should be loaded
  if(this->LoadEnvironment >= 0)
    {
    return;
    }

  QSet<QString> variables =
      q->envVars().keys().toSet() +
      q->pathsEnvVars().keys().toSet() +
      this->SystemEnvironmentKeys.toSet();

  ctkAppLauncherEnvironment::saveEnvironment(
        this->SystemEnvironment, variables.values(), env);
}

// --------------------------------------------------------------------------
bool ctkAppLauncherPrivate::readSettings(const QString& fileName, int settingsType)
{
  if (!this->Initialized)
    {
    return false;
    }

  if (!this->checkSettings(fileName, settingsType))
    {
    if (!this->ReadSettingsError.isEmpty())
      {
      this->reportError(this->ReadSettingsError);
      }
    return false;
    }
  QSettings settings(fileName, QSettings::IniFormat);

  // Read default launcher image path
  QVariant splashImagePathVariant = settings.value("launcherSplashImagePath");
  if (splashImagePathVariant.isValid() && !splashImagePathVariant.toString().isEmpty())
    {
    this->DefaultLauncherSplashImagePath = splashImagePathVariant.toString();
    }

  QVariant splashScreenHideDelayMsVariant = settings.value("launcherSplashScreenHideDelayMs");
  if (splashScreenHideDelayMsVariant.isValid() && splashScreenHideDelayMsVariant.toInt() != 0)
    {
    this->DefaultLauncherSplashScreenHideDelayMs = splashScreenHideDelayMsVariant.toInt();
    }

  if (settings.contains("launcherNoSplashScreen"))
    {
    this->LauncherNoSplashScreen = settings.value("launcherNoSplashScreen").toBool();
    }

  this->LoadEnvironment = settings.value("launcherLoadEnvironment", -1).toInt();

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

  if(settingsType == Self::RegularSettings)
    {
    // Read additional settings info
    this->AdditionalSettingsFilePath = settings.value("additionalSettingsFilePath", "").toString();
    this->AdditionalSettingsFilePath = this->expandValue(this->AdditionalSettingsFilePath);
    this->readUserAdditionalSettingsInfo(settings);
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

  this->Superclass::readPathSettings(settings);

  return true;
}

// --------------------------------------------------------------------------
void ctkAppLauncherPrivate::runProcess()
{
  this->Process.setProcessChannelMode(QProcess::ForwardedChannels);

  QProcessEnvironment env = this->SystemEnvironment;

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
void ctkAppLauncherPrivate::terminateProcess()
{
  this->Process.terminate();
}

// --------------------------------------------------------------------------
void ctkAppLauncherPrivate::applicationFinished(int exitCode, QProcess::ExitStatus  exitStatus)
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
void ctkAppLauncherPrivate::applicationStarted()
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
  : Superclass(new ctkAppLauncherPrivate(*this), parentObject)
{
  this->setApplication(application);
}

// --------------------------------------------------------------------------
ctkAppLauncher::ctkAppLauncher(QObject* parentObject)
  : Superclass(new ctkAppLauncherPrivate(*this), parentObject)
{
}

// --------------------------------------------------------------------------
ctkAppLauncher::~ctkAppLauncher()
{
}

// --------------------------------------------------------------------------
void ctkAppLauncher::displayEnvironment(std::ostream &output)
{
  Q_D(ctkAppLauncher);
  if (d->LauncherName.isEmpty())
    {
    return;
    }
  QProcessEnvironment env;
  d->buildEnvironment(env);
  QStringList envAsList = env.toStringList();
  envAsList.sort();
  foreach (const QString& envArg, envAsList)
    {
    output << qPrintable(envArg) << std::endl;
    }
  if(envAsList.isEmpty())
    {
    output << "(No environment to display)" << std::endl;
    }
}

// --------------------------------------------------------------------------
void ctkAppLauncher::generateEnvironmentScript(QTextStream &output, bool posix)
{
  Q_D(ctkAppLauncher);
  if (d->LauncherName.isEmpty())
    {
    return;
    }

  QProcessEnvironment env;

  d->buildEnvironment(env);
  QStringList envKeys = ctkAppLauncherEnvironment::envKeys(env);
  envKeys.sort();

  QSet<QString> appendVars = d->AdditionalPathVariables;
  appendVars << d->PathVariableName << d->LibraryPathVariableName;

  static const char* const exportFormatPosix = "declare -x %1;";
  static const char* const appendFormatPosix = "${%1:+%2$%1}";
#ifdef Q_OS_WIN32
  static const char* const exportFormatWinCmd = "@set %1";
  static const char* const appendFormatWinCmd = "%2%%1%";
  const QString exportFormat(posix ? exportFormatPosix : exportFormatWinCmd);
  const QString appendFormat(posix ? appendFormatPosix : appendFormatWinCmd);
#else
  const QString exportFormat(exportFormatPosix);
  const QString appendFormat(appendFormatPosix);
#endif

  foreach(const QString& key, envKeys)
    {
    const QString pair = QString("%1=%2").arg(key, env.value(key));
    if (appendVars.contains(key))
      {
      const QString trailing = appendFormat.arg(key, d->PathSep);
      output << exportFormat.arg(d->shellQuote(posix, pair, trailing)) << '\n';
      }
    else
      {
      output << exportFormat.arg(d->shellQuote(posix, pair)) << '\n';
      }
    }
}

// --------------------------------------------------------------------------
bool ctkAppLauncher::generateExecWrapperScript()
{
  Q_D(ctkAppLauncher);
  if (d->LauncherName.isEmpty())
    {
    return false;
    }

#ifdef Q_OS_WIN32
  const QString scriptComment("::");
  const QString scriptExtension("bat");
#else
  const QString scriptComment("#");
  const QString scriptExtension("sh");
#endif

  QTemporaryFile launcherScript(QDir::temp().filePath("Slicer-XXXXXX.%1").arg(scriptExtension));
  launcherScript.setAutoRemove(false);
  if (!launcherScript.open())
    {
    d->reportError("Failed to generate executable wrapper script.");
    return false;
    }
  QTextStream out(&launcherScript);

#ifndef Q_OS_WIN32
  out << "#!/usr/bin/env bash\n\n";
#endif

  out << scriptComment << " This script has been generated using "
      << d->LauncherName << " launcher " << CTKAppLauncher_VERSION << '\n'
      << '\n'
      << scriptComment << " WARNING Usage of --launcher-generate-exec-wrapper-script is experimental and not tested.\n"
      << scriptComment << " WARNING Community contribution are welcome. See https://github.com/commontk/AppLauncher/issues/36\n"
      << '\n';

  this->generateEnvironmentScript(out);

#ifndef Q_OS_WIN32
  out << "\n[ \"$#\" -gt \"0\" ] && exec \"$@\"\n";
#endif

  d->reportInfo(
        QString("Launcher script generated [%1]").arg(launcherScript.fileName()),
        /* force= */ true);

  return true;
}

// --------------------------------------------------------------------------
void ctkAppLauncher::displayHelp(std::ostream &output)
{
  Q_D(ctkAppLauncher);
  if (d->LauncherName.isEmpty())
    {
    return;
    }

  // Add "extra application to launch" arguments so that helpText() consider them.
  foreach(const QString& extraAppLongArgument, d->ExtraApplicationToLaunchList.keys())
    {
    ctkAppLauncherPrivate::ExtraApplicationToLaunchProperty extraAppToLaunchProperty =
        d->ExtraApplicationToLaunchList[extraAppLongArgument];
    QString extraAppShortArgument = extraAppToLaunchProperty.value("shortArgument");
    d->Parser.addArgument(extraAppLongArgument, extraAppShortArgument, QVariant::Bool,
                                       extraAppToLaunchProperty.value("help"));
    }

  output << "Usage\n";
  output << "  " << qPrintable(d->LauncherName) << " [options]\n\n";
  output << "Options\n";
  output << qPrintable(d->Parser.helpText());
}

// --------------------------------------------------------------------------
void ctkAppLauncher::displayVersion(std::ostream &output)
{
  Q_D(ctkAppLauncher);
  if (d->LauncherName.isEmpty())
    {
    return;
    }
  output << qPrintable(d->LauncherName) << " launcher version " CTKAppLauncher_VERSION << "\n";
}

// --------------------------------------------------------------------------
bool ctkAppLauncher::initialize(QString launcherFilePath)
{
  Q_D(ctkAppLauncher);
  if (d->Initialized)
    {
    return true;
    }

  // Set verbose flags now so that call to "reportInfo" in "initialize" method properly
  // display information.
  d->ParsedArgs.insert(
        "launcher-verbose", QVariant(d->Arguments.contains("--launcher-verbose")));

  if (launcherFilePath.isEmpty() && d->Application)
    {
    launcherFilePath = d->Application->applicationFilePath();
    }
  if (!d->extractLauncherNameAndDir(launcherFilePath))
    {
    return false;
    }

  ctkCommandLineParser & parser = d->Parser;
  parser.setArgumentPrefix(d->LongArgPrefix, d->ShortArgPrefix);

  parser.addArgument("launcher-help","", QVariant::Bool, "Display help");
  parser.addArgument("launcher-version","", QVariant::Bool, "Show launcher version information");
  parser.addArgument("launcher-verbose", "", QVariant::Bool, "Verbose mode");
  parser.addArgument("launch", "", QVariant::String, "Specify the application to launch",
                     QVariant(d->DefaultApplicationToLaunch), true /*ignoreRest*/);
  parser.addArgument("launcher-detach", "", QVariant::Bool,
                     "Launcher will NOT wait for the application to finish");
  parser.addArgument("launcher-no-splash", "", QVariant::Bool,"Hide launcher splash");
  parser.addArgument("launcher-timeout", "", QVariant::Int,
                     "Specify the time in second before the launcher kills the application. "
                     "-1 means no timeout", QVariant(-1));
  parser.setExactMatchRegularExpression("launcher-timeout",
                                        "(-1)|([0-9]+)", "-1 or a positive integer is expected.");
  parser.addArgument("launcher-load-environment", "", QVariant::Int,
                     "Specify the saved environment to load.");
  parser.setExactMatchRegularExpression("launcher-load-environment",
                                        "([0-9]+)", "a positive integer is expected.");
  parser.addArgument("launcher-dump-environment", "", QVariant::Bool,
                     "Launcher will print environment variables to be set, then exit");
  parser.addArgument("launcher-show-set-environment-commands", "", QVariant::Bool,
                     "Launcher will print commands suitable for setting the parent environment "
                     "(i.e. using 'eval' in a POSIX shell), then exit");
  parser.addArgument("launcher-additional-settings", "", QVariant::String,
                     "Additional settings file to consider");
  parser.addArgument("launcher-ignore-user-additional-settings", "", QVariant::Bool,
                     "Ignore additional user settings");
  parser.addArgument("launcher-generate-exec-wrapper-script", "", QVariant::Bool,
                     "Generate executable wrapper script allowing to set the environment");
  parser.addArgument("launcher-generate-template", "", QVariant::Bool,
                     "Generate an example of setting file");

  // TODO Should SplashImagePath and SplashScreenHideDelayMs be added as parameters ?

  d->Initialized = true;
  return true;
}

// --------------------------------------------------------------------------
void ctkAppLauncher::setApplication(const QCoreApplication& app)
{
  Q_D(ctkAppLauncher);
  d->Application = app.instance();
  if (d->Application)
    {
    this->setArguments(d->Application->arguments());
    }
}

// --------------------------------------------------------------------------
QStringList ctkAppLauncher::arguments()const
{
  Q_D(const ctkAppLauncher);
  return d->Arguments;
}

// --------------------------------------------------------------------------
void ctkAppLauncher::setArguments(const QStringList& args)
{
  Q_D(ctkAppLauncher);
  d->Arguments = args;
}

// --------------------------------------------------------------------------
int ctkAppLauncher::processArguments()
{
  Q_D(ctkAppLauncher);
  if (!d->Initialized)
    {
    return Self::ExitWithError;
    }

  bool ok = false;
  d->ParsedArgs =
      d->Parser.parseArguments(d->Arguments, &ok);
  if (!ok)
    {
    std::cerr << "Error\n  "
              << qPrintable(d->Parser.errorString()) << "\n" << std::endl;
    return Self::ExitWithError;
    }

  bool reportInfo = d->LauncherStarting
      || d->ParsedArgs.value("launcher-help").toBool()
      || d->ParsedArgs.value("launcher-version").toBool()
      || d->ParsedArgs.value("launcher-dump-environment").toBool()
      || d->ParsedArgs.value("launcher-show-set-environment-commands").toBool()
      || d->ParsedArgs.value("launcher-generate-template").toBool()
      || d->ParsedArgs.value("launcher-generate-exec-wrapper-script").toBool();

  if (d->ParsedArgs.value("launcher-help").toBool())
    {
    this->displayHelp();
    return Self::ExitWithSuccess;
    }

  if (d->ParsedArgs.value("launcher-version").toBool())
    {
    this->displayVersion();
    return Self::ExitWithSuccess;
    }

  if (!d->processUserAdditionalSettings())
    {
    return Self::ExitWithError;
    }

  if (!d->processAdditionalSettings())
    {
    return Self::ExitWithError;
    }

  if (!d->processAdditionalSettingsArgument())
    {
    return Self::ExitWithError;
    }

  if (reportInfo)
    {
    d->reportInfo(
        QString("LauncherDir [%1]").arg(d->LauncherDir));

    d->reportInfo(
        QString("LauncherName [%1]").arg(d->LauncherName));

    d->reportInfo(
        QString("OrganizationDomain [%1]").arg(d->OrganizationDomain));

    d->reportInfo(
        QString("OrganizationName [%1]").arg(d->OrganizationName));

    d->reportInfo(
        QString("ApplicationName [%1]").arg(d->ApplicationName));

    d->reportInfo(
        QString("ApplicationRevision [%1]").arg(d->ApplicationRevision));

    d->reportInfo(
        QString("SettingsFileName [%1]").arg(this->findSettingsFile()));

    d->reportInfo(
        QString("SettingsDir [%1]").arg(d->LauncherSettingsDir));

    d->reportInfo(
        QString("UserAdditionalSettingsDir [%1]").arg(d->userAdditionalSettingsDir()));

    d->reportInfo(
        QString("UserAdditionalSettingsFileName [%1]").arg(this->findUserAdditionalSettings()));

    d->reportInfo(
        QString("UserAdditionalSettingsFileBaseName [%1]").arg(d->UserAdditionalSettingsFileBaseName));

    d->reportInfo(
        QString("LauncherNoSplashScreen [%1]").arg(d->LauncherNoSplashScreen));

    d->reportInfo(
        QString("AdditionalLauncherHelpShortArgument [%1]").arg(d->LauncherAdditionalHelpShortArgument));

    d->reportInfo(
        QString("AdditionalLauncherHelpLongArgument [%1]").arg(d->LauncherAdditionalHelpLongArgument));

    d->reportInfo(
        QString("AdditionalLauncherNoSplashArguments [%1]").arg(d->LauncherAdditionalNoSplashArguments.join(",")));
    }

  d->DetachApplicationToLaunch =
      d->ParsedArgs.value("launcher-detach").toBool();
  if (d->LauncherStarting)
    {
    d->reportInfo(
        QString("DetachApplicationToLaunch [%1]").arg(d->DetachApplicationToLaunch));
    }

  if (d->ParsedArgs.contains("launcher-load-environment"))
    {
    d->LoadEnvironment =
        d->ParsedArgs.value("launcher-load-environment").toInt();
    }
  if (reportInfo)
    {
    d->reportInfo(
        QString("LoadEnvironment [%1]").arg(d->LoadEnvironment));
    }

  QStringList unparsedArgs = d->Parser.unparsedArguments();

  if (!d->processExtraApplicationToLaunchArgument(unparsedArgs))
    {
    return Self::ExitWithError;
    }

  if (unparsedArgs.contains(d->LauncherAdditionalHelpShortArgument) ||
      unparsedArgs.contains(d->LauncherAdditionalHelpLongArgument))
    {
    if (d->LauncherStarting && d->ExtraApplicationToLaunch.isEmpty())
      {
      this->displayHelp();
      }
    }

  if (d->ParsedArgs.value("launcher-generate-template").toBool())
    {
    bool success = this->generateTemplate();
    return success ? Self::ExitWithSuccess : Self::ExitWithError;
    }

  if (!d->processSplashPathArgument())
    {
    return Self::ExitWithError;
    }

  if (!d->processScreenHideDelayMsArgument())
    {
    return Self::ExitWithError;
    }

  if (d->ParsedArgs.value("launcher-show-set-environment-commands").toBool())
    {
    QTextStream out(stdout);
    this->generateEnvironmentScript(out, true);
    return Self::ExitWithSuccess;
    }

  if (d->ParsedArgs.value("launcher-generate-exec-wrapper-script").toBool())
    {
    bool success = this->generateExecWrapperScript();
    return success ? Self::ExitWithSuccess : Self::ExitWithError;
    }

  if (d->ParsedArgs.value("launcher-dump-environment").toBool())
    {
    this->displayEnvironment();
    return Self::ExitWithSuccess;
    }

  if (!d->processApplicationToLaunchArgument())
    {
    return Self::ExitWithError;
    }

  return Self::Continue;
}

// --------------------------------------------------------------------------
QString ctkAppLauncher::findSettingsFile()const
{
  Q_D(const ctkAppLauncher);
  if (!d->Initialized)
    {
    return QString();
    }

  foreach(const QString& subdir, d->LauncherSettingSubDirs)
    {
    QString fileName = QString("%1/%2/%3LauncherSettings.ini").
                       arg(d->LauncherDir).arg(subdir).
                       arg(d->LauncherName);
    if (QFile::exists(fileName))
      {
      return fileName;
      }
    }
  return QString();
}

bool ctkAppLauncher::writeSettings(const QString& outputFilePath)
{
  Q_D(ctkAppLauncher);
  if (!d->Initialized)
    {
    return false;
    }

  // Create or open settings file ...
  QSettings settings(outputFilePath, QSettings::IniFormat);
  if (settings.status() != QSettings::NoError)
    {
    d->reportError(
      QString("Failed to open setting file [%1]").arg(outputFilePath));
    return false;
    }

  // Clear settings
  settings.clear();

  settings.setValue("launcherSplashImagePath", d->LauncherSplashImagePath);
  settings.setValue("launcherSplashScreenHideDelayMs", d->LauncherSplashScreenHideDelayMs);
  settings.setValue("launcherNoSplashScreen", d->LauncherNoSplashScreen);
  settings.setValue("additionalLauncherHelpShortArgument", d->LauncherAdditionalHelpShortArgument);
  settings.setValue("additionalLauncherHelpLongArgument", d->LauncherAdditionalHelpLongArgument);
  settings.setValue("additionalLauncherNoSplashArguments", d->LauncherAdditionalNoSplashArguments);

  QHash<QString, QString> applicationGroup;
  applicationGroup["path"] = d->ApplicationToLaunch;
  applicationGroup["arguments"] = d->ApplicationToLaunchArguments.join(" ");
  ctk::writeKeyValuePairs(settings, applicationGroup, "Application");

  settings.beginGroup("ExtraApplicationToLaunch");
  foreach(const QString& extraAppLongArgument, d->ExtraApplicationToLaunchList.keys())
    {
    ctkAppLauncherPrivate::ExtraApplicationToLaunchProperty extraAppToLaunchProperty =
        d->ExtraApplicationToLaunchList.value(extraAppLongArgument);
    ctk::writeKeyValuePairs(settings, extraAppToLaunchProperty, extraAppLongArgument);
    }
  settings.endGroup();

  ctk::writeArrayValues(settings, d->ListOfPaths, "Paths", "path");
  ctk::writeArrayValues(settings, d->ListOfLibraryPaths, "LibraryPaths", "path");
  ctk::writeKeyValuePairs(settings, d->MapOfEnvVars, "EnvironmentVariables");

  return true;
}

// --------------------------------------------------------------------------
QString ctkAppLauncher::applicationToLaunch()const
{
  Q_D(const ctkAppLauncher);
  return d->ApplicationToLaunch;
}

// --------------------------------------------------------------------------
QString ctkAppLauncher::splashImagePath()const
{
  Q_D(const ctkAppLauncher);
  return d->splashImagePath();
}

// --------------------------------------------------------------------------
int ctkAppLauncher::splashScreenHideDelayMs()const
{
  Q_D(const ctkAppLauncher);
  if (!d->Initialized)
    {
    return d->DefaultLauncherSplashScreenHideDelayMs;
    }

  return d->LauncherSplashScreenHideDelayMs;
}

// --------------------------------------------------------------------------
bool ctkAppLauncher::disableSplash() const
{
  Q_D(const ctkAppLauncher);
  return d->disableSplash();
}

// --------------------------------------------------------------------------
bool ctkAppLauncher::verbose()const
{
  Q_D(const ctkAppLauncher);
  return d->verbose();
}

// --------------------------------------------------------------------------
void ctkAppLauncher::startApplication()
{
  Q_D(ctkAppLauncher);
  if (!d->Initialized)
    {
    return;
    }
  QTimer::singleShot(0, d, SLOT(runProcess()));
}

// --------------------------------------------------------------------------
bool ctkAppLauncher::generateTemplate()
{
  Q_D(ctkAppLauncher);
  d->ListOfPaths.clear();
  d->ListOfPaths << "/home/john/app1"
                              << "/home/john/app2";

  d->ListOfLibraryPaths.clear();
  d->ListOfLibraryPaths << "/home/john/lib1"
                                     << "/home/john/lib2";

  d->MapOfEnvVars.clear();
  d->MapOfEnvVars["SOMETHING_NICE"] = "Chocolate";
  d->MapOfEnvVars["SOMETHING_AWESOME"] = "Rock climbing !";

  d->LauncherAdditionalHelpShortArgument = "h";
  d->LauncherAdditionalHelpLongArgument = "help";
  d->LauncherAdditionalNoSplashArguments.clear();
  d->LauncherAdditionalNoSplashArguments << "ns" << "no-splash";

  d->ExtraApplicationToLaunchList.clear();
  ctkAppLauncherPrivate::ExtraApplicationToLaunchProperty extraAppToLaunchProperty;
  extraAppToLaunchProperty["shortArgument"] = "t";
  extraAppToLaunchProperty["help"] = "What time is it ?";
  extraAppToLaunchProperty["path"] = "/usr/bin/xclock";
  extraAppToLaunchProperty["arguments"] = "-digital";
  d->ExtraApplicationToLaunchList.insert("time", extraAppToLaunchProperty);

  d->ApplicationToLaunch = "/usr/bin/xcalc";
  d->LauncherSplashImagePath = "/home/john/images/splash.png";
  d->ApplicationToLaunchArguments.clear();
  d->ApplicationToLaunchArguments << "-rpn";

  QString outputFile = QString("%1/%2LauncherSettings.ini.template").
    arg(d->LauncherDir).
    arg(d->LauncherName);

  return this->writeSettings(outputFile);
}

// --------------------------------------------------------------------------
int ctkAppLauncher::configure()
{
  Q_D(ctkAppLauncher);
  if (!this->initialize())
    {
    d->exit(EXIT_FAILURE);
    return ctkAppLauncher::ExitWithError;
    }

  QString settingFileName = this->findSettingsFile();
  if (!settingFileName.isEmpty())
    {
    d->LauncherSettingsDir = QFileInfo(settingFileName).absoluteDir().absolutePath();
    }

  d->ValidSettingsFile = d->readSettings(settingFileName, ctkAppLauncherPrivate::RegularSettings);

  if (d->ValidSettingsFile)
    {
    if (!d->OrganizationName.isEmpty())
      {
      qApp->setOrganizationName(d->OrganizationName);
      }
    if (!d->OrganizationDomain.isEmpty())
      {
      qApp->setOrganizationDomain(d->OrganizationDomain);
      }
    if (!d->ApplicationName.isEmpty())
      {
      qApp->setApplicationName(d->ApplicationName);
      }
    }

  // Process command line arguments and load additional settings files if any
  int status = this->processArguments();
  if (status == ctkAppLauncher::ExitWithError)
    {
    if (!d->ValidSettingsFile)
      {
      d->reportError(d->invalidSettingsMessage());
      }
    this->displayHelp(std::cerr);
    d->exit(EXIT_FAILURE);
    return status;
    }
  else if (status == ctkAppLauncher::ExitWithSuccess)
    {
    d->exit(EXIT_SUCCESS);
    return status;
    }

  // Append 'unparsed arguments' to list of arguments that will be used to start the application.
  // If it applies, extra 'application to launch' short and long arguments should be
  // removed from that list.
  QStringList unparsedArguments = d->Parser.unparsedArguments();
  if (!d->ExtraApplicationToLaunchShortArgument.isEmpty())
    {
    unparsedArguments.removeAll(d->Parser.shortPrefix() + d->ExtraApplicationToLaunchShortArgument);
    }
  if (!d->ExtraApplicationToLaunchLongArgument.isEmpty())
    {
    unparsedArguments.removeAll(d->Parser.longPrefix() + d->ExtraApplicationToLaunchLongArgument);
    }

  d->ApplicationToLaunchArguments.append(unparsedArguments);
  return status;
}

// --------------------------------------------------------------------------
void ctkAppLauncher::startLauncher()
{
  Q_D(ctkAppLauncher);
  d->LauncherStarting = true;
  int res = this->configure();
  if (res != Self::Continue)
    {
    return;
    }
  this->startApplication();
}
