
// CTK includes
#include <ctkAppLauncherEnvironment.h>
#include <ctkTest.h>

// Qt includes
#include <QProcessEnvironment>

// STD includes
#include <cstdlib>

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
      return false;
      }
    }
  return true;
}

//----------------------------------------------------------------------------
/// Verifies if actual QStringList is the same as expected.
#define CHECK_QSTRINGLIST(actual, expected) \
  { \
  QStringList a = (actual); \
  QStringList e = (expected); \
  if (!CheckStringList(__LINE__,#actual " != " #expected, a, e)) \
    { \
    QFAIL(""); \
    } \
  }

// ----------------------------------------------------------------------------
class ctkAppLauncherEnvironmentTester: public QObject
{
  Q_OBJECT
  typedef ctkAppLauncherEnvironmentTester Self;

private slots:
  void initTestCase();
  void cleanup();

  void testCurrentLevel_data();
  void testCurrentLevel();

  void testEnvironment_data();
  void testEnvironment();

  void testUpdateCurrentEnvironment();

private:
  void setEnv(const QString& name, const QString& value);
  void unsetEnv(const QString& name);
  static QStringList envKeys(const QProcessEnvironment& env);

  QProcessEnvironment OriginalEnv;
  QSet<QString> VariableNames;
};

// ----------------------------------------------------------------------------
void ctkAppLauncherEnvironmentTester::initTestCase()
{
  this->OriginalEnv = QProcessEnvironment::systemEnvironment();
}

// ----------------------------------------------------------------------------
void ctkAppLauncherEnvironmentTester::cleanup()
{
  // Remove additional variables
  foreach(const QString& varName, this->VariableNames)
    {
    this->unsetEnv(varName);
    }
  // Reset original values
  QStringList originalEnvKeys = Self::envKeys(this->OriginalEnv);
  foreach(const QString& varName, originalEnvKeys)
    {
    qputenv(varName.toLatin1(), this->OriginalEnv.value(varName).toLatin1());
    }
}

// ----------------------------------------------------------------------------
void ctkAppLauncherEnvironmentTester::setEnv(const QString& name, const QString& value)
{
  qputenv(name.toLatin1(), value.toLatin1());
  this->VariableNames.insert(name);
}

// ----------------------------------------------------------------------------
void ctkAppLauncherEnvironmentTester::unsetEnv(const QString& name)
{
#if defined(_MSC_VER)
  qputenv(name.toLatin1(), QString("").toLatin1());
#else
  unsetenv(name.toLatin1());
#endif
}

// ----------------------------------------------------------------------------
QStringList ctkAppLauncherEnvironmentTester::envKeys(const QProcessEnvironment& env)
{
#if QT_VERSION >= 0x040800
  return env.keys();
#else
  QStringList envKeys;
  foreach (const QString& pair, env.toStringList())
    {
    envKeys.append(pair.split("=").first());
    }
  return envKeys;
#endif
}

// ----------------------------------------------------------------------------
void ctkAppLauncherEnvironmentTester::testCurrentLevel_data()
{
  QTest::addColumn<QString>("env_level");
  QTest::addColumn<QString>("expected_env_level");

  QTest::newRow("empty") << "" << "0";
  QTest::newRow("negative") << "-1" << "0";
  QTest::newRow("invalid") << "foo" << "0";
  QTest::newRow("0") << "0" << "0";
  QTest::newRow("1") << "1" << "1";
  QTest::newRow("2") << "2" << "2";
}

// ----------------------------------------------------------------------------
void ctkAppLauncherEnvironmentTester::testCurrentLevel()
{
  QFETCH(QString, env_level);
  QFETCH(QString, expected_env_level);

  this->setEnv("APPLAUNCHER_LEVEL", env_level);

  QCOMPARE(ctkAppLauncherEnvironment::currentLevel(), expected_env_level.toInt());
}

// ----------------------------------------------------------------------------
Q_DECLARE_METATYPE(QProcessEnvironment);

// ----------------------------------------------------------------------------
void ctkAppLauncherEnvironmentTester::testEnvironment_data()
{
  qRegisterMetaType<QProcessEnvironment>("QProcessEnvironment");

  QProcessEnvironment sysEnv = QProcessEnvironment::systemEnvironment();

  QStringList sysEnvKeys;
  foreach (const QString& pair, sysEnv.toStringList())
    {
    if (pair.startsWith("="))
      {
      continue;
      }
    sysEnvKeys.append(pair.split("=").first());
    }

  QTest::addColumn<QProcessEnvironment>("env");
  QTest::addColumn<QProcessEnvironment>("expectedEnv");
  QTest::addColumn<int>("requestedLevel");

  {
  QProcessEnvironment env = sysEnv;
  QProcessEnvironment expectedEnv;
  QTest::newRow("no APPLAUNCHER_LEVEL, requested -1") << env << expectedEnv << -1;
  }

  {
  QProcessEnvironment env = sysEnv;
  QTest::newRow("no APPLAUNCHER_LEVEL, requested 0") << env << env << 0;
  }

  {
  QProcessEnvironment env = sysEnv;
  env.insert("APPLAUNCHER_LEVEL", "-1");
  QProcessEnvironment expectedEnv(env);
  QTest::newRow("invalid APPLAUNCHER_LEVEL, requested 0") << env << expectedEnv << 0;
  }

  {
  QProcessEnvironment env = sysEnv;
  env.insert("APPLAUNCHER_LEVEL", "1");
  env.insert("APPLAUNCHER_0_FOO", "foo-level-0");
  foreach(const QString& varname, sysEnvKeys)
    {
    env.insert(QString("APPLAUNCHER_0_%1").arg(varname), sysEnv.value(varname));
    }

  QProcessEnvironment expectedEnv;
  foreach(const QString& varname, sysEnvKeys)
    {
    expectedEnv.insert(varname, sysEnv.value(varname));
    }
  expectedEnv.insert("FOO", "foo-level-0");

  QTest::newRow("APPLAUNCHER_LEVEL=1, requested 0") << env << expectedEnv << 0;
  }

  {
  QProcessEnvironment env = sysEnv;
  env.insert("APPLAUNCHER_LEVEL", "2");
  env.insert("APPLAUNCHER_0_FOO", "foo-level-0");
  foreach(const QString& varname, sysEnvKeys)
    {
    env.insert(QString("APPLAUNCHER_0_%1").arg(varname), sysEnv.value(varname));
    }
  env.insert("APPLAUNCHER_1_FOO", "foo-level-1");
  foreach(const QString& varname, sysEnvKeys)
    {
    env.insert(QString("APPLAUNCHER_1_%1").arg(varname), sysEnv.value(varname));
    }

  QProcessEnvironment expectedEnv;
  foreach(const QString& varname, sysEnvKeys)
    {
    expectedEnv.insert(varname, sysEnv.value(varname));
    }
  expectedEnv.insert("APPLAUNCHER_LEVEL", "1");
  expectedEnv.insert("APPLAUNCHER_0_FOO", "foo-level-0");
  expectedEnv.insert("FOO", "foo-level-1");
  foreach(const QString& varname, sysEnvKeys)
    {
    expectedEnv.insert(QString("APPLAUNCHER_0_%1").arg(varname), sysEnv.value(varname));
    }

  QTest::newRow("APPLAUNCHER_LEVEL=2, requested 1") << env << expectedEnv << 1;
  }
}

// ----------------------------------------------------------------------------
void ctkAppLauncherEnvironmentTester::testEnvironment()
{
  QFETCH(QProcessEnvironment, env);
  QFETCH(QProcessEnvironment, expectedEnv);
  QFETCH(int, requestedLevel);

  // Update current environment
  foreach(const QString& varName, Self::envKeys(env))
    {
    this->setEnv(varName, env.value(varName));
    }

  QProcessEnvironment requestedEnv =
      ctkAppLauncherEnvironment::environment(requestedLevel);

  CHECK_QSTRINGLIST(requestedEnv.toStringList(), expectedEnv.toStringList())
}

// ----------------------------------------------------------------------------
void ctkAppLauncherEnvironmentTester::testUpdateCurrentEnvironment()
{
  {
  qputenv("SYS_ONLY", "sys-only");
  qputenv("COMMON", "sys-common");
  QProcessEnvironment sysEnv = QProcessEnvironment::systemEnvironment();
  QStringList sysEnvKeys = Self::envKeys(sysEnv);
  QVERIFY(sysEnvKeys.contains("SYS_ONLY"));
  QCOMPARE(sysEnv.value("SYS_ONLY"), QString("sys-only"));
  QVERIFY(sysEnvKeys.contains("COMMON"));
  QCOMPARE(sysEnv.value("COMMON"), QString("sys-common"));
  }

  {
  QProcessEnvironment updatedEnv;
  updatedEnv.insert("UPDATED_ONLY", "updated-only");
  updatedEnv.insert("COMMON", "updated-common");
  ctkAppLauncherEnvironment::updateCurrentEnvironment(updatedEnv);
  }

  {
  QProcessEnvironment sysEnv = QProcessEnvironment::systemEnvironment();
  QStringList sysEnvKeys = Self::envKeys(sysEnv);
  QVERIFY(!sysEnvKeys.contains("SYS_ONLY"));
  QVERIFY(sysEnvKeys.contains("COMMON"));
  QCOMPARE(sysEnv.value("COMMON"), QString("updated-common"));
  QVERIFY(sysEnvKeys.contains("UPDATED_ONLY"));
  QCOMPARE(sysEnv.value("UPDATED_ONLY"), QString("updated-only"));
  }
}

// ----------------------------------------------------------------------------
CTK_TEST_MAIN(ctkAppLauncherEnvironmentTest)
#include "moc_ctkAppLauncherEnvironmentTest.cpp"
