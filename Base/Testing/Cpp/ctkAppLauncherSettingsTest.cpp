
// CTKAppLauncher includes
#include <ctkAppLauncherSettings.h>
#include <ctkTest.h>

// CTKAppLauncherTesting includes
#include <ctkAppLauncherTestingHelper.h>

// Qt includes
#include <QTemporaryFile>

// ----------------------------------------------------------------------------
class ctkAppLauncherSettingsTester : public QObject
{
  Q_OBJECT

private slots:
  void testDefaults();
  void testLauncherDir();
  void testLauncherName();
  void testLauncherSettingsDir();
  void testReadSettingsError();
  void testPathSep();
  void testLibraryPathVariableName();
  void testAdditionalSettingsFilePath();
  void testAdditionalSettingsExcludeGroups();
  void testReadSettings();
};

// ----------------------------------------------------------------------------
void ctkAppLauncherSettingsTester::testLauncherDir()
{
  ctkAppLauncherSettings appLauncherSettings;
  QCOMPARE(appLauncherSettings.launcherDir(), QString());

  appLauncherSettings.setLauncherDir("/path/to");
  QCOMPARE(appLauncherSettings.launcherDir(), QString("/path/to"));
}

// ----------------------------------------------------------------------------
void ctkAppLauncherSettingsTester::testLauncherName()
{
  ctkAppLauncherSettings appLauncherSettings;
  QCOMPARE(appLauncherSettings.launcherName(), QString());

  appLauncherSettings.setLauncherName("Foo");
  QCOMPARE(appLauncherSettings.launcherName(), QString("Foo"));
}

// ----------------------------------------------------------------------------
void ctkAppLauncherSettingsTester::testLauncherSettingsDir()
{
  ctkAppLauncherSettings appLauncherSettings;
  QCOMPARE(appLauncherSettings.launcherSettingsDir(), QString("<APPLAUNCHER_SETTINGS_DIR-NOTFOUND>"));
}

// ----------------------------------------------------------------------------
void ctkAppLauncherSettingsTester::testDefaults()
{
}

// ----------------------------------------------------------------------------
void ctkAppLauncherSettingsTester::testReadSettingsError()
{
  ctkAppLauncherSettings appLauncherSettings;
  QCOMPARE(appLauncherSettings.readSettings(""), false);
  QCOMPARE(appLauncherSettings.readSettingsError(), QString());

  QCOMPARE(appLauncherSettings.readSettings("/path/to/invalid"), false);
  QCOMPARE(appLauncherSettings.readSettingsError(), QString());

  // Disable on windows where setting group permission is not supported
  // See http://stackoverflow.com/questions/5021645/qt-setpermissions-not-setting-permisions
#ifndef Q_OS_WIN32
  QTemporaryFile nonreadable("testReadSettingsError");
  QVERIFY(nonreadable.open());
  QFile file(nonreadable.fileName());
  QVERIFY(file.setPermissions(QFile::WriteOwner));
  QCOMPARE(appLauncherSettings.readSettings(nonreadable.fileName()), false);
  QCOMPARE(appLauncherSettings.readSettingsError(), //
           QString("Failed to read launcher setting file [%1]").arg(nonreadable.fileName()));
#endif
}

// ----------------------------------------------------------------------------
void ctkAppLauncherSettingsTester::testPathSep()
{
  ctkAppLauncherSettings appLauncherSettings;
#if defined(Q_OS_WIN32)
  QCOMPARE(appLauncherSettings.pathSep(), QString(";"));
#else
  QCOMPARE(appLauncherSettings.pathSep(), QString(":"));
#endif
}

// ----------------------------------------------------------------------------
void ctkAppLauncherSettingsTester::testLibraryPathVariableName()
{
  ctkAppLauncherSettings appLauncherSettings;
#if defined(Q_OS_WIN32)
  QCOMPARE(appLauncherSettings.libraryPathVariableName(), QString("Path"));
#elif defined(Q_OS_MAC)
  QCOMPARE(appLauncherSettings.libraryPathVariableName(), QString("DYLD_LIBRARY_PATH"));
#elif defined(Q_OS_LINUX)
  QCOMPARE(appLauncherSettings.libraryPathVariableName(), QString("LD_LIBRARY_PATH"));
#else
  QFAIL("Platform not yet supported");
#endif
}

