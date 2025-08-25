

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
#include <ctkAppLauncherEnvironment.h>
#include <ctkAppLauncherSettings.h>

// CTKAppLauncherTesting includes
#include <ctkAppLauncherTestingHelper.h>

// STD includes
#include <cstdlib>

//----------------------------------------------------------------------------
int checkReadArrayValues();
int checkReadSettingsWithoutExpand();
int checkReadSettingsWithExpand();
int checkReadAdditionalSettingsWithExpand();
int checkEnvironment(bool withLauncher);

//----------------------------------------------------------------------------
int main(int argc, char*[])
{
  CHECK_EXIT_SUCCESS(checkReadArrayValues());
  CHECK_EXIT_SUCCESS(checkReadSettingsWithoutExpand());
  CHECK_EXIT_SUCCESS(checkReadSettingsWithExpand());
  CHECK_EXIT_SUCCESS(checkReadAdditionalSettingsWithExpand());
  CHECK_EXIT_SUCCESS(checkEnvironment(argc > 1));

  return EXIT_SUCCESS;
}

//----------------------------------------------------------------------------
int checkReadArrayValues()
{
  QSettings settings("settings-for-read-array-values-test.ini", QSettings::IniFormat);
  if (!QFile(settings.fileName()).exists())
  {
    qWarning() << "Line" << __LINE__ << __FILE__ << "\n"
               << "Settings file" << settings.fileName() << "does not exist";
    return EXIT_FAILURE;
  }

  CHECK_QSTRINGLIST( //
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

  CHECK_QSTRINGLIST( //
    appLauncherSettings.paths(/* expand= */ false),
    QStringList() //
      << "<APPLAUNCHER_DIR>/cow/<APPLAUNCHER_NAME>"
      << "/path/to/pig-<env:BOTH>"
      << "/path/to/<env:PET>"
      << "<APPLAUNCHER_REGULAR_SETTINGS_DIR>/sheep/<APPLAUNCHER_NAME>"
      << "relative-path/sheep/<APPLAUNCHER_NAME>"
    );

  CHECK_QSTRINGLIST( //
    appLauncherSettings.libraryPaths(/* expand= */ false),
    QStringList() //
      << "/path/to/libA"
      << "<APPLAUNCHER_DIR>/libB"
      << "/path/to/libC-<env:PET>"
      << "<APPLAUNCHER_REGULAR_SETTINGS_DIR>/libC"
      << "relative-path/libC"
    );

  CHECK_QSTRING( //
    appLauncherSettings.envVar("BAR", /* expand= */ false),
    "ASSOCIATION"
    );

  CHECK_QSTRING( //
    appLauncherSettings.envVar("PET", /* expand= */ false),
    "dog"
    );

  CHECK_QSTRING( //
    appLauncherSettings.envVar("BOTH", /* expand= */ false),
    "cat-and-<env:PET>"
    );

  CHECK_QSTRING( //
    appLauncherSettings.envVar("PLACEHOLDER", /* expand= */ false),
    "<APPLAUNCHER_DIR>-<APPLAUNCHER_NAME>"
    );

  CHECK_QSTRING( //
    appLauncherSettings.envVar("SETTINGSPLACEHOLDER", /* expand= */ false),
    "<APPLAUNCHER_SETTINGS_DIR>-<APPLAUNCHER_NAME>"
    );

#if defined(Q_OS_WIN32)
  CHECK_QSTRING( //
    appLauncherSettings.envVar("PYTHONPATH", /* expand= */ false),
    "<APPLAUNCHER_DIR>/lib/python/site-packages;/path/to/site-packages-2;<APPLAUNCHER_REGULAR_SETTINGS_DIR>/lib/python/site-packages-settings;relative-path/to/site-packages-3"
    );

  CHECK_QSTRING( //
    appLauncherSettings.envVar("QT_PLUGIN_PATH", /* expand= */ false),
    "<APPLAUNCHER_DIR>/libexec/qt;<APPLAUNCHER_DIR>/libexec/<env:BAR>;<APPLAUNCHER_REGULAR_SETTINGS_DIR>/libexec-settings/<env:BAR>;relative-path/libexec-settings/<env:BAR>"
    );
#else
  CHECK_QSTRING( //
    appLauncherSettings.envVar("PYTHONPATH", /* expand= */ false),
    "<APPLAUNCHER_DIR>/lib/python/site-packages:/path/to/site-packages-2:<APPLAUNCHER_REGULAR_SETTINGS_DIR>/lib/python/site-packages-settings:relative-path/to/site-packages-3"
    );

  CHECK_QSTRING( //
    appLauncherSettings.envVar("QT_PLUGIN_PATH", /* expand= */ false),
    "<APPLAUNCHER_DIR>/libexec/qt:<APPLAUNCHER_DIR>/libexec/<env:BAR>:<APPLAUNCHER_REGULAR_SETTINGS_DIR>/libexec-settings/<env:BAR>:relative-path/libexec-settings/<env:BAR>"
    );
#endif

  CHECK_QSTRINGLIST( //
    appLauncherSettings.additionalPaths("PYTHONPATH", /* expand= */ false),
    QStringList() //
      << "<APPLAUNCHER_DIR>/lib/python/site-packages"
      << "/path/to/site-packages-2"
      << "<APPLAUNCHER_REGULAR_SETTINGS_DIR>/lib/python/site-packages-settings"
      << "relative-path/to/site-packages-3"
    );

  CHECK_QSTRINGLIST( //
    appLauncherSettings.additionalPaths("QT_PLUGIN_PATH", /* expand= */ false),
    QStringList() //
      << "<APPLAUNCHER_DIR>/libexec/qt"
      << "<APPLAUNCHER_DIR>/libexec/<env:BAR>"
      << "<APPLAUNCHER_REGULAR_SETTINGS_DIR>/libexec-settings/<env:BAR>"
      << "relative-path/libexec-settings/<env:BAR>"
    );

  //
  // pathsEnvVars
  //

  QHash<QString, QStringList> pathsEnvVars =
      appLauncherSettings.pathsEnvVars(/* expand= */ false);

#if defined(Q_OS_WIN32)
  CHECK_QSTRINGLIST( //
    pathsEnvVars.value("Path"),
    QStringList() //
      << "<APPLAUNCHER_DIR>/cow/<APPLAUNCHER_NAME>"
      << "/path/to/pig-<env:BOTH>"
      << "/path/to/<env:PET>"
      << "<APPLAUNCHER_REGULAR_SETTINGS_DIR>/sheep/<APPLAUNCHER_NAME>"
      << "relative-path/sheep/<APPLAUNCHER_NAME>"
      << "/path/to/libA"
      << "<APPLAUNCHER_DIR>/libB"
      << "/path/to/libC-<env:PET>"
      << "<APPLAUNCHER_REGULAR_SETTINGS_DIR>/libC"
      << "relative-path/libC"
    );
#else
  CHECK_QSTRINGLIST( //
    pathsEnvVars.value("PATH"),
    QStringList() //
      << "<APPLAUNCHER_DIR>/cow/<APPLAUNCHER_NAME>"
      << "/path/to/pig-<env:BOTH>"
      << "/path/to/<env:PET>"
      << "<APPLAUNCHER_REGULAR_SETTINGS_DIR>/sheep/<APPLAUNCHER_NAME>"
      << "relative-path/sheep/<APPLAUNCHER_NAME>"
    );

  CHECK_QSTRINGLIST( //
    pathsEnvVars.value(appLauncherSettings.libraryPathVariableName()),
    QStringList() //
      << "/path/to/libA"
      << "<APPLAUNCHER_DIR>/libB"
      << "/path/to/libC-<env:PET>"
      << "<APPLAUNCHER_REGULAR_SETTINGS_DIR>/libC"
      << "relative-path/libC"
    );
#endif

  CHECK_QSTRINGLIST( //
    pathsEnvVars.value("PYTHONPATH"),
    QStringList() //
      << "<APPLAUNCHER_DIR>/lib/python/site-packages"
      << "/path/to/site-packages-2"
      << "<APPLAUNCHER_REGULAR_SETTINGS_DIR>/lib/python/site-packages-settings"
      << "relative-path/to/site-packages-3"
    );

  CHECK_QSTRINGLIST( //
    pathsEnvVars.value("QT_PLUGIN_PATH"),
    QStringList() //
      << "<APPLAUNCHER_DIR>/libexec/qt"
      << "<APPLAUNCHER_DIR>/libexec/<env:BAR>"
      << "<APPLAUNCHER_REGULAR_SETTINGS_DIR>/libexec-settings/<env:BAR>"
      << "relative-path/libexec-settings/<env:BAR>"
    );

#if defined(Q_OS_WIN32)
  int expectedPathsEnvVarsCount = 3;
#else
  int expectedPathsEnvVarsCount = 4;
#endif
  if (pathsEnvVars.count() != expectedPathsEnvVarsCount)
  {
    qWarning() << "Line" << __LINE__ << __FILE__ << "\n"
               << "pathsEnvVars has not the expected number of entries\n"
               << "current:" << pathsEnvVars.count() << "\n"
               << "expected:" << expectedPathsEnvVarsCount << "\n"
               << "current list:" << pathsEnvVars;
    return EXIT_FAILURE;
  }

  return EXIT_SUCCESS;
}

//----------------------------------------------------------------------------
int checkReadSettingsWithExpand()
{
  ctkAppLauncherSettings appLauncherSettings;

  appLauncherSettings.setLauncherDir("/awesome/path/to");
  appLauncherSettings.setLauncherName("AwesomeApp");

  appLauncherSettings.readSettings("launcher-settings.ini");

  QString regularSettingsDir = QFileInfo("launcher-settings.ini").absolutePath();

  CHECK_QSTRINGLIST( //
    appLauncherSettings.paths(),
    QStringList() //
      << "/awesome/path/to/cow/AwesomeApp"
      << "/path/to/pig-cat-and-dog"
      << "/path/to/dog"                                         //
      << QString("%1/sheep/AwesomeApp").arg(regularSettingsDir) //
      << "/awesome/path/to/relative-path/sheep/AwesomeApp");

  CHECK_QSTRINGLIST( //
    appLauncherSettings.libraryPaths(),
    QStringList() //
      << "/path/to/libA"
      << "/awesome/path/to/libB"
      << "/path/to/libC-dog"                        //
      << QString("%1/libC").arg(regularSettingsDir) //
      << "/awesome/path/to/relative-path/libC");

  CHECK_QSTRING( //
    appLauncherSettings.envVar("BAR"),
    "ASSOCIATION"
    );

  CHECK_QSTRING( //
    appLauncherSettings.envVar("PET"),
    "dog"
    );

  CHECK_QSTRING( //
    appLauncherSettings.envVar("BOTH"),
    "cat-and-dog"
    );

  CHECK_QSTRING( //
    appLauncherSettings.envVar("PLACEHOLDER"),
    "/awesome/path/to-AwesomeApp"
    );

  CHECK_QSTRING( //
    appLauncherSettings.envVar("SETTINGSPLACEHOLDER"),
    QString("%1-AwesomeApp").arg(regularSettingsDir)
    );

#if defined(Q_OS_WIN32)
  CHECK_QSTRING( //
    appLauncherSettings.envVar("PYTHONPATH"),
    QString("/awesome/path/to/lib/python/site-packages;/path/to/site-packages-2;%1/lib/python/site-packages-settings;/awesome/path/to/relative-path/to/site-packages-3").arg(regularSettingsDir)
    );

  CHECK_QSTRING( //
    appLauncherSettings.envVar("QT_PLUGIN_PATH"),
    QString("/awesome/path/to/libexec/qt;/awesome/path/to/libexec/ASSOCIATION;%1/libexec-settings/ASSOCIATION;/awesome/path/to/relative-path/libexec-settings/ASSOCIATION").arg(regularSettingsDir)
    );
#else
  CHECK_QSTRING( //
        appLauncherSettings.envVar("PYTHONPATH"),
        QString("/awesome/path/to/lib/python/site-packages:/path/to/site-packages-2:%1/lib/python/site-packages-settings:/awesome/path/to/relative-path/to/site-packages-3").arg(regularSettingsDir)
        );

  CHECK_QSTRING( //
    appLauncherSettings.envVar("QT_PLUGIN_PATH"),
    QString("/awesome/path/to/libexec/qt:/awesome/path/to/libexec/ASSOCIATION:%1/libexec-settings/ASSOCIATION:/awesome/path/to/relative-path/libexec-settings/ASSOCIATION").arg(regularSettingsDir)
    );
#endif

  CHECK_QSTRINGLIST( //
    appLauncherSettings.additionalPaths("PYTHONPATH"),
    QStringList() //
      << "/awesome/path/to/lib/python/site-packages"
      << "/path/to/site-packages-2"                                              //
      << QString("%1/lib/python/site-packages-settings").arg(regularSettingsDir) //
      << "/awesome/path/to/relative-path/to/site-packages-3");

  CHECK_QSTRINGLIST( //
    appLauncherSettings.additionalPaths("QT_PLUGIN_PATH"),
    QStringList() //
      << "/awesome/path/to/libexec/qt"
      << "/awesome/path/to/libexec/ASSOCIATION"                             //
      << QString("%1/libexec-settings/ASSOCIATION").arg(regularSettingsDir) //
      << "/awesome/path/to/relative-path/libexec-settings/ASSOCIATION");

  CHECK_QSTRINGLIST( //
    appLauncherSettings.additionalPathsVars().value("PYTHONPATH"),
    QStringList() //
      << "/awesome/path/to/lib/python/site-packages"
      << "/path/to/site-packages-2"                                              //
      << QString("%1/lib/python/site-packages-settings").arg(regularSettingsDir) //
      << "/awesome/path/to/relative-path/to/site-packages-3");

  CHECK_QSTRINGLIST( //
    appLauncherSettings.additionalPathsVars().value("QT_PLUGIN_PATH"),
    QStringList() //
      << "/awesome/path/to/libexec/qt"
      << "/awesome/path/to/libexec/ASSOCIATION"                             //
      << QString("%1/libexec-settings/ASSOCIATION").arg(regularSettingsDir) //
      << "/awesome/path/to/relative-path/libexec-settings/ASSOCIATION");

  //
  // pathsEnvVars
  //

  QHash<QString, QStringList> pathsEnvVars =
      appLauncherSettings.pathsEnvVars();

#if defined(Q_OS_WIN32)
  CHECK_QSTRINGLIST( //
    pathsEnvVars.value("Path"),
    QStringList() //
      << "/awesome/path/to/cow/AwesomeApp"
      << "/path/to/pig-cat-and-dog"
      << "/path/to/dog" << QString("%1/sheep/AwesomeApp").arg(regularSettingsDir) << "/awesome/path/to/relative-path/sheep/AwesomeApp"
      << "/path/to/libA"
      << "/awesome/path/to/libB"
      << "/path/to/libC-dog"                        //
      << QString("%1/libC").arg(regularSettingsDir) //
      << "/awesome/path/to/relative-path/libC");
#else
  CHECK_QSTRINGLIST( //
    pathsEnvVars.value("PATH"),
    QStringList() //
      << "/awesome/path/to/cow/AwesomeApp"
      << "/path/to/pig-cat-and-dog"
      << "/path/to/dog"                                         //
      << QString("%1/sheep/AwesomeApp").arg(regularSettingsDir) //
      << "/awesome/path/to/relative-path/sheep/AwesomeApp");

  CHECK_QSTRINGLIST( //
    pathsEnvVars.value(appLauncherSettings.libraryPathVariableName()),
    QStringList() //
      << "/path/to/libA"
      << "/awesome/path/to/libB"
      << "/path/to/libC-dog"                        //
      << QString("%1/libC").arg(regularSettingsDir) //
      << "/awesome/path/to/relative-path/libC");
#endif

  CHECK_QSTRINGLIST( //
    pathsEnvVars.value("PYTHONPATH"),
    QStringList() //
      << "/awesome/path/to/lib/python/site-packages"
      << "/path/to/site-packages-2"                                              //
      << QString("%1/lib/python/site-packages-settings").arg(regularSettingsDir) //
      << "/awesome/path/to/relative-path/to/site-packages-3");

  CHECK_QSTRINGLIST( //
    pathsEnvVars.value("QT_PLUGIN_PATH"),
    QStringList() //
      << "/awesome/path/to/libexec/qt"
      << "/awesome/path/to/libexec/ASSOCIATION"                             //
      << QString("%1/libexec-settings/ASSOCIATION").arg(regularSettingsDir) //
      << "/awesome/path/to/relative-path/libexec-settings/ASSOCIATION");

#if defined(Q_OS_WIN32)
  int expectedPathsEnvVarsCount = 3;
#else
  int expectedPathsEnvVarsCount = 4;
#endif
  if (pathsEnvVars.count() != expectedPathsEnvVarsCount)
  {
    qWarning() << "Line" << __LINE__ << __FILE__ << "\n"
               << "pathsEnvVars has not the expected number of entries\n"
               << "current:" << pathsEnvVars.count() << "\n"
               << "expected:" << expectedPathsEnvVarsCount << "\n"
               << "current list:" << pathsEnvVars;
    return EXIT_FAILURE;
  }

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

  bool success = true;
  QString appName;
  QString userAdditionalSettingsFileName =
      createUserAdditionalLauncherSettings("AwesomeAppXXXXXX-0.1", appName, success);
  if (!success)
  {
    return EXIT_FAILURE;
  }

  // Update main settings replacing "AwesomeApp" with "AwesomeAppXXXXXX"
  QString mainSettingsFileName("launcher-settings.ini");
  QString mainSettingsContent = readFile(__LINE__, mainSettingsFileName);
  CHECK_QSTRING_NOT_NULL(mainSettingsContent);
  mainSettingsContent.replace("AwesomeApp", appName);
  CHECK_EXIT_SUCCESS(writeFile(__LINE__, mainSettingsFileName, mainSettingsContent));

  // Generate user additional settings
  QFile userAdditionalSettingsFile(userAdditionalSettingsFileName);
  if (!userAdditionalSettingsFile.open(QIODevice::WriteOnly))
  {
    qWarning() << "Line" << __LINE__ << "- Failed to open user additional settings file" << userAdditionalSettingsFileName;
  }
  QString userAdditionalSettingsContent = readFile(__LINE__, "launcher-user-additional-settings.ini");
  CHECK_QSTRING_NOT_NULL(userAdditionalSettingsContent);
  QTextStream outputStream(&userAdditionalSettingsFile);
  outputStream << userAdditionalSettingsContent;
  userAdditionalSettingsFile.close();

  // Set unique application name used in the remaining of the test
  QCoreApplication::setApplicationName(appName);

  ctkAppLauncherSettings appLauncherSettings;

  appLauncherSettings.setLauncherDir("/awesome/path/to");
  appLauncherSettings.setLauncherName(appName);

  appLauncherSettings.readSettings("launcher-settings.ini");

  QString regularSettingsDir = QFileInfo("launcher-settings.ini").absolutePath();
  QString userAdditionalSettingsDir = QFileInfo(userAdditionalSettingsFileName).absolutePath();

  CHECK_QSTRINGLIST( //
    appLauncherSettings.paths(),
    QStringList() //
      << "/awesome/path/to/fawn"
      << "/path/to/cat-and-dog"
      << "/path/to/Klimt"                                            //
      << QString("%1/osprey").arg(userAdditionalSettingsDir)         //
      << "/awesome/path/to/relative-path/osprey"                     //
      << QString("/awesome/path/to/cow/%1").arg(appName)             //
      << "/path/to/pig-cat-and-dog"                                  //
      << "/path/to/dog"                                              //
      << QString("%1/sheep/%2").arg(regularSettingsDir).arg(appName) //
      << QString("/awesome/path/to/relative-path/sheep/%1").arg(appName));

  CHECK_QSTRINGLIST( //
    appLauncherSettings.libraryPaths(),
    QStringList() //
      << "/path/to/libD"
      << "/awesome/path/to/libE-dog"                       //
      << QString("%1/libF").arg(userAdditionalSettingsDir) //
      << "/awesome/path/to/relative-path/libF"
      << "/path/to/libA"
      << "/awesome/path/to/libB"
      << "/path/to/libC-dog"                        //
      << QString("%1/libC").arg(regularSettingsDir) //
      << "/awesome/path/to/relative-path/libC");

  CHECK_QSTRING( //
    appLauncherSettings.envVar("BAR"),
    "RAB"
    );

  CHECK_QSTRING( //
    appLauncherSettings.envVar("PET"),
    "dog"
    );

  CHECK_QSTRINGLIST( //
    appLauncherSettings.additionalPaths("PYTHONPATH"),
    QStringList() //
      << "/awesome/path/to/lib/python/site-packages"
      << "/awesome/path/to/lib/python/site-packages-3"
      << "/path/to/site-packages-RAB"                                                     //
      << QString("%1/lib/python/site-packages-settings-2").arg(userAdditionalSettingsDir) //
      << "/awesome/path/to/relative-path/lib/python/site-packages-settings-2"
      << "/awesome/path/to/lib/python/site-packages"
      << "/path/to/site-packages-2"                                              //
      << QString("%1/lib/python/site-packages-settings").arg(regularSettingsDir) //
      << "/awesome/path/to/relative-path/to/site-packages-3");

  CHECK_QSTRINGLIST( //
    appLauncherSettings.additionalPathsVars().value("PYTHONPATH"),
    QStringList() //
      << "/awesome/path/to/lib/python/site-packages"
      << "/awesome/path/to/lib/python/site-packages-3"
      << "/path/to/site-packages-RAB"                                                     //
      << QString("%1/lib/python/site-packages-settings-2").arg(userAdditionalSettingsDir) //
      << "/awesome/path/to/relative-path/lib/python/site-packages-settings-2"
      << "/awesome/path/to/lib/python/site-packages"
      << "/path/to/site-packages-2"                                              //
      << QString("%1/lib/python/site-packages-settings").arg(regularSettingsDir) //
      << "/awesome/path/to/relative-path/to/site-packages-3");

  CHECK_QSTRINGLIST( //
    appLauncherSettings.additionalPaths("QT_PLUGIN_PATH"),
    QStringList() //
      << "/awesome/path/to/libexec/qt"
      << "/awesome/path/to/libexec/RAB"                             //
      << QString("%1/libexec-settings/RAB").arg(regularSettingsDir) //
      << "/awesome/path/to/relative-path/libexec-settings/RAB");

  CHECK_QSTRINGLIST( //
    appLauncherSettings.additionalPathsVars().value("QT_PLUGIN_PATH"),
    QStringList() //
      << "/awesome/path/to/libexec/qt"
      << "/awesome/path/to/libexec/RAB"                             //
      << QString("%1/libexec-settings/RAB").arg(regularSettingsDir) //
      << "/awesome/path/to/relative-path/libexec-settings/RAB");

  return EXIT_SUCCESS;
}

//----------------------------------------------------------------------------
int checkEnvironment(bool withLauncher)
{
  QProcessEnvironment systemEnvironment = QProcessEnvironment::systemEnvironment();

  CHECK_BOOL(systemEnvironment.contains("APPLAUNCHER_LEVEL"), withLauncher);

  if (withLauncher)
  {
    CHECK_INT(ctkAppLauncherEnvironment::currentLevel(), 1);
    CHECK_QSTRING(systemEnvironment.value("APPWITHLAUNCHER_ENV_VAR", ""), "set-from-launcher-settings");
  }
  else
  {
    CHECK_INT(ctkAppLauncherEnvironment::currentLevel(), 0);
    CHECK_QSTRING(systemEnvironment.value("APPWITHLAUNCHER_ENV_VAR", ""), "");
  }

  qputenv("APPWITHLAUNCHER_ENV_VAR_ONLY_FROM_EXECUTABLE", "set-only-from-executable");
  qputenv("APPWITHLAUNCHER_ENV_VAR", "set-from-executable");

  systemEnvironment = QProcessEnvironment::systemEnvironment();
  CHECK_QSTRING(systemEnvironment.value("APPWITHLAUNCHER_ENV_VAR", ""), "set-from-executable");

  if (withLauncher)
  {
    CHECK_QSTRING(ctkAppLauncherEnvironment::environment(0).value("APPWITHLAUNCHER_ENV_VAR", ""), "set-from-launcher-env");
    CHECK_QSTRING(ctkAppLauncherEnvironment::environment(0).value("APPWITHLAUNCHER_ENV_VAR_ONLY_FROM_EXECUTABLE", ""), "");

    CHECK_QSTRING(ctkAppLauncherEnvironment::environment(1).value("APPWITHLAUNCHER_ENV_VAR", ""), "set-from-executable");
    CHECK_QSTRING(ctkAppLauncherEnvironment::environment(1).value("APPWITHLAUNCHER_ENV_VAR_ONLY_FROM_EXECUTABLE", ""), "set-only-from-executable");
  }
  else
  {
    CHECK_QSTRING(ctkAppLauncherEnvironment::environment(0).value("APPWITHLAUNCHER_ENV_VAR", ""), "set-from-executable");
    CHECK_QSTRING(ctkAppLauncherEnvironment::environment(0).value("APPWITHLAUNCHER_ENV_VAR_ONLY_FROM_EXECUTABLE", ""), "set-only-from-executable");

    CHECK_QSTRING(ctkAppLauncherEnvironment::environment(1).value("APPWITHLAUNCHER_ENV_VAR", ""), "");
    CHECK_QSTRING(ctkAppLauncherEnvironment::environment(1).value("APPWITHLAUNCHER_ENV_VAR_ONLY_FROM_EXECUTABLE", ""), "");
  }

  return EXIT_SUCCESS;
}
