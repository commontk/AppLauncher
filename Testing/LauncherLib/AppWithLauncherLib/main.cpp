

// Qt includes
#include <QCoreApplication>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QSettings>
#include <QStringList>
#include <QTemporaryFile>
#include <QTextStream>
#include <QtGlobal>

// CTKAppLauncher includes
#include <ctkSettingsHelper.h>
#include <ctkAppLauncherSettings.h>

// STD includes
#include <cstdlib>

//----------------------------------------------------------------------------
// Copied from CTK/Libs/Core/ctkCoreTestingUtilities.{h,cpp,tpp}
template<typename TYPE>
bool CheckList(int line, const QString& description,
               const QList<TYPE>& current, const QList<TYPE>& expected,
               const QString& testName)
{
  QString msg;
  if (current.count() != expected.count())
    {
    qWarning() << "\nLine " << line << " - " << description
               << " : " << testName << " failed"
               << "\nCompared lists have different sizes."
               << "\n\tcurrent size :" << current.count()
               << "\n\texpected size:" << expected.count()
               << "\n\tcurrent:" << current
               << "\n\texpected:" << expected;
    return false;
    }
  for (int idx = 0; idx < current.count(); ++idx)
    {
    if (current.at(idx) != expected.at(idx))
      {
      qWarning() << "\nLine " << line << " - " << description
                 << " : " << testName << " failed"
                 << "\nCompared lists differ at index " << idx
                 << "\n\tcurrent[" << idx << "] :" << current.at(idx)
                 << "\n\texpected[" << idx << "]:" << expected.at(idx)
                 << "\n\tcurrent:" << current
                 << "\n\texpected:" << expected;
      return false;
      }
    }
  return true;
}

//----------------------------------------------------------------------------
// Copied from CTK/Libs/Core/ctkCoreTestingUtilities.{h,cpp,tpp}
bool CheckStringList(int line, const QString& description,
                     const QStringList& current, const QStringList& expected)
{
  return CheckList<QString>(line, description, current, expected, "CheckStringList");
}

