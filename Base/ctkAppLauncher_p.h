#ifndef __ctkAppLauncher_p_h
#define __ctkAppLauncher_p_h

// AppLauncher includes
#include "ctkAppLauncher.h"
#include "ctkAppLauncherSettings.h"
#include "ctkAppLauncherSettings_p.h"

// Qt includes
#include <QStringList>
#include <QSettings>
#include <QSharedPointer>
#include <QSplashScreen>
#include <QProcess>
#include <QDebug>
#include <QHash>

// CTK includes
#include "ctkCommandLineParser.h"

class QCoreApplication;

// --------------------------------------------------------------------------
class ctkInteractiveProcess : public QProcess
{
  static int StdinClone;

public:
  ctkInteractiveProcess(QObject* parent = 0);

protected:
  virtual void setupChildProcess();
};

// --------------------------------------------------------------------------
class ctkAppLauncherPrivate : public ctkAppLauncherSettingsPrivate
{
  Q_OBJECT
  Q_DECLARE_PUBLIC(ctkAppLauncher)
public:
  ctkAppLauncherPrivate(ctkAppLauncher& object);
  ~ctkAppLauncherPrivate() {}
  typedef ctkAppLauncherPrivate Self;
  typedef ctkAppLauncherSettingsPrivate Superclass;

  /// Display error on Standard Error
  void reportError(const QString& msg) const;

  /// Display status on Standard Output
  void reportInfo(const QString& msg, bool force = false) const;

  /// Exit the application if the application has been set.
  /// \sa ctkAppLauncher::setApplication
  void exit(int exitCode);

  /// Will return False if the object is NOT initialized
  bool readSettings(const QString& fileName, int settingsType);

  bool processApplicationToLaunchArgument();
  bool processExtraApplicationToLaunchArgument(const QStringList& unparsedArgs);
  bool processSplashPathArgument();
  bool processScreenHideDelayMsArgument();
  bool processAdditionalSettings();
  bool processAdditionalSettingsArgument();

  QString additionalSettingsDir() const;

  /// \sa ctkAppLauncherSettingsPrivate::findUserAdditionalSettings()
  bool processUserAdditionalSettings();

  bool extractLauncherNameAndDir(const QString& applicationFilePath);

  /// \brief Quote string to preserve value when seen by the default shell.
  ///
  /// This adds quotes and applies escaping the \p text so that the value may
  /// be safely parsed by the default shell (i.e. cmd on Windows if \p posix is
  /// \c false, sh otherwise) without being subject to additional expansion,
  /// substitution, etc. The additional text \p trailing is added inside of the
  /// escapes, but is \em not otherwise escaped; this is intended to be used to
  /// build prepend expressions to environment variables, like \c FOO=...:$FOO.
  static QString shellQuote(bool posix, QString text, const QString& trailing = QString());

  /// \brief Update the current process environment.
  ///
  /// Environment variables to set are retrieved using ctkAppLauncherSettings::envVars()
  /// and ctkAppLauncherSettings::pathsEnvVars().
  ///
  /// If the internal variable \c LoadEnvironment was set to value >=0, environment
  /// values are restored using ctkAppLauncherEnvironment::environment(int requestedLevel).
  ///
  /// Otherwise, the environment is saved using ctkAppLauncherEnvironment::saveEnvironment(const QProcessEnvironment& systemEnvironment, const QStringList& variables,
  /// QProcessEnvironment& env)
  ///
  /// \sa ctkAppLauncherEnvironment::environment(int requestedLevel), ctkAppLauncherEnvironment::saveEnvironment(const QProcessEnvironment& systemEnvironment, const QStringList&
  /// variables, QProcessEnvironment& env)
  /// \sa ctkAppLauncherSettings::envVars(), ctkAppLauncherSettings::pathsEnvVars()
  void buildEnvironment(QProcessEnvironment&);

  QString invalidSettingsMessage() const;
  bool verbose() const;
  QString splashImagePath() const;
  bool disableSplash() const;

