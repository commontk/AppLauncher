
// Qt includes
#include <QApplication>
#include <QDir>
#include <QHash>
#include <QFile>
#include <QFileInfo>
#include <QRegularExpression>
#include <QSet>
#include <QSettings>

// CTK includes
#include "ctkAppLauncherEnvironment.h"
#include "ctkAppLauncherSettings.h"
#include "ctkAppLauncherSettings_p.h"
#include "ctkSettingsHelper.h"

// STD includes
#include <iostream>

// --------------------------------------------------------------------------
ctkAppLauncherSettingsPrivate::ctkAppLauncherSettingsPrivate(ctkAppLauncherSettings& object)
  : q_ptr(&object)
{
//  this->LauncherSettingSubDirs << "." << "bin" << "lib";

#if defined(Q_OS_WIN32)
  this->PathSep = ";";
  this->LibraryPathVariableName = "PATH";
#else
  this->PathSep = ":";
# if defined(Q_OS_MAC)
  this->LibraryPathVariableName = "DYLD_LIBRARY_PATH";
# elif defined(Q_OS_LINUX)
  this->LibraryPathVariableName = "LD_LIBRARY_PATH";
# else
  // TODO support solaris?
#  error CTK launcher is not supported on this platform
# endif
#endif

  this->PathVariableName = "PATH";

  this->SystemEnvironment = QProcessEnvironment::systemEnvironment();
  this->SystemEnvironmentKeys = ctkAppLauncherEnvironment::envKeys(this->SystemEnvironment);

  this->LibraryPathVariableName = ctkAppLauncherEnvironment::casedVariableName(
        this->SystemEnvironmentKeys, this->LibraryPathVariableName);

  this->PathVariableName = ctkAppLauncherEnvironment::casedVariableName(
        this->SystemEnvironmentKeys, this->PathVariableName);

  this->LauncherSettingsDirType = Self::RegularSettings;

  this->LauncherSettingsDirs[Self::RegularSettings] = "<APPLAUNCHER_SETTINGS_DIR-NOTFOUND>";
  this->LauncherSettingsDirs[Self::UserAdditionalSettings] = "<APPLAUNCHER_SETTINGS_DIR-NOTFOUND>";
  this->LauncherSettingsDirs[Self::AdditionalSettings] = "<APPLAUNCHER_SETTINGS_DIR-NOTFOUND>";
}

// --------------------------------------------------------------------------
QString ctkAppLauncherSettingsPrivate::findUserAdditionalSettings()const
{
  Q_Q(const ctkAppLauncherSettings);

  QString prefix = QFileInfo(QSettings().fileName()).completeBaseName();
  QString suffix;
  if (!this->ApplicationRevision.isEmpty())
  {
    suffix = "-" + this->ApplicationRevision;
  }

  QStringList candidateUserAdditionalSettingsDirs;

  // Settings may be stored in launcherDir/organizationDir:
  candidateUserAdditionalSettingsDirs << QDir(q->launcherDir()).filePath(q->organizationDir());

  // Settings may be stored in path/to/settings/organizationDir:
  QFileInfo fileInfo(QSettings().fileName());
  candidateUserAdditionalSettingsDirs << fileInfo.path();

  foreach (QString candidateUserAdditionalSettingsDir, candidateUserAdditionalSettingsDirs)
  {
    QString fileName = QDir(candidateUserAdditionalSettingsDir).filePath(QString("%1%2%3.ini").
        arg(prefix).
        arg(this->UserAdditionalSettingsFileBaseName).
        arg(suffix));
    if (QFile::exists(fileName))
    {
      return fileName;
    }
  }

  return QString();
}

// --------------------------------------------------------------------------
QString ctkAppLauncherSettingsPrivate::settingsTypeToString(const SettingsType& settingsType)
{
  if (settingsType == Self::RegularSettings)
  {
    return QLatin1String("RegularSettings");
  }
  else if (settingsType == Self::UserAdditionalSettings)
  {
    return QLatin1String("UserAdditionalSettings");
  }
  else // if (settingsType == Self::AdditionalSettings)
  {
    return QLatin1String("AdditionalSettings");
  }
}

