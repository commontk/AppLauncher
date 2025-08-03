#ifndef __ctkSettingsHelper_h
#define __ctkSettingsHelper_h

// Qt includes
#include <QHash>
#include <QString>

// CTK includes
#include "CTKAppLauncherLibExport.h"

class QSettings;
class QStringList;

namespace ctk {

/// Read list of value stored in an array into a QStringList
QStringList CTKAPPLAUNCHERLIB_EXPORT readArrayValues(
                      QSettings& settings, const QString& arrayName, const QString fieldName);

/// Read list of value stored in a group into a QHash<QString, QString>
QHash<QString, QString> CTKAPPLAUNCHERLIB_EXPORT readKeyValuePairs(
                      QSettings& settings, const QString& groupName);

/// Write QStringList
void CTKAPPLAUNCHERLIB_EXPORT writeArrayValues(
                      QSettings& settings, const QStringList& values,
                      const QString& arrayName, const QString fieldName);

/// Write QHash<QString, QString>
void CTKAPPLAUNCHERLIB_EXPORT writeKeyValuePairs(
                        QSettings& settings,
                        const QHash<QString, QString>& map, const QString& groupName);

} // end of ctk namespace

#endif
