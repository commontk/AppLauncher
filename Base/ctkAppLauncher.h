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

///
/// \brief The ctkAppLauncher class provides an interface for setting
/// the environment before executing an application.
///
/// The ctkAppLauncher can be configured using setting files and/or command
/// line arguments. It relies on ctkAppLauncherSettings to parse settings file
/// and define the particular environment to set before executing
/// the selected application. Relative paths are resolved using the launcher
/// directory as the base.
///
/// Command line arguments
/// ----------------------
///
/// \todo Improve this paragraph
///
/// \code
/// Usage
/// CTKAppLauncher [options]
///
/// Options
/// --launcher-help                              Display help
/// --launcher-version                           Show launcher version information
/// --launcher-verbose                           Verbose mode
/// --launch                                     Specify the application to launch
/// --launcher-detach                            Launcher will NOT wait for the application to finish
/// --launcher-no-splash                         Hide launcher splash
/// --launcher-timeout                           Specify the time in second before the launcher kills the
///                                              application. -1 means no timeout (default: -1)
/// --launcher-load-environment                  Specify the saved environment to load.
/// --launcher-dump-environment                  Launcher will print environment variables to be set, then exit
/// --launcher-show-set-environment-commands     Launcher will print commands suitable for setting the parent
///                                              environment (i.e. using 'eval' in a POSIX shell), then exit
/// --launcher-additional-settings               Additional settings file to consider
/// --launcher-ignore-user-additional-settings   Ignore additional user settings
/// --launcher-generate-exec-wrapper-script      Generate executable wrapper script allowing to set the environment
/// --launcher-generate-template                 Generate an example of setting file
/// \endcode
///
/// Settings file format
/// --------------------
///
/// In addition of the settings already described in in ctkAppLauncherSettings
/// class, the ctkAppLauncher class adds support for keys found in the `[General]`
/// and `[ExtraApplicationToLaunch]` groups.
///
/// \todo Improve this paragraph
///
/// ### `[General]` group
///
/// Settings key                        | Description
/// ------------------------------------|----------------------------------------------
/// launcherSplashImagePath             | Absolute or relative path to splashscreen. If empty, it defaults to ``:Images/ctk-splash.png`.
/// launcherSplashScreenHideDelayMs     | Delay in milliseconds before hiding the launcher splashscreen. Default is 800ms.
/// launcherNoSplashScreen              | If set to 1, no splashscreen is shown.
/// launcherLoadEnvironment             | Optionally specify an integer identifying the saved environment to use.
/// additionalLauncherHelpShortArgument | Short argument indicating that the launcher help should be displayed (e.g `-h`). This argument is passed down to the application.
/// additionalLauncherHelpLongArgument  | Long argument indicating that the launcher help should be displayed (e.g `--help`). This argument is passed down to the application.
/// additionalLauncherNoSplashArguments | List of arguments passed to the launched application meaning that no launcher spashscreen should be displayed.
///
/// ### `[ExtraApplicationToLaunch]` group
///
/// This group allows to list applications that can be started using the launcher
/// environment.
///
/// The list of available applications is displayed if the help is requested.
///
/// For example, this launcher help will display these additional options:
///
/// \code
///
/// Options
///
///   [...]
///   --designer                                   Start Qt designer using Slicer plugins
///   --gnome-terminal                             Start gnome-terminal
///
/// \endcode
///
/// by adding the corresponding applications in the settings:
///
/// \code
/// [ExtraApplicationToLaunch]
///
/// designer/shortArgument=
/// designer/help=Start Qt designer using Slicer plugins
/// designer/path=/home/jcfr/Support/qt-everywhere-opensource-build-4.8.7/bin/designer
/// designer/arguments=
///
/// gnome-terminal/shortArgument=
/// gnome-terminal/help=Start gnome-terminal
/// gnome-terminal/path=/usr/bin/gnome-terminal
/// gnome-terminal/arguments=
///
/// ...
/// \endcode
///
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