// --------------------------------------------------------------------------
QString ctkAppLauncherSettingsPrivate::settingsDirPlaceHolder(const SettingsType& settingsType)
{
  if (settingsType == Self::RegularSettings)
  {
    return QLatin1String("<APPLAUNCHER_REGULAR_SETTINGS_DIR>");
  }
  else if (settingsType == Self::UserAdditionalSettings)
  {
    return QLatin1String("<APPLAUNCHER_USER_ADDITIONAL_SETTINGS_DIR>");
  }
  else // if (settingsType == Self::AdditionalSettings)
  {
    return QLatin1String("<APPLAUNCHER_ADDITIONAL_SETTINGS_DIR>");
  }
}

// --------------------------------------------------------------------------
QString ctkAppLauncherSettingsPrivate::updateSettingDirPlaceHolder(
    const QString& value, const ctkAppLauncherSettingsPrivate::SettingsType& settingsType)
{
  QString updatedValue = value;
  return updatedValue.replace(QString("<APPLAUNCHER_SETTINGS_DIR>"), Self::settingsDirPlaceHolder(settingsType));
}

// --------------------------------------------------------------------------
QStringList ctkAppLauncherSettingsPrivate::updateSettingDirPlaceHolder(
    const QStringList& values, const ctkAppLauncherSettingsPrivate::SettingsType& settingsType)
{
  QStringList updatedValues;
  foreach (const QString& value, values)
  {
    updatedValues.append(Self::updateSettingDirPlaceHolder(value, settingsType));
  }
  return updatedValues;
}

// --------------------------------------------------------------------------
bool ctkAppLauncherSettingsPrivate::checkSettings(const QString& fileName, int settingsType)
{
  QString settingsTypeDesc;
  if (settingsType == Self::AdditionalSettings)
  {
    settingsTypeDesc = QLatin1String(" additional");
  }
  if (settingsType == Self::UserAdditionalSettings)
  {
    settingsTypeDesc = QLatin1String(" user additional");
  }

  this->ReadSettingsError = QString();

  // Check if settings file exists
  if (fileName.isEmpty() || !QFile::exists(fileName))
  {
    return false;
  }

  if (! (QFile::permissions(fileName) & QFile::ReadOwner) )
  {
    this->ReadSettingsError =
        QString("Failed to read%1 launcher setting file [%2]").arg(settingsTypeDesc).arg(fileName);
    return false;
  }

  // Open settings file ...
  QSettings settings(fileName, QSettings::IniFormat);
  if (settings.status() != QSettings::NoError)
  {
    this->ReadSettingsError =
        QString("Failed to open%1 setting file [%2]").arg(settingsTypeDesc).arg(fileName);
    return false;
  }
  return true;
}

// --------------------------------------------------------------------------
void ctkAppLauncherSettingsPrivate::readUserAdditionalSettingsInfo(QSettings& settings)
{
  QHash<QString, QString> applicationGroup = ctk::readKeyValuePairs(settings, "Application");

  this->UserAdditionalSettingsFileBaseName =
      settings.value("userAdditionalSettingsFileBaseName", "").toString();

  // Read revision, organization and application names
  this->OrganizationName = applicationGroup["organizationName"];
  this->OrganizationDomain = applicationGroup["organizationDomain"];
  this->ApplicationName = applicationGroup["name"];
  this->ApplicationRevision = applicationGroup["revision"];
}

// --------------------------------------------------------------------------
void ctkAppLauncherSettingsPrivate::readAdditionalSettingsInfo(QSettings& settings)
{
  Q_Q(ctkAppLauncherSettings);
  if (settings.contains("additionalSettingsFilePath"))
  {
    q->setAdditionalSettingsFilePath(this->expandValue(settings.value("additionalSettingsFilePath", "").toString()));
  }
  if (settings.contains("additionalSettingsExcludeGroups"))
  {
    this->AdditionalSettingsExcludeGroups = settings.value("additionalSettingsExcludeGroups").toStringList();
  }
}

