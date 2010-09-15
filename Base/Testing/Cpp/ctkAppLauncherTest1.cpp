// Qt includes
#include <QDebug>
#include <QApplication>

// CTK includes
#include "ctkAppLauncher.h"

// STD includes
#include <cstdlib>
#include <sstream>

int ctkAppLauncherTest1(int argc, char* argv[])
{
  QApplication app(argc, argv);

  ctkAppLauncher appLauncher(app);

  // Test0 - verbose()
  // By default, verbose flag should be Off
  if (appLauncher.verbose())
    {
    qCritical() << "Test0a - Problem with verbose() function";
    return EXIT_FAILURE;
    }
//  appLauncher.setVerbose(true);
//  if (!appLauncher.verbose())
//    {
//    qCritical() << "Test0b - Problem with verbose() function";
//    return EXIT_FAILURE;
//    }

//  appLauncher.setVerbose(false);
//  if (appLauncher.verbose())
//    {
//    qCritical() << "Test0c - Problem with verbose() function";
//    return EXIT_FAILURE;
//    }

  // Test1 - displayHelp() before initialize()
  std::ostringstream helpText;
  appLauncher.displayHelp(helpText);

  if (helpText.str().length() != 0)
    {
    // Since the command line parser hasn't been initialized, displayHelp is expected
    // to return an empty string.
    qCritical() << "Test1 - Problem with displayHelp() function";
    return EXIT_FAILURE;
    }

  // Test2 - initialize()
  bool status = appLauncher.initialize();
  if (!status)
    {
    qCritical() << "Test2 - Problem with initialize() function";
    return EXIT_FAILURE;
    }

  // Test3 - displayHelp() after initialize()
  QString expectedHelpText;
  QTextStream expectedHelpTextStream(&expectedHelpText);

  expectedHelpTextStream << "Usage\n"
    << "  CTKAppLauncherBaseCppTests [options]\n\n"
    << "Options\n"
    << "  --launcher-help                Display help\n"
    << "  --launcher-verbose             Verbose mode\n"
    << "  --launch                       Specify the application to launch\n"
    << "  --launcher-detach              Launcher will NOT wait for the application to finish\n"
    << "  --launcher-no-splash           Hide launcher splash\n"
    << "  --launcher-timeout             Specify the time in second before the launcher kills "
       "the application. -1 means no timeout (default: -1)\n"
    << "  --launcher-generate-template   Generate an example of setting file\n";

  helpText.clear();
  appLauncher.displayHelp(helpText);
  if (expectedHelpText != QString::fromStdString(helpText.str()))
    {
    qCritical() << "Test3 - Problem with displayHelp() function - expected\n-----\n"
        << expectedHelpText << "\n-----\ncurrent\n-----\n" << QString::fromStdString(helpText.str());
    return EXIT_FAILURE;
    }

  return EXIT_SUCCESS;
}

