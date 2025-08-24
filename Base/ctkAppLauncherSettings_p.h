#ifndef __ctkAppLauncherSettings_p_h
#define __ctkAppLauncherSettings_p_h

// CTK includes
#include "ctkAppLauncherSettings.h"

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
  Q_DECLARE_PUBLIC(ctkAppLauncherSettings)
protected:
  ctkAppLauncherSettings* q_ptr;
public:
  ctkAppLauncherSettingsPrivate(ctkAppLauncherSettings& object);
  ~ctkAppLauncherSettingsPrivate(){}
  typedef ctkAppLauncherSettingsPrivate Self;

  QString findUserAdditionalSettings()const;

  /// Different type of settings files.
  enum SettingsType
  {
    RegularSettings = 0,    ///< Primary settings file associated with the launcher.
    UserAdditionalSettings, ///< Settings file implicitly associated using application `name`, `organizationName`, `organizationDomain`, and optionally `revision`.
    AdditionalSettings      ///< Settings file explicitly specified using command line argument.
  };
  static QString settingsTypeToString(const SettingsType& settingsType);

  static QString settingsDirPlaceHolder(const SettingsType& settingsType);
  static QString updateSettingDirPlaceHolder(const QString& value, const SettingsType& settingsType);
  static QStringList updateSettingDirPlaceHolder(const QStringList& values, const SettingsType& settingsType);

  /// \brief Relative path is resolved against the launcher directory.
  ///
  /// If the launcher directory is empty, returns \a path.
  QString resolvePath(const QString& path) const;

  /// \brief Expand setting \a value
  ///
  /// The following placeholder strings will be updated:
  /// <ul>
  ///  <li>&lt;APPLAUNCHER_DIR&gt; -> LauncherDir</li>
  ///  <li>&lt;APPLAUNCHER_NAME&gt; -> LauncherName</li>
  ///  <li>&lt;APPLAUNCHER_SETTINGS_DIR&gt; -> LauncherSettingsDir</li>
  ///  <li>&lt;PATHSEP&gt; -> PathSep</li>
  ///  <li>&lt;env:VARNAME&gt; -> If any, expand to corresponding system environment variable</li>
  /// </ul>
  ///
  /// \sa expandPlaceHolders()
  QString expandValue(const QString& value) const;

  QString expandPlaceHolders(const QString& value) const;

  void expandEnvVars(const QStringList& envVarNames);
  QHash<QString, QString> MapOfExpandedEnvVars;

  bool checkSettings(const QString& fileName, int settingsType);

  void readUserAdditionalSettingsInfo(QSettings& settings);

  void readAdditionalSettingsInfo(QSettings& settings);

  void readPathSettings(QSettings& settings, const QStringList& excludeGroups = QStringList());

  QString ReadSettingsError;

//  QString     LauncherSplashImagePath;
//  int         LauncherSplashScreenHideDelayMs;
//  bool        LauncherNoSplashScreen;

  /// Variable used internally
//  QString                         DefaultApplicationToLaunch;
//  QString                         DefaultLauncherSplashImagePath;
//  int                             DefaultLauncherSplashScreenHideDelayMs;
//  bool                            DefaultLauncherNoSplashScreen;
//  QString                         DefaultApplicationToLaunchArguments;


  ///
  /// \brief The ScopedLauncherSettingsDir class provides a convenient way
  /// of selecting the value that should be returned by launcherSettingsDir()
  /// based on the type of setting file being read.
  ///
  class ScopedLauncherSettingsDir
  {
  public:
    ScopedLauncherSettingsDir(ctkAppLauncherSettingsPrivate* launcherSettingsPrivate, const SettingsType& launcherSettingsDirType)
      : LauncherSettingsPrivate(launcherSettingsPrivate)
    {
      this->PreviousLauncherSettingsDirType = this->LauncherSettingsPrivate->LauncherSettingsDirType;
      this->LauncherSettingsPrivate->LauncherSettingsDirType = launcherSettingsDirType;
    }
    ~ScopedLauncherSettingsDir()
    {
      this->LauncherSettingsPrivate->LauncherSettingsDirType = this->PreviousLauncherSettingsDirType;
    }
    ctkAppLauncherSettingsPrivate* LauncherSettingsPrivate;
    SettingsType PreviousLauncherSettingsDirType;
  };

  QString                         LauncherName;
  QString                         LauncherDir;
  QHash<SettingsType, QString>    LauncherSettingsDirs;
  SettingsType                    LauncherSettingsDirType;
//  QStringList                     LauncherSettingSubDirs;
//  bool                            ValidSettingsFile;
  QString                         OrganizationName;
  QString                         OrganizationDomain;
  QString                         ApplicationName;
  QString                         ApplicationRevision;
  QString                         UserAdditionalSettingsFileBaseName;
//  QString                         LauncherAdditionalHelpShortArgument;
//  QString                         LauncherAdditionalHelpLongArgument;
//  QStringList                     LauncherAdditionalNoSplashArguments;
  QString                         AdditionalSettingsFilePath;
  QStringList                     AdditionalSettingsExcludeGroups;
  QStringList                     ListOfPaths;
  QStringList                     ListOfLibraryPaths;
  QSet<QString>                   AdditionalPathVariables;
  QHash<QString, QStringList>     MapOfPathVars;
  QHash<QString, QString>         MapOfEnvVars;
//  QCoreApplication*               Application;
//  bool                            Initialized;
//  bool                            DetachApplicationToLaunch;
  QString                         PathSep;
  QString                         LibraryPathVariableName;
  QString                         PathVariableName;
//  QSharedPointer<QSplashScreen>   SplashScreen;
//  QScopedPointer<QPixmap>         SplashPixmap;
  QProcessEnvironment             SystemEnvironment;
  QStringList                     SystemEnvironmentKeys;

  /// Extra 'application to launch'
//  QString                                          ExtraApplicationToLaunchLongArgument;
//  QString                                          ExtraApplicationToLaunchShortArgument;
//  QString                                          ExtraApplicationToLaunch;
//  QString                                          ExtraApplicationToLaunchArguments;
//  typedef QHash<QString, QString>                  ExtraApplicationToLaunchProperty;
//  QHash<QString, ExtraApplicationToLaunchProperty> ExtraApplicationToLaunchList;

};

#endif