// --------------------------------------------------------------------------
void ctkAppLauncherSettingsPrivate::readPathSettings(QSettings& settings, const QStringList& excludeGroups)
{
  // Read additional environment variables
  QHash<QString, QString> mapOfEnvVars;
  if (!excludeGroups.contains("EnvironmentVariables"))
  {
    mapOfEnvVars = ctk::readKeyValuePairs(settings, "EnvironmentVariables");
    foreach (const QString& envVarName, mapOfEnvVars.keys())
    {
      this->MapOfEnvVars.insert(envVarName, mapOfEnvVars[envVarName]);
    }

    this->expandEnvVars(mapOfEnvVars.keys());
  }

  // Read PATHs
  if (!excludeGroups.contains("Paths"))
  {
    this->ListOfPaths = Self::updateSettingDirPlaceHolder(
          ctk::readArrayValues(settings, "Paths", "path"), this->LauncherSettingsDirType) + this->ListOfPaths;
  }

  // Read LibraryPaths
  if (!excludeGroups.contains("LibraryPaths"))
  {
    this->ListOfLibraryPaths = Self::updateSettingDirPlaceHolder(
          ctk::readArrayValues(settings, "LibraryPaths", "path"), this->LauncherSettingsDirType) + this->ListOfLibraryPaths;
  }

  // Read additional path environment variables
  if (!excludeGroups.contains("Environment") // additionalPathVariables key is associated with the "Environment" group
      ||
      !excludeGroups.contains("General") // XXX Deprecated: additionalPathVariables key used to be associated with the "General" group
      )
  {
    if (!excludeGroups.contains("General"))
    {
      #if (QT_VERSION >= QT_VERSION_CHECK(5, 14, 0))
      QStringList additionalPathVariablesList = settings.value("additionalPathVariables").toStringList();
      QSet<QString> additionalPathVariablesSet = QSet<QString> (additionalPathVariablesList.begin(), additionalPathVariablesList.end());
      #else
      QSet<QString> additionalPathVariablesSet = settings.value("additionalPathVariables").toStringList().toSet();
      #endif
      this->AdditionalPathVariables.unite(additionalPathVariablesSet); // XXX Deprecated
    }
    if (!excludeGroups.contains("Environment"))
    {
      settings.beginGroup("Environment");
      #if (QT_VERSION >= QT_VERSION_CHECK(5, 14, 0))
      QStringList additionalPathVariablesList = settings.value("additionalPathVariables").toStringList();
      QSet<QString> additionalPathVariablesSet = QSet<QString> (additionalPathVariablesList.begin(), additionalPathVariablesList.end());
      #else
      QSet<QString> additionalPathVariablesSet = settings.value("additionalPathVariables").toStringList().toSet();
      #endif
      this->AdditionalPathVariables.unite(additionalPathVariablesSet);
      settings.endGroup();
    }

    foreach (const QString& envVarName, this->AdditionalPathVariables)
    {
      if (!envVarName.isEmpty())
      {
        QStringList paths = Self::updateSettingDirPlaceHolder(
              ctk::readArrayValues(settings, envVarName, "path"), this->LauncherSettingsDirType);
        if (!paths.empty())
        {
          if (this->MapOfPathVars.contains(envVarName))
          {
            paths.append(this->MapOfPathVars[envVarName]);
          }
          this->MapOfPathVars.insert(envVarName, paths);
        }
      }
    }
  }
}

// --------------------------------------------------------------------------
QString ctkAppLauncherSettingsPrivate::resolvePath(const QString& path) const
{
  QFileInfo fileInfo(path);
  if (!this->LauncherDir.isEmpty() && fileInfo.isRelative())
  {
    return QDir(this->LauncherDir).filePath(path);
  }
  else
  {
    return path;
  }
}

// --------------------------------------------------------------------------
QString ctkAppLauncherSettingsPrivate::expandValue(const QString& value) const
{
  QString updatedValue = this->expandPlaceHolders(value);

  QHash<QString, QString> mapOfEnvVars = this->MapOfExpandedEnvVars;

  // Consider environment expression
  QRegularExpression regex("\\<env\\:([a-zA-Z0-9\\-\\_]+)\\>");
  QRegularExpressionMatchIterator iter = regex.globalMatch(value);
  while (iter.hasNext())
  {
    QRegularExpressionMatch match = iter.next();
    QString envVarName = match.captured(1);
    QString envVarValue = QString("<env-NOTFOUND:%1>").arg(envVarName);
    if (mapOfEnvVars.contains(envVarName))
    {
      envVarValue = mapOfEnvVars.value(envVarName);
    }
    else if (this->SystemEnvironment.contains(envVarName))
    {
      envVarValue = this->SystemEnvironment.value(envVarName);
    }
    updatedValue.replace(QString("<env:%1>").arg(envVarName), envVarValue, Qt::CaseInsensitive);
  }
  return updatedValue;
}

