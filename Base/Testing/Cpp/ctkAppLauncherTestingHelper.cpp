
// Qt includes
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QList>
#include <QSettings>
#include <QTemporaryFile>
#include <QTextStream>

// CTKAppLauncherTesting includes
#include <ctkAppLauncherTestingHelper.h>

//----------------------------------------------------------------------------
bool CheckStringList(int line, const QString& description,
                     const QStringList& current, const QStringList& expected)
{
  QString testName("CheckStringList");
  if (current.count() != expected.count())
  {
    QStringList shorterList(expected);
    QStringList longerList(current);
    QString status("contains extra");
    if (current.count() < expected.count())
    {
      longerList = expected;
      shorterList = current;
      status = "is missing";
    }
    foreach (const QString& name, shorterList)
    {
      longerList.removeOne(name);
    }
    qWarning() << "\nLine " << line << " - " << description
               << " : " << testName << " failed"
               << "\nCompared lists have different sizes."
               << "\n\tcurrent size :" << current.count()
               << "\n\texpected size:" << expected.count()
               << "\n\tcurrent list" << qPrintable(status) << "values:" << longerList;
    return false;
  }
  QStringList sortedCurrent(current);
  sortedCurrent.sort();

  QStringList sortedExpected(expected);
  sortedExpected.sort();

  for (int idx = 0; idx < sortedCurrent.count(); ++idx)
  {
    if (sortedCurrent.at(idx) != sortedExpected.at(idx))
    {
      qWarning() << "\nLine " << line << " - " << description
                 << " : " << testName << " failed"
                 << "\nCompared lists differ at index " << idx
                 << "\n\tcurrent[" << idx << "] :" << sortedCurrent.at(idx)
                 << "\n\texpected[" << idx << "]:" << sortedExpected.at(idx);
      qWarning().nospace()
                 << "\n\tcurrent list values:\n\t\t" << sortedCurrent.join("\n\t\t")
                 << "\n\texpected list values:\n\t\t" << sortedExpected.join("\n\t\t");
      return false;
    }
  }
  return true;
}

//----------------------------------------------------------------------------
// Copied from CTK/Libs/Core/ctkCoreTestingUtilities.{h,cpp,tpp}
bool CheckString(int line, const QString& description,
                 const char* current, const char* expected, bool errorIfDifferent)
{
  QString testName = "CheckString";

  bool different = true;
  if (current == 0 || expected == 0)
  {
    different = !(current == 0 && expected == 0);
  }
  else if (strcmp(current, expected) == 0)
  {
    different = false;
  }
  if (different == errorIfDifferent)
  {
    qWarning() << "\nLine " << line << " - " << description
               << " : " << testName << "  failed"
               << "\n\tcurrent :" << (current ? current : "<null>")
               << "\n\texpected:" << (expected ? expected : "<null>");
    return false;
  }
  return true;
}

//----------------------------------------------------------------------------
// Copied from CTK/Libs/Core/ctkCoreTestingUtilities.{h,cpp,tpp}
bool CheckInt(int line, const QString& description,
              int current, int expected)
{
  return Check<int>(line, description, current, expected, "CheckInt");
}

//----------------------------------------------------------------------------
QString readFile(int line, const QString& filePath)
{
  QFile file(filePath);
  if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
  {
    qWarning() << "Line" << line << "- Failed to open file for reading" << QDir::current().filePath(filePath);
    return QString::null;
  }
  QTextStream stream(&file);
  return stream.readAll();
}

//----------------------------------------------------------------------------
int writeFile(int line, const QString& filePath, const QString& content)
{
  QFile file(filePath);
  if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
  {
    qWarning() << "Line" << line << "- Failed to open file for writing" << QDir::current().filePath(filePath);
    return EXIT_FAILURE;
  }
  QTextStream stream(&file);
  stream << content;
  return EXIT_SUCCESS;
}

//----------------------------------------------------------------------------
QString createUserAdditionalLauncherSettings(const QString& appNameTemplate, QString& appName, bool& ok)
{
  if (!appNameTemplate.contains("XXXXXX"))
  {
    qWarning() << "Line" << __LINE__ << "- Application template name is expected to contain 'XXXXXX'" << appNameTemplate;
    ok = false;
    return QString();
  }

  // Get additional settings directory
  QDir userAdditionalSettingsDir = QFileInfo(QSettings().fileName()).dir();

  // Make setting directory
  if (!QDir().mkpath(userAdditionalSettingsDir.path()))
  {
    qWarning() << "Line" << __LINE__ << "- Failed to create directory" << userAdditionalSettingsDir.path();
    ok = false;
    return QString();
  }
  // Generate temporary settings file
  QTemporaryFile userAdditionalSettingsFile(userAdditionalSettingsDir.filePath(QString("%1.ini").arg(appNameTemplate)));
  userAdditionalSettingsFile.setAutoRemove(false);
  if (!userAdditionalSettingsFile.open())
  {
    qWarning() << "Line" << __LINE__ << "- Failed to open temporary file" << userAdditionalSettingsFile.fileName();
    ok = false;
    return QString();
  }

  // Extract unique application name of the form "AwesomeAppXXXXXX"
  appName = QFileInfo(userAdditionalSettingsFile.fileName()).fileName().split("-").at(0);

  ok = true;
  return userAdditionalSettingsFile.fileName();
}