//----------------------------------------------------------------------------
// Copied from CTK/Libs/Core/ctkCoreTestingMacros.h
bool CheckString(int line, const QString& description,
                 const char* current, const char* expected, bool errorIfDifferent = true)
{
  QString testName = "CheckString";

  bool different = true;
  if (current == 0 || expected == 0)
    {
    different = !(current == 0 && expected == 0);
    }
  else if(strcmp(current, expected) == 0)
    {
    different = false;
    }
  if(different == errorIfDifferent)
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
// Copied from CTK/Libs/Core/ctkCoreTestingMacros.h
#define CHECK_QSTRINGLIST(actual, expected) \
  { \
  QStringList a = (actual); \
  QStringList e = (expected); \
  if (!CheckStringList(__LINE__,#actual " != " #expected, a, e)) \
    { \
    return EXIT_FAILURE; \
    } \
  }

//----------------------------------------------------------------------------
// Copied from CTK/Libs/Core/ctkCoreTestingMacros.h
#define CHECK_QSTRING(actual, expected) \
  { \
  QString a = (actual); \
  QString e = (expected); \
  if (!CheckString(__LINE__,#actual " != " #expected, qPrintable(a), qPrintable(e))) \
    { \
    return EXIT_FAILURE; \
    } \
  }

//----------------------------------------------------------------------------
#define CHECK_EXIT_SUCCESS(actual) \
  { \
  int a = (actual); \
  if (a != EXIT_SUCCESS) \
    { \
    qWarning() << "\nLine " << __LINE__ << " - " << #actual " != EXIT_SUCCESS" \
             << " : " << "CheckExitSuccess" << "  failed"; \
    return EXIT_FAILURE; \
    } \
  }

//----------------------------------------------------------------------------
#define CHECK_QSTRING_NOT_NULL(actual) \
  { \
  QString a = (actual); \
  if (a.isNull()) \
    { \
    qWarning() << "\nLine " << __LINE__ << " - " << #actual " is Null" \
             << " : " << "CheckQStringNotNull" << "  failed"; \
    return EXIT_FAILURE; \
    } \
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
int checkReadArrayValues();
int checkReadSettingsWithoutExpand();
int checkReadSettingsWithExpand();
int checkReadAdditionalSettingsWithExpand();

//----------------------------------------------------------------------------
int main(int, char*[])
{
  CHECK_EXIT_SUCCESS(checkReadArrayValues());
  CHECK_EXIT_SUCCESS(checkReadSettingsWithoutExpand());
  CHECK_EXIT_SUCCESS(checkReadSettingsWithExpand());
  CHECK_EXIT_SUCCESS(checkReadAdditionalSettingsWithExpand());

  return EXIT_SUCCESS;
}

//----------------------------------------------------------------------------
int checkReadArrayValues()
{
  QSettings settings("settings.ini", QSettings::IniFormat);
  if (!QFile(settings.fileName()).exists())
    {
    qWarning() << "Line" << __LINE__ << __FILE__ << "\n"
               << "Settings file" << settings.fileName() << "does not exist";
    return EXIT_FAILURE;
    }

  CHECK_QSTRINGLIST(
        ctk::readArrayValues(settings, "Paths", "path"),
        QStringList() << "/foo" << "/bar"
        );

  return EXIT_SUCCESS;
}

//----------------------------------------------------------------------------
int checkReadSettingsWithoutExpand()
{
  ctkAppLauncherSettings appLauncherSettings;
  appLauncherSettings.readSettings("launcher-settings.ini");

  CHECK_QSTRINGLIST(
        appLauncherSettings.paths(/* expand= */ false),
        QStringList()
                << "<APPLAUNCHER_DIR>/cow"
                << "/path/to/pig-<env:BOTH>"
                << "/path/to/<env:PET>"
        );

  CHECK_QSTRINGLIST(
        appLauncherSettings.libraryPaths(/* expand= */ false),
        QStringList()
                << "/path/to/libA"
                << "<APPLAUNCHER_DIR>/libB"
                << "/path/to/libC-<env:PET>"
        );

  CHECK_QSTRING(
        appLauncherSettings.envVar("BAR", /* expand= */ false),
        "ASSOCIATION"
        );

  CHECK_QSTRING(
        appLauncherSettings.envVar("PET", /* expand= */ false),
        "dog"
        );

  CHECK_QSTRING(
        appLauncherSettings.envVar("BOTH", /* expand= */ false),
        "cat-and-<env:PET>"
        );

#if defined(Q_OS_WIN32)
  CHECK_QSTRING(
        appLauncherSettings.envVar("PYTHONPATH", /* expand= */ false),
        "<APPLAUNCHER_DIR>/lib/python/site-packages;/path/to/site-packages-2"
        );

  CHECK_QSTRING(
        appLauncherSettings.envVar("QT_PLUGIN_PATH", /* expand= */ false),
        "<APPLAUNCHER_DIR>/libexec/qt;<APPLAUNCHER_DIR>/libexec/<env:BAR>"
        );
#else
  CHECK_QSTRING(
        appLauncherSettings.envVar("PYTHONPATH", /* expand= */ false),
        "<APPLAUNCHER_DIR>/lib/python/site-packages:/path/to/site-packages-2"
        );

  CHECK_QSTRING(
        appLauncherSettings.envVar("QT_PLUGIN_PATH", /* expand= */ false),
        "<APPLAUNCHER_DIR>/libexec/qt:<APPLAUNCHER_DIR>/libexec/<env:BAR>"
        );
#endif

  CHECK_QSTRINGLIST(
        appLauncherSettings.additionalPaths("PYTHONPATH", /* expand= */ false),
        QStringList()
                << "<APPLAUNCHER_DIR>/lib/python/site-packages"
                << "/path/to/site-packages-2"
        );

  CHECK_QSTRINGLIST(
        appLauncherSettings.additionalPaths("QT_PLUGIN_PATH", /* expand= */ false),
        QStringList()
                << "<APPLAUNCHER_DIR>/libexec/qt"
                << "<APPLAUNCHER_DIR>/libexec/<env:BAR>"
        );

  return EXIT_SUCCESS;
}

//----------------------------------------------------------------------------
int checkReadSettingsWithExpand()
{
  ctkAppLauncherSettings appLauncherSettings;

  appLauncherSettings.setLauncherDir("/awesome/path/to");
  appLauncherSettings.setLauncherName("AwesomeApp");

  appLauncherSettings.readSettings("launcher-settings.ini");

  CHECK_QSTRINGLIST(
        appLauncherSettings.paths(),
        QStringList()
                << "/awesome/path/to/cow"
                << "/path/to/pig-cat-and-dog"
                << "/path/to/dog"
        );

  CHECK_QSTRINGLIST(
        appLauncherSettings.libraryPaths(),
        QStringList()
                << "/path/to/libA"
                << "/awesome/path/to/libB"
                << "/path/to/libC-dog"
        );

  CHECK_QSTRING(
        appLauncherSettings.envVar("BAR"),
        "ASSOCIATION"
        );

  CHECK_QSTRING(
        appLauncherSettings.envVar("PET"),
        "dog"
        );

  CHECK_QSTRING(
        appLauncherSettings.envVar("BOTH"),
        "cat-and-dog"
        );

#if defined(Q_OS_WIN32)
  CHECK_QSTRING(
        appLauncherSettings.envVar("PYTHONPATH"),
        "/awesome/path/to/lib/python/site-packages;/path/to/site-packages-2"
        );

  CHECK_QSTRING(
        appLauncherSettings.envVar("QT_PLUGIN_PATH"),
        "/awesome/path/to/libexec/qt;/awesome/path/to/libexec/ASSOCIATION"
        );
#else
  CHECK_QSTRING(
        appLauncherSettings.envVar("PYTHONPATH"),
        "/awesome/path/to/lib/python/site-packages:/path/to/site-packages-2"
        );

  CHECK_QSTRING(
        appLauncherSettings.envVar("QT_PLUGIN_PATH"),
        "/awesome/path/to/libexec/qt:/awesome/path/to/libexec/ASSOCIATION"
        );
#endif

  CHECK_QSTRINGLIST(
        appLauncherSettings.additionalPaths("PYTHONPATH"),
        QStringList()
                << "/awesome/path/to/lib/python/site-packages"
                << "/path/to/site-packages-2"
        );

  CHECK_QSTRINGLIST(
        appLauncherSettings.additionalPaths("QT_PLUGIN_PATH"),
        QStringList()
                << "/awesome/path/to/libexec/qt"
                << "/awesome/path/to/libexec/ASSOCIATION"
        );

  return EXIT_SUCCESS;
}

//----------------------------------------------------------------------------
int checkReadAdditionalSettingsWithExpand()
{
  // Setting these now is required to successfully get the additional settings
  // directory.
  QSettings::setDefaultFormat(QSettings::IniFormat);
  QCoreApplication::setOrganizationDomain("kitware.com");
  QCoreApplication::setOrganizationName("kitware");
  QCoreApplication::setApplicationName("AwesomeApp");

  // Get additional settings directory
  QDir additionalSettingsDir = QFileInfo(QSettings().fileName()).dir();

  // Make setting directory
  if (!QDir().mkpath(additionalSettingsDir.path()))
    {
    qWarning() << "Line" << __LINE__ << "- Failed to create directory" << additionalSettingsDir.path();
    return EXIT_FAILURE;
    }
  // Generate temporary settings file
  QTemporaryFile additionalSettingsFile(additionalSettingsDir.filePath("AwesomeAppXXXXXX-0.1.ini"));
  if (!additionalSettingsFile.open())
    {
    qWarning() << "Line" << __LINE__ << "- Failed to open temporary file" << additionalSettingsFile.fileName();
    return EXIT_FAILURE;
    }

  // Extract unique application name of the form "AwesomeAppXXXXXX"
  QString appName =
      QFileInfo(additionalSettingsFile.fileName()).fileName().split("-").at(0);

  // Update main settings replacing "AwesomeApp" with "AwesomeAppXXXXXX"
  QString mainSettingsFileName("launcher-settings.ini");
  QString mainSettingsContent = readFile(__LINE__, mainSettingsFileName);
  CHECK_QSTRING_NOT_NULL(mainSettingsContent);
  mainSettingsContent.replace("AwesomeApp", appName);
  CHECK_EXIT_SUCCESS(writeFile(__LINE__, mainSettingsFileName, mainSettingsContent));

  // Generate additional settings
  QString additionalSettingsFileName = "launcher-additional-settings.ini";
  QString additionalSettingsContent = readFile(__LINE__, additionalSettingsFileName);
  CHECK_QSTRING_NOT_NULL(additionalSettingsContent);
  QTextStream outputStream(&additionalSettingsFile);
  outputStream << additionalSettingsContent;
  additionalSettingsFile.close();

  // Set unique application name used in the remaining of the test
  QCoreApplication::setApplicationName(appName);

  ctkAppLauncherSettings appLauncherSettings;

  appLauncherSettings.setLauncherDir("/awesome/path/to");
  appLauncherSettings.setLauncherName(appName);

  appLauncherSettings.readSettings("launcher-settings.ini");

  CHECK_QSTRINGLIST(
        appLauncherSettings.paths(),
        QStringList()
                << "/awesome/path/to/fawn"
                << "/path/to/cat-and-dog"
                << "/path/to/Klimt"
                << "/awesome/path/to/cow"
                << "/path/to/pig-cat-and-dog"
                << "/path/to/dog"
        );

  CHECK_QSTRINGLIST(
        appLauncherSettings.libraryPaths(),
        QStringList()
                << "/path/to/libD"
                << "/awesome/path/to/libE-dog"
                << "/path/to/libA"
                << "/awesome/path/to/libB"
                << "/path/to/libC-dog"
        );

  CHECK_QSTRING(
        appLauncherSettings.envVar("BAR"),
        "RAB"
        );

  CHECK_QSTRING(
        appLauncherSettings.envVar("PET"),
        "dog"
        );

#if defined(Q_OS_WIN32)
  CHECK_QSTRING(
        appLauncherSettings.envVar("PYTHONPATH"),
        "/awesome/path/to/lib/python/site-packages;/awesome/path/to/lib/python/site-packages-3;/path/to/site-packages-RAB;/awesome/path/to/lib/python/site-packages;/path/to/site-packages-2"
        );

  CHECK_QSTRING(
        appLauncherSettings.envVar("QT_PLUGIN_PATH"),
        "/awesome/path/to/libexec/qt;/awesome/path/to/libexec/RAB"
        );
#else
  CHECK_QSTRING(
        appLauncherSettings.envVar("PYTHONPATH"),
        "/awesome/path/to/lib/python/site-packages:/awesome/path/to/lib/python/site-packages-3:/path/to/site-packages-RAB:/awesome/path/to/lib/python/site-packages:/path/to/site-packages-2"
        );

  CHECK_QSTRING(
        appLauncherSettings.envVar("QT_PLUGIN_PATH"),
        "/awesome/path/to/libexec/qt:/awesome/path/to/libexec/RAB"
        );
#endif

  CHECK_QSTRINGLIST(
        appLauncherSettings.additionalPaths("PYTHONPATH"),
        QStringList()
                << "/awesome/path/to/lib/python/site-packages"
                << "/awesome/path/to/lib/python/site-packages-3"
                << "/path/to/site-packages-RAB"
                << "/awesome/path/to/lib/python/site-packages"
                << "/path/to/site-packages-2"
        );

  CHECK_QSTRINGLIST(
        appLauncherSettings.additionalPaths("QT_PLUGIN_PATH"),
        QStringList()
                << "/awesome/path/to/libexec/qt"
                << "/awesome/path/to/libexec/RAB"
        );

  return EXIT_SUCCESS;
}
