#ifndef __ctkAppLauncherSettings_h
#define __ctkAppLauncherSettings_h

// Qt includes
#include <QObject>
#include <QHash>

// CTK includes
#include "CTKAppLauncherLibExport.h"

class ctkAppLauncherSettingsPrivate;

///
/// \brief The CTKAppLauncherSettings class provides an interface for parsing
/// settings file referencing environment variables.
///
/// Settings file format
/// --------------------
///
/// A settings file is expected to be formatted as an INI file where
/// the following groups and keys are recognized:
///
/// \code
/// [General]
/// additionalPathVariables=PYTHONPATH,QT_PLUGIN_PATH
///
/// [Application]
/// revision=0.1
/// name=AwesomeApp
/// organizationDomain=kitware.com
/// organizationName=Kitware
///
/// [LibraryPaths]
/// 1\path=/path/to/lib_dir_1
/// 2\path=/path/to/lib_dir_2
/// size=2
///
/// [Paths]
/// 1\path=/path/to/dir_1
/// 2\path=/path/to/dir_2
/// size=2
///
/// [EnvironmentVariables]
/// FOO=BAR
/// NUMBER=42
///
/// [PYTHONPATH]
/// 1\path=/path/to/python-package-1
/// 2\path=/path/to/python-package-2
/// size=2
///
/// [QT_PLUGIN_PATH]
/// 1\path=/path/to/qt-plugin-1
/// 2\path=/path/to/qt-plugin-2
/// size=2
///
/// \endcode
///
/// \note Having other groups and keys is valid, they are simply ignored.
///
/// Special string expansion
/// ------------------------
///
/// The following special strings are expanded:
///
/// Special string                    | Description
/// ----------------------------------|-------------------------------------------------------
/// &lt;APPLAUNCHER_DIR&gt;           | Replaced with value set using setLauncherDir()
/// &lt;APPLAUNCHER_NAME&gt;          | Replaced with value set using setLauncherName()
/// &lt;APPLAUNCHER_SETTINGS_DIR&gt;  | Replaced with the absolute path of the settings file where the special string is used.
/// &lt;PATHSEP&gt;                   | Replaced by ":" on unix and ";" on windows
/// &lt;env:VARNAME&gt;               | If any, with corresponding system environment variable
///
/// Additional User Settings
/// ------------------------
///
/// If a group named `Application` having at least the keys `organizationDomain`,
/// `organizationName`, `name` is found in the main setting file given to readSettings(const QString&),
/// then an additional setting file is automatically parsed.
///
/// An optional `revision` key can also be specified.
///
/// First the launcher looks for the user settings file within &lt;APPLAUNCHER_DIR&gt;:
///
///   <APPLAUNCHER_DIR>/<organizationDir>/<ApplicationName>(-<revision>).ini
///
/// If the file is not found there then the launcher looks for it in the Qt user specific settings directory
/// (corresponding to \c QSettings::UserScope):
///
///   /path/to/user/settings/<organizationDir>/<ApplicationName>(-<revision>).ini
///
/// Settings values found in the additional settings file are merged with the
/// one already found in the main settings. For `Paths`, `LibraryPaths` or any
/// other path variables, the values found in the additional launcher settings
/// are prepended.
///
/// Example of `Application` group:
///
/// \code
/// [Application]
/// revision=0.1
/// name=AwesomeApp
/// organizationDomain=kitware.com
/// organizationName=Kitware
/// \endcode
///
/// Usage
/// -----
///
/// \code
/// // Setting these is required to ensure lookup of additional user settings
/// QSettings::setDefaultFormat(QSettings::IniFormat);
/// QApplication::setOrganizationDomain("kitware.com");
/// QApplication::setOrganizationName("kitware");
/// QApplication::setApplicationName("AwesomeApp");
///
/// ctkAppLauncherSettings appLauncherSettings;
///
/// // Set launcher directory and name to ensure the expansion of special strings
/// // work as expected.
/// appLauncherSettings.setLauncherDir("/path/to");
/// appLauncherSettings.setLauncherName("AwesomeApp");
///
/// // Read main settings file
/// appLauncherSettings.readSettings("/path/to/AwesomeAppLauncherSetting.ini");
///
/// // Get values (read from both the main settings file and the additional one).
/// qDebug() << appLauncherSettings.pathsEnvVars().value("PATH");
/// qDebug() << appLauncherSettings.pathsEnvVars().value("LD_LIBRARY_PATH");
/// qDebug() << appLauncherSettings.pathsEnvVars().value("PYTHONPATH");
/// qDebug() << appLauncherSettings.envVars().value("FOO");
/// // or
/// qDebug() << appLauncherSettings.paths();
/// qDebug() << appLauncherSettings.libraryPaths();
/// qDebug() << appLauncherSettings.additionalPathsVars().value("PYTHONPATH");
/// qDebug() << appLauncherSettings.envVars().value("FOO");
/// \endcode
///
class CTKAPPLAUNCHERLIB_EXPORT ctkAppLauncherSettings : public QObject
{
  Q_OBJECT
public:
  typedef ctkAppLauncherSettings Self;
  typedef QObject Superclass;

