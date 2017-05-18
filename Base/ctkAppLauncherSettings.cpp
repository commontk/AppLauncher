
// Qt includes
#include <QApplication>
#include <QDir>
#include <QHash>
#include <QFile>
#include <QFileInfo>
#include <QSettings>

// CTK includes
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

  this->SystemEnvironment = QProcessEnvironment::systemEnvironment();
}

// --------------------------------------------------------------------------
QString ctkAppLauncherSettingsPrivate::additionalSettingsDir()const
{
  QFileInfo fileInfo(QSettings().fileName());
  return fileInfo.path();
}

// --------------------------------------------------------------------------
QString ctkAppLauncherSettingsPrivate::findUserAdditionalSettings()const
{
  QString prefix = QFileInfo(QSettings().fileName()).completeBaseName();
  QString suffix;
  if (!this->ApplicationRevision.isEmpty())
    {
    suffix = "-" + this->ApplicationRevision;
    }
  QString fileName =
      QDir(this->additionalSettingsDir()).filePath(QString("%1%2%3.ini").
                                                   arg(prefix).
                                                   arg(this->UserAdditionalSettingsFileBaseName).
                                                   arg(suffix));
  if (QFile::exists(fileName))
    {
    return fileName;
    }
  return QString();
}

// --------------------------------------------------------------------------
bool ctkAppLauncherSettingsPrivate::checkSettings(const QString& fileName, int settingsType)
{
  QString settingsTypeDesc;
  if(settingsType == Self::AdditionalSettings)
    {
    settingsTypeDesc = QLatin1String(" additional");
    }
  if(settingsType == Self::UserAdditionalSettings)
    {
    settingsTypeDesc = QLatin1String(" user additional");
    }

  this->ReadSettingsError = QString();

  // Check if settings file exists
  if (!QFile::exists(fileName))
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
void ctkAppLauncherSettingsPrivate::readPathSettings(QSettings& settings)
{
  // Read PATHs
  this->ListOfPaths = ctk::readArrayValues(settings, "Paths", "path") + this->ListOfPaths;

  // Read LibraryPaths
  this->ListOfLibraryPaths = ctk::readArrayValues(settings, "LibraryPaths", "path") + this->ListOfLibraryPaths;

  // Read additional environment variables
  QHash<QString, QString> mapOfEnvVars = ctk::readKeyValuePairs(settings, "EnvironmentVariables");
  foreach(const QString& envVarName, mapOfEnvVars.keys())
    {
    QString envVarValue = mapOfEnvVars.value(envVarName);
    envVarValue.replace(QString("<env:%1>").arg(envVarName), this->MapOfEnvVars.value(envVarName));
    this->MapOfEnvVars.insert(envVarName, envVarValue);
    }

  // Read additional path environment variables
  this->AdditionalPathVariables.unite(settings.value("additionalPathVariables").toStringList().toSet());
  foreach(const QString& envVarName, this->AdditionalPathVariables)
    {
    if (!envVarName.isEmpty())
      {
      QStringList paths = ctk::readArrayValues(settings, envVarName, "path");
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

// --------------------------------------------------------------------------
QString ctkAppLauncherSettingsPrivate::expandValue(const QString& value) const
{
  QHash<QString, QString> keyValueMap;
  keyValueMap["<APPLAUNCHER_DIR>"] = this->LauncherDir;
  keyValueMap["<APPLAUNCHER_NAME>"] = this->LauncherName;
  keyValueMap["<PATHSEP>"] = this->PathSep;

  QString updatedValue = value;
  foreach(const QString& key, keyValueMap.keys())
    {
    updatedValue.replace(key, keyValueMap.value(key), Qt::CaseInsensitive);
    }
  // Consider environment expression
  QRegExp regex("\\<env\\:([a-zA-Z0-9\\-\\_]+)\\>");
  int pos = 0;
  while ((pos = regex.indexIn(value, pos)) != -1)
    {
    pos += regex.matchedLength();
    Q_ASSERT(regex.captureCount() == 1);
    QString envVarName = regex.cap(1);
    QString envVarValue = QString("<env-NOTFOUND:%1>").arg(envVarName);
    if (this->MapOfEnvVars.contains(envVarName))
      {
      envVarValue = this->MapOfEnvVars.value(envVarName);
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
QString ctkAppLauncherSettings::additionalSettingsDir()const
{
  Q_D(const ctkAppLauncherSettings);
  return d->additionalSettingsDir();
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
bool ctkAppLauncherSettings::readSettings(const QString& fileName)
{
  Q_D(ctkAppLauncherSettings);

  // Read regular settings
  if (!d->checkSettings(fileName, ctkAppLauncherSettingsPrivate::RegularSettings))
    {
    return false;
    }
  QSettings settings(fileName, QSettings::IniFormat);
  d->readUserAdditionalSettingsInfo(settings);
  d->readPathSettings(settings);

  // Read user additional settings
  QString additionalSettingsFileName = this->findUserAdditionalSettings();
  if(additionalSettingsFileName.isEmpty())
    {
    return true;
    }
  if (!d->checkSettings(additionalSettingsFileName, ctkAppLauncherSettingsPrivate::UserAdditionalSettings))
    {
    return false;
    }
  QSettings additionalSettings(additionalSettingsFileName, QSettings::IniFormat);
  d->readPathSettings(additionalSettings);

  return true;
}

// --------------------------------------------------------------------------
QString ctkAppLauncherSettings::readSettingsError() const
{
  Q_D(const ctkAppLauncherSettings);
  return d->ReadSettingsError;
}

// --------------------------------------------------------------------------
QStringList ctkAppLauncherSettings::libraryPaths(bool expand /* = true */)const
{
  Q_D(const ctkAppLauncherSettings);
  QStringList expanded;
  foreach(const QString& path, d->ListOfLibraryPaths)
    {
    expanded << (expand ? d->expandValue(path) : path);
    }
  return expanded;
}

// --------------------------------------------------------------------------
QStringList ctkAppLauncherSettings::paths(bool expand /* = true */)const
{
  Q_D(const ctkAppLauncherSettings);
  QStringList expanded;
  foreach(const QString& path, d->ListOfPaths)
    {
    expanded << (expand ? d->expandValue(path) : path);
    }
  return expanded;
}

// --------------------------------------------------------------------------
QString ctkAppLauncherSettings::envVar(const QString& variableName, bool expand /* = true */) const
{
  Q_D(const ctkAppLauncherSettings);
  QString value = d->MapOfEnvVars.value(variableName);
  value = expand ? d->expandValue(value) : value;

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
QStringList ctkAppLauncherSettings::additionalPaths(const QString& variableName, bool expand /* = true */) const
{
  Q_D(const ctkAppLauncherSettings);
  QStringList expanded;
  foreach(const QString& path, d->MapOfPathVars.value(variableName))
    {
    expanded << (expand ? d->expandValue(path) : path);
    }
  return expanded;
}

// --------------------------------------------------------------------------
QHash<QString, QString> ctkAppLauncherSettings::envVars(bool expand /* = true */) const
{
  Q_D(const ctkAppLauncherSettings);
  QHash<QString, QString> newVars;
  QSet<QString> keys = QSet<QString>::fromList(
        d->MapOfEnvVars.keys() + d->MapOfPathVars.keys());
  foreach(const QString& key, keys)
    {
    newVars.insert(key, this->envVar(key, expand));
    }
  return newVars;
}
