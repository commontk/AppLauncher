
//Qt includes
#include <QFile>
#include <QFileInfo>
#include <QProcessEnvironment>
#include <QDebug>
#include <QTimer>
#include <QApplication>

// CTK includes
#include "ctkAppLauncher.h"
#include "ctkAppLauncher_p.h"
#include "ctkSettingsHelper.h"

// STD includes
#include <iostream>
#include <cstdlib>

// --------------------------------------------------------------------------
// ctkAppLauncherInternal methods

// --------------------------------------------------------------------------
ctkAppLauncherInternal::ctkAppLauncherInternal()
{
  this->Application = 0;
  this->Initialized = false;
  this->DefaultLauncherSplashImagePath;
  this->DetachApplicationToLaunch = false;
  this->LauncherSplashScreenHideDelayMs = -1;
  this->DefaultLauncherSplashImagePath = ":Images/ctk-splash.png";
  this->DefaultLauncherSplashScreenHideDelayMs = 0;
  this->LauncherSettingSubDirs << "." << "bin" << "lib";
  this->ValidSettingsFile = false;

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
bool ctkAppLauncherInternal::processSplashPathArgument()
{
  if (this->LauncherSplashImagePath.isEmpty())
    {
    this->LauncherSplashImagePath = this->DefaultLauncherSplashImagePath;
    }
  this->LauncherSplashImagePath = this->expandValue(this->LauncherSplashImagePath);
  this->reportInfo(QString("LauncherSplashImagePath [%1]").arg(this->LauncherSplashImagePath));
    
  // Make sure the splash image exists
  if (!QFile::exists(this->LauncherSplashImagePath))
    {
    this->reportError(
      QString("SplashImage do NOT exists [%1]").arg(this->LauncherSplashImagePath));
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
bool ctkAppLauncherInternal::processApplicationToLaunchArgument()
{
  // Overwrite applicationToLaunch with the value read from the settings file
  this->ApplicationToLaunch = this->ParsedArgs.value("launch").toString();
  if (this->ApplicationToLaunch.isEmpty())
    {
    this->ApplicationToLaunch = this->DefaultApplicationToLaunch;
    }

  this->ApplicationToLaunch = this->expandValue(this->ApplicationToLaunch);

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
bool ctkAppLauncherInternal::disableSplash() const
{
  QStringList unparsedArgs = this->Parser.unparsedArguments();
  if (this->ParsedArgs.value("launcher-no-splash").toBool() ||
      unparsedArgs.contains(this->LauncherAdditionalNoSplashShortArgument) ||
      unparsedArgs.contains(this->LauncherAdditionalNoSplashLongArgument))
    {
    return true;
    }
  return false;
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
void ctkAppLauncherInternal::runProcess()
{
  this->Process.setProcessChannelMode(QProcess::ForwardedChannels);

  QProcessEnvironment env = QProcessEnvironment::systemEnvironment();

  // LD_LIBRARY_PATH (linux), DYLD_LIBRARY_PATH (mac), PATH (win) ...
  QString libPathVarName = this->LibraryPathVariableName;

  this->reportInfo(QString("<APPLAUNCHER_DIR> -> [%1]").arg(this->LauncherDir));

  // Set library paths
  foreach(const QString& path, this->ListOfLibraryPaths)
    {
    this->reportInfo(QString("Setting library path [%1]").arg(path));
    env.insert(libPathVarName, path + this->PathSep + this->expandValue(env.value(libPathVarName)));
    }

  // Update Path - First path of the list will be the first on the PATH
  for(int i =  this->ListOfPaths.size() - 1; i >= 0; --i)
    {
    this->reportInfo(QString("Setting path [%1]").arg(this->ListOfPaths.at(i)));
    env.insert("PATH", this->ListOfPaths.at(i) + this->PathSep
               + this->expandValue(env.value("PATH")));
    }

  // Set additional environment variables
  foreach(const QString& key, this->MapOfEnvVars.keys())
    {
    QString value = this->MapOfEnvVars[key];
    this->reportInfo(QString("Setting env. variable [%1]:%2").arg(key).arg(value));
    env.insert(key, this->expandValue(value));
    }

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
    this->Application->quit();
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
    this->Application->exit(exitCode);
    }
  else if (exitStatus == QProcess::CrashExit)
    {
    this->reportError(
      QString("[%1] exit abnormally - Report the problem.").
        arg(this->ApplicationToLaunch));
    this->Application->exit(EXIT_FAILURE);
    }
}

// --------------------------------------------------------------------------
void ctkAppLauncherInternal::applicationStarted()
{
  QTimer::singleShot(this->LauncherSplashScreenHideDelayMs,
                     this->SplashScreen.data(), SLOT(hide()));
}

// --------------------------------------------------------------------------
// ctkAppLauncher methods

// --------------------------------------------------------------------------
ctkAppLauncher::ctkAppLauncher(const QCoreApplication& application, QObject* parentObject):
  Superclass(parentObject)
{
  this->Internal = new ctkAppLauncherInternal();
  this->Internal->Application = application.instance();
}

// --------------------------------------------------------------------------
ctkAppLauncher::~ctkAppLauncher()
{
  delete this->Internal;
}

// --------------------------------------------------------------------------
void ctkAppLauncher::displayHelp(std::ostream &output)
{
  if (this->Internal->LauncherName.isEmpty())
    {
    return;
    }
  output << "Usage\n";
  output << "  " << qPrintable(this->Internal->LauncherName) << " [options]\n\n";
  output << "Options\n";
  output << qPrintable(this->Internal->Parser.helpText());
}

// --------------------------------------------------------------------------
bool ctkAppLauncher::initialize()
{
  if (this->Internal->Initialized)
    {
    this->Internal->reportError("AppLauncher already initialized !");
    return true;
    }

  if (!this->Internal->extractLauncherNameAndDir(
    this->Internal->Application->applicationFilePath()))
    {
    return false;
    }

  ctkCommandLineParser & parser = this->Internal->Parser;
  parser.setArgumentPrefix("--", "-");

  parser.addArgument("launcher-help","", QVariant::Bool, "Display help");
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
  parser.addArgument("launcher-generate-template", "", QVariant::Bool,
                     "Generate an example of setting file");

  // TODO Should SplashImagePath and SplashScreenHideDelayMs be added as parameters ?

  this->Internal->Initialized = true;
  return true;
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
      this->Internal->Parser.parseArguments(this->Internal->Application->arguments(), &ok);
  if (!ok)
    {
    std::cerr << "Error\n  " 
              << qPrintable(this->Internal->Parser.errorString()) << "\n" << std::endl;
    this->displayHelp();
    return Self::ExitWithError;
    }

  this->Internal->reportInfo(
      QString("LauncherDir [%1]").arg(this->Internal->LauncherDir));

  this->Internal->reportInfo(
      QString("LauncherName [%1]").arg(this->Internal->LauncherName));

  this->Internal->reportInfo(
      QString("SettingsFileName [%1]").arg(this->findSettingFile()));

  if (this->Internal->ParsedArgs.value("launcher-help").toBool())
    {
    this->displayHelp();
    return Self::ExitWithSuccess;
    }

  QStringList unparsedArgs = this->Internal->Parser.unparsedArguments();
  if (unparsedArgs.contains(this->Internal->LauncherAdditionalHelpShortArgument) ||
      unparsedArgs.contains(this->Internal->LauncherAdditionalHelpLongArgument))
    {
    this->displayHelp();
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
  if (!this->Internal->Initialized)
    {
    return false;
    }
    
  // Check if settings file exists
  if (!QFile::exists(fileName))
    {
//    this->Internal->reportError(
//      QString("Launcher setting file does NOT exist [%1]").arg(fileName));
    return false;
    }
    
  if (! (QFile::permissions(fileName) & QFile::ReadOwner) )
    {
    this->Internal->reportError(
      QString("Failed to read launcher setting file [%1]").arg(fileName));
    return false;
    }
  
  // Open settings file ... 
  QSettings settings(fileName, QSettings::IniFormat);
  if (settings.status() != QSettings::NoError)
    {
    this->Internal->reportError(
      QString("Failed to open setting file [%1]").arg(fileName));
    return false;
    }

  // Read default launcher image path
  this->Internal->DefaultLauncherSplashImagePath =
    settings.value("launcherSplashImagePath", ":Images/ctk-splash.png").toString();
  this->Internal->DefaultLauncherSplashScreenHideDelayMs =
    settings.value("launcherSplashScreenHideDelayMs", 0).toInt();

  // Read default application to launch
  QHash<QString, QString> applicationGroup = ctk::readKeyValuePairs(settings, "Application");
  this->Internal->DefaultApplicationToLaunch = applicationGroup["path"];
  this->Internal->DefaultApplicationToLaunchArguments = applicationGroup["arguments"];

  // Read additional launcher arguments
  this->Internal->LauncherAdditionalHelpShortArgument =
      settings.value("additionalLauncherHelpShortArgument").toString();
  this->Internal->LauncherAdditionalHelpLongArgument =
      settings.value("additionalLauncherHelpLongArgument").toString();
  this->Internal->LauncherAdditionalNoSplashShortArgument =
      settings.value("additionalLauncherNoSplashShortArgument").toString();
  this->Internal->LauncherAdditionalNoSplashLongArgument =
      settings.value("additionalLauncherNoSplashLongArgument").toString();
    
  // Read PATHs
  this->Internal->ListOfPaths = ctk::readArrayValues(settings, "Paths", "path");
  
  // Read LibraryPaths
  this->Internal->ListOfLibraryPaths = ctk::readArrayValues(settings, "LibraryPaths", "path");

  // Read additional environment variables
  this->Internal->MapOfEnvVars = ctk::readKeyValuePairs(settings, "EnvironmentVariables");
    
  return true;
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
  settings.setValue("additionalLauncherHelpShortArgument", this->Internal->LauncherAdditionalHelpShortArgument);
  settings.setValue("additionalLauncherHelpLongArgument", this->Internal->LauncherAdditionalHelpLongArgument);
  settings.setValue("additionalLauncherNoSplashShortArgument", this->Internal->LauncherAdditionalNoSplashShortArgument);
  settings.setValue("additionalLauncherNoSplashLongArgument", this->Internal->LauncherAdditionalNoSplashLongArgument);
  
  QHash<QString, QString> applicationGroup;
  applicationGroup["path"] = this->Internal->ApplicationToLaunch;
  applicationGroup["arguments"] = this->Internal->ApplicationToLaunchArguments.join(" ");
  ctk::writeKeyValuePairs(settings, applicationGroup, "Application");

  ctk::writeArrayValues(settings, this->Internal->ListOfPaths, "Paths", "path");
  ctk::writeArrayValues(settings, this->Internal->ListOfLibraryPaths, "LibraryPaths", "path");
  ctk::writeKeyValuePairs(settings, this->Internal->MapOfEnvVars, "EnvironmentVariables");
  
  return true;
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
  if (!this->Internal->Initialized)
    {
    return this->Internal->DefaultLauncherSplashImagePath;
    }
  
  return this->Internal->LauncherSplashImagePath;
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
    
  this->Internal->SplashPixmap.load(this->splashImagePath());
  this->Internal->SplashScreen =
      QSharedPointer<QSplashScreen>(new QSplashScreen(this->Internal->SplashPixmap, Qt::WindowStaysOnTopHint));
  if (!this->Internal->disableSplash())
    {
    this->Internal->reportInfo(QString("DisableSplash [%1]").arg(this->Internal->disableSplash()));
    this->Internal->SplashScreen->show();
    }

  QTimer::singleShot(50, this->Internal, SLOT(runProcess()));
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
  this->Internal->LauncherAdditionalNoSplashShortArgument = "ns";
  this->Internal->LauncherAdditionalNoSplashLongArgument = "no-splash";

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
void ctkAppLauncher::startLauncher()
{
  if (!this->initialize())
    {
    this->Internal->Application->exit(EXIT_FAILURE);
    return;
    }

  QString settingFileName = this->findSettingFile();

  this->Internal->ValidSettingsFile = this->readSettings(settingFileName);
//  if (!this->readSettings(settingFileName))
//    {
//    this->Internal->Application->exit(EXIT_FAILURE);
//    return;
//    }

  int status = this->processArguments();
  if (status == ctkAppLauncher::ExitWithError)
    {
    if (!this->Internal->ValidSettingsFile)
      {
      this->Internal->reportError(this->Internal->invalidSettingsMessage());
      }
    this->Internal->Application->exit(EXIT_FAILURE);
    return;
    }
  else if (status == ctkAppLauncher::ExitWithSuccess)
    {
    this->Internal->Application->exit(EXIT_SUCCESS);
    return;
    }

  this->Internal->ApplicationToLaunchArguments.append(this->Internal->Parser.unparsedArguments());

  this->startApplication();
}
