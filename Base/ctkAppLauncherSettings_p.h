#ifndef __ctkAppLauncherSettings_p_h
#define __ctkAppLauncherSettings_p_h

// Qt includes
#include <QHash>
#include <QFile>
#include <QFileInfo>
#include <QProcessEnvironment>
#include <QSet>
#include <QSettings>
#include <QStringList>

// --------------------------------------------------------------------------
class ctkAppLauncherSettingsPrivate : public QObject
{
  Q_OBJECT
public:
  ctkAppLauncherSettingsPrivate();
  ~ctkAppLauncherSettingsPrivate(){}
  typedef ctkAppLauncherSettingsPrivate Self;

  virtual bool verbose()const;

  QString     LauncherSplashImagePath;
  int         LauncherSplashScreenHideDelayMs;
  bool        LauncherNoSplashScreen;

  /// Variable used internally
  QString                         DefaultApplicationToLaunch;
  QString                         DefaultLauncherSplashImagePath;
  int                             DefaultLauncherSplashScreenHideDelayMs;
  bool                            DefaultLauncherNoSplashScreen;
  QString                         DefaultApplicationToLaunchArguments;

  QString                         LauncherName;
  QString                         LauncherDir;
  QStringList                     LauncherSettingSubDirs;
//  bool                            ValidSettingsFile;
  QString                         OrganizationName;
  QString                         OrganizationDomain;
  QString                         ApplicationName;
  QString                         ApplicationRevision;
  QString                         UserAdditionalSettingsFileBaseName;
  QString                         LauncherAdditionalHelpShortArgument;
  QString                         LauncherAdditionalHelpLongArgument;
  QStringList                     LauncherAdditionalNoSplashArguments;
  QStringList                     ListOfPaths;
  QStringList                     ListOfLibraryPaths;
  QSet<QString>                   AdditionalPathVariables;
  QHash<QString, QString>         MapOfEnvVars;
//  QCoreApplication*               Application;
  bool                            Initialized;
//  bool                            DetachApplicationToLaunch;
  QString                         PathSep;
  QString                         LibraryPathVariableName;
//  QSharedPointer<QSplashScreen>   SplashScreen;
//  QScopedPointer<QPixmap>         SplashPixmap;
  QProcessEnvironment             SystemEnvironment;

  /// Extra 'application to launch'
  QString                                          ExtraApplicationToLaunchLongArgument;
  QString                                          ExtraApplicationToLaunchShortArgument;
//  QString                                          ExtraApplicationToLaunch;
//  QString                                          ExtraApplicationToLaunchArguments;
  typedef QHash<QString, QString>                  ExtraApplicationToLaunchProperty;
  QHash<QString, ExtraApplicationToLaunchProperty> ExtraApplicationToLaunchList;

};

#endif
