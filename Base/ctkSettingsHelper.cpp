
// Qt includes
#include <QSettings>
#include <QStringList>

// CTK includes
#include "ctkSettingsHelper.h"

// --------------------------------------------------------------------------
QStringList ctk::readArrayValues(QSettings& settings, const QString& arrayName, const QString fieldName)
{
  Q_ASSERT(!arrayName.isEmpty());
  Q_ASSERT(!fieldName.isEmpty());
  QStringList listOfValues;
  int size = settings.beginReadArray(arrayName);
  for (int i = 0; i < size; ++i)
  {
    settings.setArrayIndex(i);
    listOfValues << settings.value(fieldName).toString();
  }
  settings.endArray();
  return listOfValues;
}

// --------------------------------------------------------------------------
QHash<QString, QString> ctk::readKeyValuePairs(QSettings& settings, const QString& groupName)
{
  Q_ASSERT(!groupName.isEmpty());
  QHash<QString, QString> keyValuePairs;
  settings.beginGroup(groupName);
  foreach (const QString& key, settings.childKeys())
  {
    keyValuePairs[key] = settings.value(key).toString();
  }
  settings.endGroup();
  return keyValuePairs;
}

// --------------------------------------------------------------------------
void ctk::writeArrayValues(QSettings& settings, const QStringList& values, const QString& arrayName, const QString fieldName)
{
  Q_ASSERT(!arrayName.isEmpty());
  Q_ASSERT(!fieldName.isEmpty());
  settings.beginWriteArray(arrayName);
  for (int i = 0; i < values.size(); ++i)
  {
    settings.setArrayIndex(i);
    settings.setValue(fieldName, values.at(i));
  }
  settings.endArray();
}

// --------------------------------------------------------------------------
void ctk::writeKeyValuePairs(QSettings& settings, const QHash<QString, QString>& map, const QString& groupName)
{
  Q_ASSERT(!groupName.isEmpty());
  settings.beginGroup(groupName);
  foreach (const QString& key, map.keys())
  {
    settings.setValue(key, map[key]);
  }
  settings.endGroup();
}
