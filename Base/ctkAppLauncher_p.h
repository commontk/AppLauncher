#ifndef __ctkAppLauncher_p_h
#define __ctkAppLauncher_p_h

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
class ctkAppLauncherInternal : public QObject
{
  Q_OBJECT
public:
  ctkAppLauncherInternal();
  ~ctkAppLauncherInternal(){}

  /// Display error on Standard Error
  void reportError(const QString& msg);

  /// Display status on Standard Output
  void reportInfo(const QString& msg);

  void buildEnvironment(QProcessEnvironment&);
  bool processApplicationToLaunchArgument();
  bool processExtraApplicationToLaunchArgument(const QStringList& unparsedArgs);
  bool processSplashPathArgument();
  bool processScreenHideDelayMsArgument();

  bool extractLauncherNameAndDir(const QString& applicationFilePath);

  /// \brief Expand setting \a value
  /// The following string will be updated:
  /// <ul>
  ///  <li>&lt;APPLAUNCHER_DIR&gt; -> LauncherDir</li>
  ///  <li>&lt;APPLAUNCHER_NAME&gt; -> LauncherName</li>
  ///  <li>&lt;PATHSEP&gt; -> PathSep</li>
  /// </ul>
  QString expandValue(const QString& value);

  QString invalidSettingsMessage()const;
  bool verbose()const;
  bool disableSplash()const;

public slots:

  /// Called 50ms after the splashscreen is shown and the eventloop flushed
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
  QString     LauncherSplashImagePath;
  int         LauncherSplashScreenHideDelayMs;

  /// Variable used internally
  QProcess                        Process;
  ctkCommandLineParser            Parser;
  QHash<QString, QVariant>        ParsedArgs;
  QString                         ParseError;
  QString                         DefaultApplicationToLaunch;
  QString                         DefaultLauncherSplashImagePath;
  int                             DefaultLauncherSplashScreenHideDelayMs;
  QString                         DefaultApplicationToLaunchArguments;
  QString                         LauncherName;
  QString                         LauncherDir;
  QStringList                     LauncherSettingSubDirs;
  bool                            ValidSettingsFile;
  QString                         LauncherAdditionalHelpShortArgument;
  QString                         LauncherAdditionalHelpLongArgument;
  QStringList                     LauncherAdditionalNoSplashArguments;
  QStringList                     ListOfPaths;
  QStringList                     ListOfLibraryPaths;
  QHash<QString, QString>         MapOfEnvVars;
  QCoreApplication*               Application;
  bool                            Initialized;
  bool                            DetachApplicationToLaunch;
  QString                         PathSep;
  QString                         LibraryPathVariableName;
  QSharedPointer<QSplashScreen>   SplashScreen;
  QPixmap                         SplashPixmap;

  /// Extra 'application to launch'
  QString                                          ExtraApplicationToLaunchLongArgument;
  QString                                          ExtraApplicationToLaunchShortArgument;
  QString                                          ExtraApplicationToLaunch;
  QString                                          ExtraApplicationToLaunchArguments;
  typedef QHash<QString, QString>                  ExtraApplicationToLaunchProperty;
  QHash<QString, ExtraApplicationToLaunchProperty> ExtraApplicationToLaunchList;
};

#endif