// --------------------------------------------------------------------------
QString ctkAppLauncherSettingsPrivate::expandPlaceHolders(const QString& value) const
{
  Q_Q(const ctkAppLauncherSettings);
  QHash<QString, QString> keyValueMap;
  keyValueMap["<APPLAUNCHER_DIR>"] = this->LauncherDir;
  keyValueMap["<APPLAUNCHER_NAME>"] = this->LauncherName;
  keyValueMap["<APPLAUNCHER_SETTINGS_DIR>"] = q->launcherSettingsDir();
  keyValueMap[this->settingsDirPlaceHolder(Self::RegularSettings)] = this->LauncherSettingsDirs[Self::RegularSettings];
  keyValueMap[this->settingsDirPlaceHolder(Self::UserAdditionalSettings)] = this->LauncherSettingsDirs[Self::UserAdditionalSettings];
  keyValueMap[this->settingsDirPlaceHolder(Self::AdditionalSettings)] = this->LauncherSettingsDirs[Self::AdditionalSettings];
  keyValueMap["<PATHSEP>"] = this->PathSep;

  QString updatedValue = value;
  foreach (const QString& key, keyValueMap.keys())
  {
    updatedValue.replace(key, keyValueMap.value(key), Qt::CaseInsensitive);
  }
  return updatedValue;
}

// --------------------------------------------------------------------------
void ctkAppLauncherSettingsPrivate::expandEnvVars(const QStringList& envVarNames)
{
  QRegularExpression regex("\\<env\\:([a-zA-Z0-9\\-\\_]+)\\>");

  QHash<QString, QString> expanded = this->MapOfEnvVars;

  foreach (const QString& key, this->MapOfEnvVars.keys())
  {
    QString value = this->MapOfEnvVars[key];
    QRegularExpressionMatchIterator iter = regex.globalMatch(value);
    while (iter.hasNext())
    {
      QRegularExpressionMatch match = iter.next();
      QString envVarName = match.captured(1);
      QString envVarValue = QString("<env:%1>").arg(envVarName);
      if (this->MapOfExpandedEnvVars.contains(envVarName))
      {
        envVarValue = this->MapOfExpandedEnvVars[envVarName];
        value.replace(QString("<env:%1>").arg(envVarName), envVarValue, Qt::CaseInsensitive);
      }
      else if (expanded.contains(envVarName) && envVarName != key)
      {
        envVarValue = expanded[envVarName];
        value.replace(QString("<env:%1>").arg(envVarName), envVarValue, Qt::CaseInsensitive);
      }
      else if (this->SystemEnvironment.contains(envVarName))
      {
        value = this->SystemEnvironment.value(envVarName);
      }
      else
      {
        value = QString("<env-NOTFOUND:%1>").arg(envVarName);
      }
    }
    expanded[key] = this->expandPlaceHolders(value);
  }

  // Update only variables explicitly listed in the settings
  foreach (const QString& envVarName, envVarNames)
  {
    this->MapOfExpandedEnvVars[envVarName] = expanded[envVarName];
  }
}

// --------------------------------------------------------------------------
// ctkAppLauncherSettings

// --------------------------------------------------------------------------
ctkAppLauncherSettings::ctkAppLauncherSettings(QObject* parentObject) :
  Superclass(parentObject), d_ptr(new ctkAppLauncherSettingsPrivate(*this))
{
}

//-----------------------------------------------------------------------------
ctkAppLauncherSettings::ctkAppLauncherSettings(
  ctkAppLauncherSettingsPrivate* pimpl, QObject* parentObject)
  : Superclass(parentObject), d_ptr(pimpl)
{
}

// --------------------------------------------------------------------------
ctkAppLauncherSettings::~ctkAppLauncherSettings()
{
}

// --------------------------------------------------------------------------
QString ctkAppLauncherSettings::findUserAdditionalSettings()const
{
  Q_D(const ctkAppLauncherSettings);
  return d->findUserAdditionalSettings();
}

// --------------------------------------------------------------------------
QString ctkAppLauncherSettings::userAdditionalSettingsDir()const
{
  Q_D(const ctkAppLauncherSettings);
  QString userAdditionalSettingsFileName = d->findUserAdditionalSettings();
  if (!userAdditionalSettingsFileName.isEmpty())
  {
    return QFileInfo(userAdditionalSettingsFileName).absolutePath();
  }
  else
  {
    // No user settings file is found, return default location
    QFileInfo fileInfo(QSettings().fileName());
    return fileInfo.path();
  }
}

// --------------------------------------------------------------------------
QString ctkAppLauncherSettings::launcherDir() const
{
  Q_D(const ctkAppLauncherSettings);
  return d->LauncherDir;
}

// --------------------------------------------------------------------------
void ctkAppLauncherSettings::setLauncherDir(const QString& dir)
{
  Q_D(ctkAppLauncherSettings);
  d->LauncherDir = dir;
}