  ctkAppLauncherSettings(QObject* parentObject = 0);
  ~ctkAppLauncherSettings();

  /// \brief Read main settings file.
  ///
  /// Return False if it failed to read the settings file. Failure reason
  /// can be retrieved using readSettingsError().
  ///
  /// \sa readSettingsError()
  bool readSettings(const QString& fileName);

  /// \brief Return last readSettings() error description if any.
  ///
  /// \sa readSettings()
  QString readSettingsError() const;

  QString additionalSettingsFilePath() const;
  void setAdditionalSettingsFilePath(const QString& filePath);

  QStringList additionalSettingsExcludeGroups() const;
  void setAdditionalSettingsExcludeGroups(const QStringList& excludeGroups);

  /// Get list of library paths associated with the \c LibraryPaths group.
  ///
  /// \sa ctkAppLauncherSettingsPrivate::expandValue(const QString& value)
  QStringList libraryPaths(bool expand = true)const;

  /// Get list of paths associated with the \c Paths group.
  ///
  /// By default, placeholder strings are expanded and relative paths are updated
  /// prepending the launcher directory.
  ///
  /// \sa ctkAppLauncherSettingsPrivate::expandValue(const QString& value)
  /// \sa launcherDir()
  QStringList paths(bool expand = true)const;

  /// Get environment variable value associated with \c EnvironmentVariables
  /// group.
  ///
  /// By default, placeholder strings are expanded and relative paths are updated
  /// prepending the launcher directory.
  ///
  /// \sa envVars(bool expand)
  /// \sa ctkAppLauncherSettingsPrivate::expandValue(const QString& value)
  /// \sa launcherDir()
  QString envVar(const QString& variableName, bool expand = true) const;

  /// Get list of environment variables associated with \c EnvironmentVariables
  /// group.
  ///
  /// By default, placeholder strings are expanded and relative paths are updated
  /// prepending the launcher directory.
  ///
  /// \sa envVar(const QString& variableName, bool expand)
  /// \sa ctkAppLauncherSettingsPrivate::expandValue(const QString& value)
  /// \sa launcherDir()
  QHash<QString, QString> envVars(bool expand = true) const;

  /// \brief Get dictionary of all list of paths.
  ///
  /// These include list of paths associated with:
  ///
  /// * \c General/additionalPathVariables group (see additionalPathsVars()).
  ///
  /// * \c LibraryPaths group (see libraryPaths()).
  ///
  /// * \c Paths group (see paths()).
  ///
  /// Depending on the platform, list associated with the \c LibraryPaths and \c Paths
  /// groups are mapped with different environment variable names:
  ///
  /// Variable name         | Linux           | MacOSX          | Windows
  /// ----------------------|-----------------|-----------------|--------------------------|
  /// `LD_LIBRARY_PATH`     | libraryPaths()  | NA              | NA                       |
  /// `DYLD_LIBRARY_PATH`   | NA              | libraryPaths()  | NA                       |
  /// `PATH`                | paths()         | paths()         | paths() + libraryPaths() |
  ///
  /// By default, placeholder strings are expanded and relative paths are updated
  /// prepending the launcher directory.
  ///
  /// \sa ctkAppLauncherSettingsPrivate::expandValue(const QString& value)
  /// \sa launcherDir()
  /// \sa additionalPathsVars(bool expand)
  /// \sa libraryPaths(bool expand)
  /// \sa paths(bool expand)
  /// \sa libraryPathVariableName()
  ///
  QHash<QString, QStringList> pathsEnvVars(bool expand = true) const;

