// Qt includes
#include <QDebug>
#include <QApplication>

// CTK includes
#include <ctkAppArguments.h>
#include <ctkAppLauncher.h>
#include <ctkTest.h>

// STD includes
#include <sstream>

class ctkAppLauncherTest1er: public QObject
{
  Q_OBJECT

private slots:

  void testVerbose();

  void testSetArguments();
  void testSetArguments_data();
};

// ----------------------------------------------------------------------------
void ctkAppLauncherTest1er::testVerbose()
{
  ctkAppLauncher appLauncher(*qApp);
  QVERIFY2(!appLauncher.verbose(), "Disabled by default");
}

// ----------------------------------------------------------------------------
void ctkAppLauncherTest1er::testSetArguments()
{
  QFETCH(bool, shouldSetArguments);
  QFETCH(QStringList, argumentsToSet);
  QFETCH(QStringList, expectedArguments);

  ctkAppLauncher appLauncher(*qApp);

  if (shouldSetArguments)
    {
    appLauncher.setArguments(argumentsToSet);
    }

  QCOMPARE(appLauncher.arguments(), expectedArguments);
}

// ----------------------------------------------------------------------------
void ctkAppLauncherTest1er::testSetArguments_data()
{
  QTest::addColumn<bool>("shouldSetArguments");
  QTest::addColumn<QStringList>("argumentsToSet");
  QTest::addColumn<QStringList>("expectedArguments");

  QTest::newRow("0") << false
                     << QStringList()
                     << qApp->arguments();

  QTest::newRow("1") << true
                     << (QStringList() << "ctkAppLauncherTest" << "-bar")
                     << (QStringList() << "ctkAppLauncherTest" << "-bar");
}

// ----------------------------------------------------------------------------
CTK_TEST_MAIN(ctkAppLauncherTest1)
#include "moc_ctkAppLauncherTest1.cpp"
