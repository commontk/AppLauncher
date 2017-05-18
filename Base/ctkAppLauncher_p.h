#ifndef __ctkAppLauncher_p_h
#define __ctkAppLauncher_p_h

// AppLauncher includes
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
class ctkAppLauncherPrivate : public ctkAppLauncherSettingsPrivate
{
  Q_OBJECT
public:
  ctkAppLauncherPrivate();
  ~ctkAppLauncherPrivate(){}
  typedef ctkAppLauncherPrivate Self;

  /// Display error on Standard Error
  void reportError(const QString& msg)const;

  /// Display status on Standard Output
  void reportInfo(const QString& msg, bool force = false)const;

  /// Exit the application if the application has been set.
  /// \sa ctkAppLauncher::setApplication
  void exit(int exitCode);

  /// Return additional settings directory associated with the \a ApplicationOrganization
  /// read from the main settings.
  /// The location of the additional settings directory is expected to match the following
  /// path: path/to/settings/<OrganisationName|DomainName>/
  QString additionalSettingsDir()const;

  QString findUserAdditionalSettings()const;

  enum SettingsType
    {
    RegularSettings = 0,
    AdditionalSettings,
    UserAdditionalSettings
    };

  bool readSettings(const QString& fileName, int settingsType);

  void buildEnvironment(QProcessEnvironment&);
  bool processApplicationToLaunchArgument();
  bool processExtraApplicationToLaunchArgument(const QStringList& unparsedArgs);
  bool processSplashPathArgument();
  bool processScreenHideDelayMsArgument();
  bool processAdditionalSettingsArgument();

  /// \sa ctkAppLauncher::findUserAdditionalSettings()
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

  /// \brief Expand setting \a value
  /// The following string will be updated:
  /// <ul>
  ///  <li>&lt;APPLAUNCHER_DIR&gt; -> LauncherDir</li>
  ///  <li>&lt;APPLAUNCHER_NAME&gt; -> LauncherName</li>
  ///  <li>&lt;PATHSEP&gt; -> PathSep</li>
  ///  <li>&lt;env:VARNAME&gt; -> If any, expand to corresponding system environment variable</li>
  /// </ul>
  QString expandValue(const QString& value);

  QString invalidSettingsMessage()const;
  virtual bool verbose()const;
  QString splashImagePath()const;
  bool disableSplash()const;

  QString searchPaths(const QString& programName, const QStringList& extensions);

  QString trimArgumentPrefix(const QString& argument) const;

public slots:

  /// Called just after the splashscreen is shown
  /// \sa QTimer::singleShot()
  void runProcess();

  /// Terminate the started process
  void terminateProcess();

  /// Slot called when the ApplicationToLaunch process is terminated
  void applicationFinished(int exitCode, QProcess::ExitStatus  exitStatus);

  /// Slot called when the ApplicationToLaunch process is started
  void applicationStarted();

public:
  /// Options passed to the launcher from the command line
  QString     ApplicationToLaunch;
  QStringList ApplicationToLaunchArguments;
//  QString     LauncherSplashImagePath;
//  int         LauncherSplashScreenHideDelayMs;
//  bool        LauncherNoSplashScreen;

  /// Variable used internally
  bool                            LauncherStarting;
  QStringList                     Arguments;
  QProcess                        Process;
  ctkCommandLineParser            Parser;
  QString                         ShortArgPrefix;
  QString                         LongArgPrefix;
  QHash<QString, QVariant>        ParsedArgs;
  QString                         ParseError;
//  QString                         DefaultApplicationToLaunch;
//  QString                         DefaultLauncherSplashImagePath;
//  int                             DefaultLauncherSplashScreenHideDelayMs;
//  bool                            DefaultLauncherNoSplashScreen;
//  QString                         DefaultApplicationToLaunchArguments;
//  QString                         LauncherName;
//  QString                         LauncherDir;
//  QStringList                     LauncherSettingSubDirs;
  bool                            ValidSettingsFile;
//  QString                         OrganizationName;
//  QString                         OrganizationDomain;
//  QString                         ApplicationName;
//  QString                         ApplicationRevision;
//  QString                         UserAdditionalSettingsFileBaseName;
//  QString                         LauncherAdditionalHelpShortArgument;
//  QString                         LauncherAdditionalHelpLongArgument;
//  QStringList                     LauncherAdditionalNoSplashArguments;
//  QStringList                     ListOfPaths;
//  QStringList                     ListOfLibraryPaths;
//  QSet<QString>                   AdditionalPathVariables;
//  QHash<QString, QString>         MapOfEnvVars;
  QCoreApplication*               Application;
//  bool                            Initialized;
  bool                            DetachApplicationToLaunch;
//  QString                         PathSep;
//  QString                         LibraryPathVariableName;
  QSharedPointer<QSplashScreen>   SplashScreen;
  QScopedPointer<QPixmap>         SplashPixmap;
//  QProcessEnvironment             SystemEnvironment;

  /// Extra 'application to launch'
//  QString                                          ExtraApplicationToLaunchLongArgument;
//  QString                                          ExtraApplicationToLaunchShortArgument;
  QString                                          ExtraApplicationToLaunch;
  QString                                          ExtraApplicationToLaunchArguments;
//  typedef QHash<QString, QString>                  ExtraApplicationToLaunchProperty;
//  QHash<QString, ExtraApplicationToLaunchProperty> ExtraApplicationToLaunchList;
};

#endif