// --------------------------------------------------------------------------
QString ctkAppLauncherSettings::launcherName() const
{
  Q_D(const ctkAppLauncherSettings);
  return d->LauncherName;
}

// --------------------------------------------------------------------------
void ctkAppLauncherSettings::setLauncherName(const QString& name)
{
  Q_D(ctkAppLauncherSettings);
  d->LauncherName = name;
}

// --------------------------------------------------------------------------
QString ctkAppLauncherSettings::launcherSettingsDir() const
{
  Q_D(const ctkAppLauncherSettings);
  return d->LauncherSettingsDirs[d->LauncherSettingsDirType];
}

// --------------------------------------------------------------------------
bool ctkAppLauncherSettings::readSettings(const QString& fileName)
{
  Q_D(ctkAppLauncherSettings);

  // Read regular settings
  if (!d->checkSettings(fileName, ctkAppLauncherSettingsPrivate::RegularSettings))
  {
    return false;
  }

  d->LauncherSettingsDirs[ctkAppLauncherSettingsPrivate::RegularSettings] = QFileInfo(fileName).absolutePath();

  QSettings settings(fileName, QSettings::IniFormat);
  d->readPathSettings(settings);
  d->readUserAdditionalSettingsInfo(settings); // Read info used by "findUserAdditionalSettings()"
  d->readAdditionalSettingsInfo(settings); // Read file path and exclude groups

  // Read user additional settings
  QString userAdditionalSettingsFileName = this->findUserAdditionalSettings();
  if (!userAdditionalSettingsFileName.isEmpty())
  {
    if (!d->checkSettings(userAdditionalSettingsFileName, ctkAppLauncherSettingsPrivate::UserAdditionalSettings))
    {
      return false;
    }
    d->LauncherSettingsDirs[ctkAppLauncherSettingsPrivate::UserAdditionalSettings] = QFileInfo(userAdditionalSettingsFileName).absolutePath();
    ctkAppLauncherSettingsPrivate::ScopedLauncherSettingsDir scopedLauncherSettingsDir(d, ctkAppLauncherSettingsPrivate::UserAdditionalSettings);
    Q_UNUSED(scopedLauncherSettingsDir);
    QSettings userAdditionalSettings(userAdditionalSettingsFileName, QSettings::IniFormat);
    d->readPathSettings(userAdditionalSettings);
  }

  // Read additional settings
  if (!this->additionalSettingsFilePath().isEmpty())
  {
    if (!d->checkSettings(this->additionalSettingsFilePath(), ctkAppLauncherSettingsPrivate::AdditionalSettings))
    {
      return false;
    }
    ctkAppLauncherSettingsPrivate::ScopedLauncherSettingsDir scopedLauncherSettingsDir(d, ctkAppLauncherSettingsPrivate::AdditionalSettings);
    Q_UNUSED(scopedLauncherSettingsDir);
    QSettings additionalSettings(this->additionalSettingsFilePath(), QSettings::IniFormat);
    d->readPathSettings(additionalSettings, this->additionalSettingsExcludeGroups());
  }

  return true;
}

// --------------------------------------------------------------------------
QString ctkAppLauncherSettings::readSettingsError() const
{
  Q_D(const ctkAppLauncherSettings);
  return d->ReadSettingsError;
}

// --------------------------------------------------------------------------
QString ctkAppLauncherSettings::additionalSettingsFilePath() const
{
  Q_D(const ctkAppLauncherSettings);
  return d->AdditionalSettingsFilePath;
}

// --------------------------------------------------------------------------
void ctkAppLauncherSettings::setAdditionalSettingsFilePath(const QString& filePath)
{
  Q_D(ctkAppLauncherSettings);
  if (!filePath.isEmpty())
  {
    d->LauncherSettingsDirs[ctkAppLauncherSettingsPrivate::AdditionalSettings] = QFileInfo(filePath).absolutePath();
  }
  d->AdditionalSettingsFilePath = filePath;
}

// --------------------------------------------------------------------------
QStringList ctkAppLauncherSettings::additionalSettingsExcludeGroups() const
{
  Q_D(const ctkAppLauncherSettings);
  return d->AdditionalSettingsExcludeGroups;
}

// --------------------------------------------------------------------------
void ctkAppLauncherSettings::setAdditionalSettingsExcludeGroups(const QStringList& excludeGroups)
{
  Q_D(ctkAppLauncherSettings);
  d->AdditionalSettingsExcludeGroups = excludeGroups;
}

