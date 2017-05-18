#ifndef __ctkAppLauncher_h
#define __ctkAppLauncher_h

// Qt includes
#include <QTextStream>
#include <QString>
#include <QStringList>
#include <QSettings>
#include <QCoreApplication>

// CTK includes
#include "ctkAppLauncherSettings.h"

// STD includes
#include <iostream>

class ctkAppLauncherPrivate;

// --------------------------------------------------------------------------
class ctkAppLauncher : public ctkAppLauncherSettings
{
  Q_OBJECT
public:
  typedef ctkAppLauncher Self;
  typedef ctkAppLauncherSettings Superclass;
  ctkAppLauncher(const QCoreApplication& application, QObject* parentObject = 0);
  ctkAppLauncher(QObject* parentObject = 0);
  ~ctkAppLauncher();

  enum ProcessArgumentsStatus
    {
    ExitWithError = 0,
    ExitWithSuccess,
    Continue
    };

  /// Display environment variables on standard output
  void displayEnvironment(std::ostream &output = std::cout);

  void generateEnvironmentScript(QTextStream &output, bool posix = false);

  bool generateExecWrapperScript();

  /// Display help string on standard output
  void displayHelp(std::ostream &output = std::cout);

  /// Display version information string on standard output
  void displayVersion(std::ostream &output = std::cout);

  /// Initialize launcher by extracting associated name and directory, and
  /// configuring the command line parser.
  /// \a launcherFilePath is the path of the launcher used to extract its
  /// name and directory. If empty, the application file path is used instead.
  /// Return false if it fails to initialize the arguments.
  /// \sa setArguments(), configure()
  bool initialize(QString launcherFilePath = QString());

  /// Read command line arguments to configure launcher behavior.
  /// Configure the AppLauncher by first initializing the arguments (see
  /// initialize()) and then read settings from ini file and parse arguments
  /// arguments from command line.
  /// Return ProcessArgumentsStatus::Continue if the application must be launched,
  /// or either ProcessArgumentsStatus::ExitWithError or ProcessArgumentsStatus::ExitWithSuccess otherwise.
  /// \sa initialize(), setArguments(), startLauncher()
  int configure();

  /// Set the launcher application and its arguments
  /// \sa setArguments()
  void setApplication(const QCoreApplication& app);

  /// Set/Get list of arguments that will be passed to the program to launch.
  /// By default, \a arguments associated with the \a application are used.
  /// \sa ctkAppLauncher(), QCoreApplication::arguments(), setApplication()
  QStringList arguments()const;
  void setArguments(const QStringList& args);

  /// Parse arguments
  /// Return ProcessArgumentsStatus::ExitWithError in case of parse error
  /// or if the object is NOT initialized
  int processArguments();

  /// Return associated settingsFileName
  /// Will return an empty string if the object is NOT initialized or
  /// if the file does NOT exist
  QString findSettingsFile()const;

  /// Read/Write settings
  /// Will return False if the object is NOT initialized
  bool writeSettings(const QString& outputFilePath);

  /// Get applicationToLaunch
  QString applicationToLaunch()const;

  /// Start the ApplicationToLaunch as a child process
  /// Will return False if the object is NOT initialized
  void startApplication();

  /// Return the associated splash screen image path
  QString splashImagePath()const;

  /// \brief Return the delay in ms before the launcher hides the splashscreen.
  /// The delay is applied after the application finishes to start.
  int splashScreenHideDelayMs()const;

  /// \brief Return true if the splash-screen should not be visible when
  /// starting the launched application, false otherwise.
  /// false by default.
  bool disableSplash()const;

  /// Get verbose flag
  /// If True, print to standard output information associated with the parameters
  /// passed to the launcher, launcher settings, etc ...
  bool verbose()const;

  bool generateTemplate();

public slots:

  /// Slot called just after the application event loop is started
  void startLauncher();

private:
  Q_DECLARE_PRIVATE(ctkAppLauncher)
  Q_DISABLE_COPY(ctkAppLauncher)
};

#endif
