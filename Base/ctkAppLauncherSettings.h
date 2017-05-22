#ifndef __ctkAppLauncherSettings_h
#define __ctkAppLauncherSettings_h

// Qt includes
#include <QObject>
#include <QHash>

class ctkAppLauncherSettingsPrivate;

///
/// \brief The CTKAppLauncherSettings class provides an interface for parsing settings file referencing environment
/// variables useful to execute an application and load associated plugins.
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
/// Special string           | Description
/// ------------------------ | -------------
/// &lt;APPLAUNCHER_DIR&gt;  | Replace with value set using setLauncherDir()
/// &lt;APPLAUNCHER_NAME&gt; | Replace with value set using setLauncherName()
/// &lt;PATHSEP&gt;          | Replace by ":" on unix and ";" on windows
/// &lt;env:VARNAME&gt;      | If any, with corresponding system environment variable
///
/// Additional User Settings
/// ------------------------
///
/// If a group named `Application` having at least the keys `organizationDomain`,
/// `organizationName`, `name` is found in the main setting file given to readSettings(const QString&),
/// then an additional setting file located in the Qt user specific settings directory is automatically parsed.
///
/// An optional `revision` key can also be specified.
///
/// Location of additional setting file:
///
///   /path/to/user/settings/<organisationName|organizationDomain>/<ApplicationName>(-<revision>).ini
///
/// The location of the additional settings file corresponds to \c QSettings::UserScope.
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
/// // Set launcher directory and name to ensure the expension of special strings
/// // work as expected.
/// appLauncherSettings.setLauncherDir("/path/to");
/// appLauncherSettings.setLauncherName("AwesomeApp");
///
/// // Read main settings file
/// appLauncherSettings.readSettings("/path/to/AwesomeAppLauncherSetting.ini");
///
/// // Get values (read from both the main settings file and the additional one).
/// qDebug() << appLauncherSettings.paths();
/// qDebug() << appLauncherSettings.libraryPaths();
/// qDebug() << appLauncherSettings.additionalPathsVars().value("PYTHONPATH");
/// qDebug() << appLauncherSettings.envVars().value("FOO");
/// \endcode
///
class ctkAppLauncherSettings : public QObject
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

  /// Get list of library paths associated with the \c LibraryPaths group.
  QStringList libraryPaths(bool expand = true)const;

  /// Get list of paths associated with the \c Paths group.
  QStringList paths(bool expand = true)const;

  /// Get environment variable value associated with \c EnvironmentVariables
  /// group or any path environment variables associated
  /// with \c General/additionalPathVariables.
  ///
  /// Paths associated with \c General/additionalPathVariables are obtained
  /// using additionalPaths(const QString&, bool) and are joined using the
  /// platform specific separator (":" on Unix, ";" on Windows).
  ///
  /// If \a variableName corresponds to both \c EnvironmentVariables
  /// and \c General/additionalPathVariables, the final value is generated
  /// by appending the environment variable to the matching path variable.
  QString envVar(const QString& variableName, bool expand = true) const;

  /// Get list of environment variables associated with \c EnvironmentVariables
  /// group.
  ///
  /// \sa envVar(const QString& variableName, bool expand)
  QHash<QString, QString> envVars(bool expand = true) const;

  /// \brief Get paths associated with \a variableName.
  ///
  /// The returned list corresponds to the path matching one of the variable
  /// associated with \c General/additionalPathVariables.
  QStringList additionalPaths(const QString& variableName, bool expand = true) const;

  /// \brief Get dictionnary of path variable list associated with \c General/additionalPathVariables.
  ///
  /// \sa additionalPaths(const QString& variableName, bool expand)
  QHash<QString, QStringList> additionalPathsVars(bool expand = true) const;

  /// \brief Get current platform path separator.
  ///
  /// Platform     | Path separator
  /// -------------| -------------
  /// Unix         | `:`
  /// Windows      | `;`
  ///
  QString pathSep() const;

  /// Return user specific additional settings file associated with the \c ApplicationOrganization,
  /// \c ApplicationName and \c ApplicationRevision read from the main settings using
  /// readSettings(const QString&).
  ///
  /// The location of the additional settings file is expected to match the following name
  /// and path: \c path/to/settings/<organisationName|organizationDomain>/<ApplicationName>(-<revision>).ini
  /// If the settings file does NOT exist, an empty string will be returned.
  ///
  /// \sa readSettings(const QString&)
  /// \sa additionalSettingsDir()
  QString findUserAdditionalSettings()const;

  /// Return additional settings directory associated with the \a ApplicationOrganization
  /// read from the main settings.
  ///
  /// The location of the additional settings directory is expected to match the following
  /// path: \c path/to/settings/<organisationName|organizationDomain>/
  QString additionalSettingsDir()const;

  /// \brief Set/Get launcher directory.
  ///
  /// This is used to replace \c &lt;APPLAUNCHER_DIR&gt; with launcherDir()
  /// when expanding variables.
  QString launcherDir() const;
  void setLauncherDir(const QString& dir);

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