// ----------------------------------------------------------------------------
void ctkAppLauncherSettingsTester::testAdditionalSettingsFilePath()
{
  ctkAppLauncherSettings appLauncherSettings;

  QCOMPARE(appLauncherSettings.additionalSettingsFilePath(), QString());

  appLauncherSettings.setAdditionalSettingsFilePath("");
  QCOMPARE(appLauncherSettings.additionalSettingsFilePath(), QString());

  appLauncherSettings.setAdditionalSettingsFilePath("/path/to/additional-settings");
  QCOMPARE(appLauncherSettings.additionalSettingsFilePath(), QString("/path/to/additional-settings"));
}

// ----------------------------------------------------------------------------
void ctkAppLauncherSettingsTester::testAdditionalSettingsExcludeGroups()
{
  ctkAppLauncherSettings appLauncherSettings;

  QCOMPARE_QSTRINGLIST(appLauncherSettings.additionalSettingsExcludeGroups(), QStringList());

  appLauncherSettings.setAdditionalSettingsExcludeGroups(QStringList());
  QCOMPARE_QSTRINGLIST(appLauncherSettings.additionalSettingsExcludeGroups(), QStringList());

  appLauncherSettings.setAdditionalSettingsExcludeGroups(QStringList() << "General" << "Invalid");
  QCOMPARE_QSTRINGLIST(appLauncherSettings.additionalSettingsExcludeGroups(), QStringList() << "General" << "Invalid");
}

