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

  void testDisplayHelp();
  void testDisplayHelp_data();

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
void ctkAppLauncherTest1er::testDisplayHelp()
{
  QFETCH(bool, initialize);
  QFETCH(QString, expectedDisplayText);

  ctkAppLauncher appLauncher(*qApp);

  if (initialize)
    {
    QVERIFY(appLauncher.initialize());
    }

  std::ostringstream helpText;
  appLauncher.displayHelp(helpText);

  QCOMPARE(QString::fromLatin1(helpText.str().c_str()), expectedDisplayText);
}

// ----------------------------------------------------------------------------
void ctkAppLauncherTest1er::testDisplayHelp_data()
{
  QTest::addColumn<bool>("initialize");
  QTest::addColumn<QString>("expectedDisplayText");

  QTest::newRow("0") << false << QString();

  QTest::newRow("1")
      << true
      << QString(
           "Usage\n"
           "  CTKAppLauncherBaseCppTests [options]\n\n"
           "Options\n"
           "  --launcher-help                Display help\n"
           "  --launcher-verbose             Verbose mode\n"
           "  --launch                       Specify the application to launch\n"
           "  --launcher-detach              Launcher will NOT wait for the application to finish\n"
           "  --launcher-no-splash           Hide launcher splash\n"
           "  --launcher-timeout             Specify the time in second before the launcher kills "
           "the application. -1 means no timeout (default: -1)\n"
           "  --launcher-generate-template   Generate an example of setting file\n");
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
int ctkAppLauncherTest1(int argc, char *argv[])
{
#ifdef QT_MAC_USE_COCOA
  // See http://doc.trolltech.com/4.7/qt.html#ApplicationAttribute-enum
  // Setting the application to be a plugin will avoid the loading of qt_menu.nib files
  QCoreApplication::setAttribute(Qt::AA_MacPluginApplication, true);
#endif
  QApplication app(argc, argv);
  ctkAppLauncherTest1er tc;
  return QTest::qExec(&tc, argc, argv);
}
#include "moc_ctkAppLauncherTest1.cpp"