  /// \brief Get paths associated with \a variableName.
  ///
  /// The returned list corresponds to the path list identified by one of
  /// the variable associated with \c General/additionalPathVariables.
  ///
  /// By default, placeholder strings are expanded and relative paths are updated
  /// prepending the launcher directory.
  ///
  /// \sa ctkAppLauncherSettingsPrivate::expandValue(const QString& value)
  /// \sa launcherDir()
  QStringList additionalPaths(const QString& variableName, bool expand = true) const;

  /// \brief Get dictionary of path list associated with \c General/additionalPathVariables.
  ///
  /// By default, placeholder strings are expanded and relative paths are updated
  /// prepending the launcher directory.
  ///
  /// \sa additionalPaths(const QString& variableName, bool expand)
  /// \sa ctkAppLauncherSettingsPrivate::expandValue(const QString& value)
  /// \sa launcherDir()
  QHash<QString, QStringList> additionalPathsVars(bool expand = true) const;

  /// \brief Get current platform path separator.
  ///
  /// Platform     | Path separator
  /// -------------|---------------
  /// Unix         | `:`
  /// Windows      | `;`
  ///
  QString pathSep() const;

  /// \brief Get current platform library path variable name.
  ///
  /// Platform     | Variable name
  /// -------------|--------------------
  /// Linux        | `LD_LIBRARY_PATH`
  /// MacOSX       | `DYLD_LIBRARY_PATH`
  /// Windows      | `PATH`
  ///
  QString libraryPathVariableName() const;

  /// \brief Get path variable name.
  QString pathVariableName() const;

  /// \brief Return location of the existing user specific additional settings file.
  ///
  /// The location of the additional settings file is first looked for at path:
  /// \c <APPLAUNCHER_DIR>/<organizationDir>/<ApplicationName>(-<revision>).ini
  /// and if it is not found there then at path:
  /// \c path/to/settings/<organizationDir>/<ApplicationName>(-<revision>).ini
  /// If the settings file does NOT exist, an empty string will be returned.
  ///
  /// \sa readSettings(const QString&)
  /// \sa additionalSettingsDir()
  QString findUserAdditionalSettings()const;

  /// \brief Return location of user specific additional settings directory.
  ///
  /// The directory is the location where an existing user specific additional settings file
  /// is found using findUserAdditionalSettings(). If no such file is found then
  /// default location is returned: \c path/to/settings/<organizationDir>
  QString userAdditionalSettingsDir()const;

  /// \brief Get organization subdirectory name determined from organization domain
  /// or name determined according to QSettings conventions.
  ///
  /// On Windows and Linux: QCoreApplication::organizationName() (if undefined then QCoreApplication::organizationDomain()).
  /// On macOS: QCoreApplication::organizationDomain() (if undefined then QCoreApplication::organizationName()).
  QString organizationDir()const;

  /// \brief Set/Get launcher directory.
  ///
  /// This is used to replace \c &lt;APPLAUNCHER_DIR&gt; with launcherDir()
  /// when expanding variables.
  QString launcherDir() const;
  void setLauncherDir(const QString& dir);

  /// \brief Get launcher settings directory.
  ///
  /// Return the directory used to expand \c &lt;APPLAUNCHER_SETTINGS_DIR&gt; variable.
  QString launcherSettingsDir() const;

  /// \brief Set/Get launcher name.
  ///
  /// This is used to replace \c &lt;APPLAUNCHER_NAME&gt; with launcherName()
  /// when expanding variables.
  QString launcherName() const;
  void setLauncherName(const QString& name);

protected:
  ctkAppLauncherSettings(ctkAppLauncherSettingsPrivate* pimpl, QObject* parentObject);
  QScopedPointer<ctkAppLauncherSettingsPrivate> d_ptr;

private:
  Q_DECLARE_PRIVATE(ctkAppLauncherSettings)
  Q_DISABLE_COPY(ctkAppLauncherSettings)
};

#endif