// ----------------------------------------------------------------------------
void ctkAppLauncherSettingsTester::testReadSettings()
{
  //
  // NOTE: More exhaustive test is implemented in Testing/LauncherLib/AppWithLauncherLib
  //

  QSettings::setDefaultFormat(QSettings::IniFormat);
  QCoreApplication::setOrganizationDomain("www.commontk-AppLauncherSettingsTest.org");
  QCoreApplication::setOrganizationName("Common ToolKit AppLauncherSettingsTest");
  // See below for application name

  // regular settings
  QTemporaryFile regularSettingFile("regularSettings");
  regularSettingFile.setAutoRemove(false);
  if (!regularSettingFile.open())
  {
    QFAIL("Failed to open settings file");
  }

  // user additional settings
  bool success = true;
  QString appName;
  QString appRevision = "42";
  QString userAdditionalSettingsFileName =
      createUserAdditionalLauncherSettings(QString("AwesomeAppXXXXXX-%1").arg(appRevision), appName, success);
  QVERIFY(success);

  QCoreApplication::setApplicationName(appName);

  // additional settings
  QVERIFY(QDir().mkpath("additionalSettings"));
  QTemporaryFile additionalSettingFile("additionalSettings/additionalSettings");
  additionalSettingFile.setAutoRemove(false);
  if (!additionalSettingFile.open())
  {
    QFAIL("Failed to open additional settings file");
  }

  // write regular settings
  {
    QTextStream outputStream(&regularSettingFile);
    outputStream //
      << "[General]\n"
      << QString("additionalSettingsFilePath=%1\n").arg(additionalSettingFile.fileName())
      << "[Application]\n"
         "path=/path/to/AwesomeApp\n"
         "organizationDomain=www.commontk-AppLauncherSettingsTest.org\n"
         "organizationName=Common ToolKit AppLauncherSettingsTest\n"
      << QString("name=%1\n").arg(appName) //
      << QString("revision=%1\n").arg(appRevision)
      << "\n"
         "[Environment]\n"
         "additionalPathVariables=EXTRA_PATH\n"
         "\n"
         "[EnvironmentVariables]\n"
         "REGULAR_SETTINGS_OVERRIDE_BY_NONE=RegularSettings\n"
         "REGULAR_SETTINGS_OVERRIDE_BY_USER_ADDITIONAL_SETTINGS=UNEXPECTED\n"
         "REGULAR_SETTINGS_OVERRIDE_BY_ADDITIONAL_SETTINGS=UNEXPECTED\n"
         "APPLAUNCHER_SETTINGS_DIR_IN_REGULAR_SETTINGS=<APPLAUNCHER_SETTINGS_DIR>\n"
         "\n"
         "[Paths]\n"
         "1\\path=<APPLAUNCHER_SETTINGS_DIR>/regular-settings-path\n"
         "2\\path=/path/within/regular-settings\n"
         "3\\path=relative-path/within/regular-settings\n"
         "size=3\n"
         "\n"
         "[LibraryPaths]\n"
         "1\\path=<APPLAUNCHER_SETTINGS_DIR>/regular-settings-librarypath\n"
         "2\\path=/librarypath/within/regular-settings\n"
         "3\\path=relative-librarypath/within/regular-settings\n"
         "size=3\n"
         "\n"
         "[EXTRA_PATH]\n"
         "1\\path=<APPLAUNCHER_SETTINGS_DIR>/regular-settings-extrapath\n"
         "2\\path=/extrapath/within/regular-settings\n"
         "3\\path=relative-extrapath/within/regular-settings\n"
         "size=3\n";

    regularSettingFile.close();
  }

  // write user additional settings
  {
    QFile userAdditionalSettingFile(userAdditionalSettingsFileName);
    QVERIFY(userAdditionalSettingFile.open(QFile::WriteOnly));

    QTextStream outputStream(&userAdditionalSettingFile);
    outputStream //
      << "[EnvironmentVariables]\n"
         "REGULAR_SETTINGS_OVERRIDE_BY_USER_ADDITIONAL_SETTINGS=UserAdditionalSettingsOverride\n"
         "USER_ADDITIONAL_SETTINGS_OVERRIDE_BY_NONE=UserAdditionalSettings-<env:REGULAR_SETTINGS_OVERRIDE_BY_NONE>\n"
         "USER_ADDITIONAL_SETTINGS_OVERRIDE_BY_ADDITIONAL_SETTINGS=UNEXPECTED\n"
         "APPLAUNCHER_SETTINGS_DIR_IN_USER_ADDITIONAL_SETTINGS=<APPLAUNCHER_SETTINGS_DIR>\n"
         "\n"
         "[Paths]\n"
         "1\\path=<APPLAUNCHER_SETTINGS_DIR>/user-additional-settings-path\n"
         "2\\path=/path/within/user-additional-settings\n"
         "3\\path=relative-path/within/user-additional-settings\n"
         "size=3\n"
         "\n"
         "[LibraryPaths]\n"
         "1\\path=<APPLAUNCHER_SETTINGS_DIR>/user-additional-settings-librarypath\n"
         "2\\path=/librarypath/within/user-additional-settings\n"
         "3\\path=relative-librarypath/within/user-additional-settings\n"
         "size=3\n"
         "\n"
         "[EXTRA_PATH]\n"
         "1\\path=<APPLAUNCHER_SETTINGS_DIR>/user-additional-settings-extrapath\n"
         "2\\path=/extrapath/within/user-additional-settings\n"
         "3\\path=relative-extrapath/within/user-additional-settings\n"
         "size=3\n";

  }

  // write additional settings
  {
    QTextStream outputStream(&additionalSettingFile);
    outputStream //
      << "[EnvironmentVariables]\n"
         "REGULAR_SETTINGS_OVERRIDE_BY_ADDITIONAL_SETTINGS=AdditionalSettingsOverride\n"
         "USER_ADDITIONAL_SETTINGS_OVERRIDE_BY_ADDITIONAL_SETTINGS=AdditionalSettingsOverride\n"
         "ADDITIONAL_SETTINGS_OVERRIDE_BY_NONE=AdditionalSettings-<env:REGULAR_SETTINGS_OVERRIDE_BY_NONE>-<env:USER_ADDITIONAL_SETTINGS_OVERRIDE_BY_NONE>\n"
         "APPLAUNCHER_SETTINGS_DIR_IN_ADDITIONAL_SETTINGS=<APPLAUNCHER_SETTINGS_DIR>\n"
         "\n"
         "[Paths]\n"
         "1\\path=<APPLAUNCHER_SETTINGS_DIR>/additional-settings-path\n"
         "2\\path=/path/within/additional-settings\n"
         "3\\path=relative-path/within/additional-settings\n"
         "size=3\n"
         "\n"
         "[LibraryPaths]\n"
         "1\\path=<APPLAUNCHER_SETTINGS_DIR>/additional-settings-librarypath\n"
         "2\\path=/librarypath/within/additional-settings\n"
         "3\\path=relative-librarypath/within/additional-settings\n"
         "size=3\n"
         "\n"
         "[EXTRA_PATH]\n"
         "1\\path=<APPLAUNCHER_SETTINGS_DIR>/additional-settings-extrapath\n"
         "2\\path=/extrapath/within/additional-settings\n"
         "3\\path=relative-extrapath/within/additional-settings\n"
         "size=3\n";

    additionalSettingFile.close();
  }

  ctkAppLauncherSettings appLauncherSettings;
  appLauncherSettings.setLauncherName("AppLauncher");
  appLauncherSettings.setLauncherDir("/path/to");
  appLauncherSettings.readSettings(regularSettingFile.fileName());

  QCOMPARE(appLauncherSettings.launcherSettingsDir(), QFileInfo(regularSettingFile).absolutePath());

  QCOMPARE(appLauncherSettings.envVar("REGULAR_SETTINGS_OVERRIDE_BY_NONE"), QString("RegularSettings"));
  QCOMPARE(appLauncherSettings.envVar("REGULAR_SETTINGS_OVERRIDE_BY_USER_ADDITIONAL_SETTINGS"), QString("UserAdditionalSettingsOverride"));
  QCOMPARE(appLauncherSettings.envVar("REGULAR_SETTINGS_OVERRIDE_BY_ADDITIONAL_SETTINGS"), QString("AdditionalSettingsOverride"));
  QCOMPARE(appLauncherSettings.envVar("USER_ADDITIONAL_SETTINGS_OVERRIDE_BY_NONE"), QString("UserAdditionalSettings-RegularSettings"));
  QCOMPARE(appLauncherSettings.envVar("USER_ADDITIONAL_SETTINGS_OVERRIDE_BY_ADDITIONAL_SETTINGS"), QString("AdditionalSettingsOverride"));
  QCOMPARE(appLauncherSettings.envVar("ADDITIONAL_SETTINGS_OVERRIDE_BY_NONE"), QString("AdditionalSettings-RegularSettings-UserAdditionalSettings-RegularSettings"));

  QString regularSettingsDir = QFileInfo(regularSettingFile.fileName()).absolutePath();
  QCOMPARE(appLauncherSettings.envVar("APPLAUNCHER_SETTINGS_DIR_IN_REGULAR_SETTINGS"), regularSettingsDir);

  QString userAdditionalSettingsDir = QFileInfo(userAdditionalSettingsFileName).absolutePath();
  QCOMPARE(appLauncherSettings.envVar("APPLAUNCHER_SETTINGS_DIR_IN_USER_ADDITIONAL_SETTINGS"), userAdditionalSettingsDir);

  QString additionalSettingsDir = QFileInfo(additionalSettingFile.fileName()).absolutePath();
  QCOMPARE(appLauncherSettings.envVar("APPLAUNCHER_SETTINGS_DIR_IN_ADDITIONAL_SETTINGS"), additionalSettingsDir);

  QCOMPARE_QSTRINGLIST( //
    appLauncherSettings.paths(),
    QStringList() //
      << additionalSettingsDir + "/additional-settings-path" << "/path/within/additional-settings" << "/path/to/relative-path/within/additional-settings"
      << userAdditionalSettingsDir + "/user-additional-settings-path" << "/path/within/user-additional-settings" << "/path/to/relative-path/within/user-additional-settings" //
      << regularSettingsDir + "/regular-settings-path" << "/path/within/regular-settings" << "/path/to/relative-path/within/regular-settings"
    );

  QCOMPARE_QSTRINGLIST( //
    appLauncherSettings.libraryPaths(),
    QStringList() //
      << additionalSettingsDir + "/additional-settings-librarypath" << "/librarypath/within/additional-settings" << "/path/to/relative-librarypath/within/additional-settings"
      << userAdditionalSettingsDir + "/user-additional-settings-librarypath" << "/librarypath/within/user-additional-settings" << "/path/to/relative-librarypath/within/user-additional-settings" //
      << regularSettingsDir + "/regular-settings-librarypath" << "/librarypath/within/regular-settings" << "/path/to/relative-librarypath/within/regular-settings"
    );

  QCOMPARE_QSTRINGLIST( //
    appLauncherSettings.pathsEnvVars().value("EXTRA_PATH"),
    QStringList() //
      << additionalSettingsDir + "/additional-settings-extrapath" << "/extrapath/within/additional-settings" << "/path/to/relative-extrapath/within/additional-settings"
      << userAdditionalSettingsDir + "/user-additional-settings-extrapath" << "/extrapath/within/user-additional-settings" << "/path/to/relative-extrapath/within/user-additional-settings" //
      << regularSettingsDir + "/regular-settings-extrapath" << "/extrapath/within/regular-settings" << "/path/to/relative-extrapath/within/regular-settings"
      );
}

// ----------------------------------------------------------------------------
CTK_TEST_MAIN(ctkAppLauncherSettingsTest)
#include "moc_ctkAppLauncherSettingsTest.cpp"
