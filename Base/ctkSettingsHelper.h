#ifndef __ctkSettingsHelper_h
#define __ctkSettingsHelper_h

// Qt includes
#include <QHash>
#include <QString>

class QSettings;
class QStringList;

namespace ctk {

/// Read list of value stored in an array into a QStringList
QStringList readArrayValues(QSettings& settings, const QString& arrayName, const QString fieldName);

/// Read list of value stored in a group into a QHash<QString, QString>
QHash<QString, QString> readKeyValuePairs(QSettings& settings, const QString& groupName);

/// Write QStringList
void writeArrayValues(QSettings& settings, const QStringList& values,
                      const QString& arrayName, const QString fieldName);

/// Write QHash<QString, QString>
void writeKeyValuePairs(QSettings& settings,
                        const QHash<QString, QString>& map, const QString& groupName);

} // end of ctk namespace

#endif