// --------------------------------------------------------------------------
QStringList ctkAppLauncherSettings::libraryPaths(bool expand /* = true */)const
{
  Q_D(const ctkAppLauncherSettings);
  QStringList expanded;
  foreach (const QString& path, d->ListOfLibraryPaths)
  {
    expanded << (expand ? d->resolvePath(d->expandValue(path)) : path);
  }
  return expanded;
}

// --------------------------------------------------------------------------
QStringList ctkAppLauncherSettings::paths(bool expand /* = true */)const
{
  Q_D(const ctkAppLauncherSettings);
  QStringList expanded;
  foreach (const QString& path, d->ListOfPaths)
  {
    expanded << (expand ? d->resolvePath(d->expandValue(path)) : path);
  }
  return expanded;
}

// --------------------------------------------------------------------------
QString ctkAppLauncherSettings::envVar(const QString& variableName, bool expand /* = true */) const
{
  Q_D(const ctkAppLauncherSettings);
  QString value = expand ? d->MapOfExpandedEnvVars[variableName] : d->MapOfEnvVars[variableName];

  if (d->MapOfPathVars.contains(variableName))
  {
    QStringList paths = this->additionalPaths(variableName, expand);
    QString pathsAsStr = paths.join(d->PathSep);
    if (value.isEmpty())
    {
      value = pathsAsStr;
    }
    else
    {
      value = QString("%1%2%3").arg(pathsAsStr, d->PathSep, value);
    }
  }

  return value;
}

// --------------------------------------------------------------------------
QHash<QString, QString> ctkAppLauncherSettings::envVars(bool expand /* = true */) const
{
  Q_D(const ctkAppLauncherSettings);
  return expand ? d->MapOfExpandedEnvVars : d->MapOfEnvVars;
}

// --------------------------------------------------------------------------
QHash<QString, QStringList> ctkAppLauncherSettings::pathsEnvVars(bool expand /* = true */) const
{
  QHash<QString, QStringList> newVars = this->additionalPathsVars(expand);
#ifdef Q_OS_WIN32
  newVars[this->pathVariableName()] = (this->paths(expand) + this->libraryPaths(expand));
#else
  newVars[this->libraryPathVariableName()] = this->libraryPaths(expand);
  newVars[this->pathVariableName()] = this->paths(expand);
#endif
  return newVars;
}

// --------------------------------------------------------------------------
QStringList ctkAppLauncherSettings::additionalPaths(const QString& variableName, bool expand /* = true */) const
{
  Q_D(const ctkAppLauncherSettings);
  QStringList expanded;
  foreach (const QString& path, d->MapOfPathVars.value(variableName))
  {
    expanded << (expand ? d->resolvePath(d->expandValue(path)) : path);
  }
  return expanded;
}

// --------------------------------------------------------------------------
QHash<QString, QStringList> ctkAppLauncherSettings::additionalPathsVars(bool expand /* = true */) const
{
  Q_D(const ctkAppLauncherSettings);
  QHash<QString, QStringList> newVars;
  foreach (const QString& varName, d->MapOfPathVars.keys())
  {
    newVars.insert(varName, this->additionalPaths(varName, expand));
  }
  return newVars;
}

// --------------------------------------------------------------------------
QString ctkAppLauncherSettings::pathSep() const
{
  Q_D(const ctkAppLauncherSettings);
  return d->PathSep;
}

// --------------------------------------------------------------------------
QString ctkAppLauncherSettings::libraryPathVariableName() const
{
  Q_D(const ctkAppLauncherSettings);
  return d->LibraryPathVariableName;
}

// --------------------------------------------------------------------------
QString ctkAppLauncherSettings::pathVariableName() const
{
  Q_D(const ctkAppLauncherSettings);
  return d->PathVariableName;
}

// --------------------------------------------------------------------------
QString ctkAppLauncherSettings::organizationDir()const
{
  // Logic for deciding between using organizationDoman or organizationName is
  // adopted from qtbase\src\corelib\io\qsettings.cpp.
  QString dir =
#ifdef Q_OS_DARWIN
    QCoreApplication::organizationDomain().isEmpty()
    ? QCoreApplication::organizationName()
    : QCoreApplication::organizationDomain();
#else
    QCoreApplication::organizationName().isEmpty()
    ? QCoreApplication::organizationDomain()
    : QCoreApplication::organizationName();
#endif
  return dir;
}