  QString searchPaths(const QString& programName, const QStringList& extensions);

  QString trimArgumentPrefix(const QString& argument) const;

public slots:

  /// Called just after the splashscreen is shown
  /// \sa QTimer::singleShot()
  void runProcess();

  /// Terminate the started process
  void terminateProcess();

  /// Slot called when the ApplicationToLaunch process is terminated
  void applicationFinished(int exitCode, QProcess::ExitStatus exitStatus);

  /// Slot called when the ApplicationToLaunch process is started
  void applicationStarted();

  /// Slots used to forward child process output.
  /// It is used when the splashscreen is hidden on process output.
  void onReadyReadStandardOutput();
  void onReadyReadStandardError();
  void forwardProcessOutput(std::ostream& outputStream, QByteArray& data);

public:
  /// Options passed to the launcher from the command line
  // clang-format off
  QString     ApplicationToLaunch;
  QStringList ApplicationToLaunchArguments;
  QString     LauncherSplashImagePath;
  int         LauncherSplashScreenHideDelayMs;
  bool        LauncherNoSplashScreen;
  // clang-format on

  /// Variable used internally
  // clang-format off
  bool                            LauncherStarting;
  QStringList                     Arguments;
  ctkInteractiveProcess           Process;
  ctkCommandLineParser            Parser;
  QString                         ShortArgPrefix;
  QString                         LongArgPrefix;
  QHash<QString, QVariant>        ParsedArgs;
  QString                         ParseError;
  QString                         DefaultApplicationToLaunch;
  QString                         DefaultLauncherSplashImagePath;
  int                             DefaultLauncherSplashScreenHideDelayMs;
  QString                         DefaultApplicationToLaunchArguments;
  // QString                         LauncherName;
  // QString                         LauncherDir;
  // QString                         AdditionalSettingsFilePath;
  // QStringList                     AdditionalSettingsExcludeGroups;
  bool                            DisplayHelpAfterProcessFinished;
  QStringList                     LauncherSettingSubDirs;
  bool                            ValidSettingsFile;
//  QString                         OrganizationName;
//  QString                         OrganizationDomain;
//  QString                         ApplicationName;
//  QString                         ApplicationRevision;
//  QString                         UserAdditionalSettingsFileBaseName;
  QString                         LauncherAdditionalHelpShortArgument;
  QString                         LauncherAdditionalHelpLongArgument;
  QStringList                     LauncherAdditionalNoSplashArguments;
//  QStringList                     ListOfPaths;
//  QStringList                     ListOfLibraryPaths;
//  QSet<QString>                   AdditionalPathVariables;
//  QHash<QString, QString>         MapOfEnvVars;
  QCoreApplication*               Application;
  bool                            Initialized;
  bool                            DetachApplicationToLaunch;
  int                             LoadEnvironment;
//  QString                         PathSep;
//  QString                         LibraryPathVariableName;
  QSharedPointer<QSplashScreen>   SplashScreen;
  QScopedPointer<QPixmap>         SplashPixmap;
//  QProcessEnvironment             SystemEnvironment;
  // clang-format on

  /// If true, the splash screen will be hidden as soon as the launched
  /// process writes something to stdout or stderr, instead of waiting for LauncherSplashScreenHideDelayMs.
  bool LauncherSplashScreenIgnoreOutput;
  bool LauncherSplashScreenHidden;

  /// Extra 'application to launch'
  // clang-format off
  QString                                          ExtraApplicationToLaunchLongArgument;
  QString                                          ExtraApplicationToLaunchShortArgument;
  QString                                          ExtraApplicationToLaunch;
  QString                                          ExtraApplicationToLaunchArguments;
  typedef QHash<QString, QString>                  ExtraApplicationToLaunchProperty;
  QHash<QString, ExtraApplicationToLaunchProperty> ExtraApplicationToLaunchList;
  // clang-format on
};

#endif
