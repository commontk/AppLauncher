
// Qt includes
#include <QApplication>
#include <QDebug>
#include <QDir>
#include <QFileInfo>
#include <QStringList>
#include <QTimer>

// CTK includes
#include "ctkAppArguments.h"
#include "ctkAppLauncher.h"
#include "ctkCommandLineParser.h"

// STD includes
#include <cstdlib>

// Windows includes
#ifdef Q_OS_WIN32
# include <windows.h>
#endif

// --------------------------------------------------------------------------
int appLauncherMain(int argc, char** argv)
{
  #ifdef QT_MAC_USE_COCOA
  // See http://doc.trolltech.com/4.7/qt.html#ApplicationAttribute-enum
  // Setting the application to be a plugin will avoid the loading of qt_menu.nib files
  QCoreApplication::setAttribute(Qt::AA_MacPluginApplication, true);
  #endif

  ctkAppArguments appArguments(argc, argv);

  // See http://qt-project.org/doc/qt-4.8/qapplication.html#QApplication
  appArguments.setArgumentToFilterList(
        ctkAppArguments::ArgToFilterListType()
        << ctkAppArguments::ArgToFilterType("-style", ctkAppArguments::ARG_TO_FILTER_EQUAL_VALUE | ctkAppArguments::ARG_TO_FILTER_SPACE_VALUE)
        << ctkAppArguments::ArgToFilterType("-stylesheet", ctkAppArguments::ARG_TO_FILTER_EQUAL_VALUE | ctkAppArguments::ARG_TO_FILTER_SPACE_VALUE)
        << ctkAppArguments::ArgToFilterType("-session", ctkAppArguments::ARG_TO_FILTER_EQUAL_VALUE | ctkAppArguments::ARG_TO_FILTER_SPACE_VALUE)
        << ctkAppArguments::ArgToFilterType("-widgetcount")
        << ctkAppArguments::ArgToFilterType("-reverse")
        << ctkAppArguments::ArgToFilterType("-graphicssystem")
        << ctkAppArguments::ArgToFilterType("-qmljsdebugger=", ctkAppArguments::ARG_TO_FILTER_EQUAL_VALUE)
#ifdef QT_DEBUG
        << ctkAppArguments::ArgToFilterType("-nograb")
#endif
#ifdef Q_WS_X11
        << ctkAppArguments::ArgToFilterType("-display")
        << ctkAppArguments::ArgToFilterType("-geometry")
        << ctkAppArguments::ArgToFilterType("-fn")
        << ctkAppArguments::ArgToFilterType("-font")
        << ctkAppArguments::ArgToFilterType("-bg")
        << ctkAppArguments::ArgToFilterType("-background")
        << ctkAppArguments::ArgToFilterType("-fg")
        << ctkAppArguments::ArgToFilterType("-foreground")
        << ctkAppArguments::ArgToFilterType("-btn")
        << ctkAppArguments::ArgToFilterType("-button")
        << ctkAppArguments::ArgToFilterType("-name")
        << ctkAppArguments::ArgToFilterType("-title")
        << ctkAppArguments::ArgToFilterType("-visual")
        << ctkAppArguments::ArgToFilterType("-ncols")
        << ctkAppArguments::ArgToFilterType("-cmap")
        << ctkAppArguments::ArgToFilterType("-im")
        << ctkAppArguments::ArgToFilterType("-inputstyle")
# ifdef QT_DEBUG
        << ctkAppArguments::ArgToFilterType("-dograb")
        << ctkAppArguments::ArgToFilterType("-sync")
# endif
#endif
        );

  QFileInfo launcherFile(QDir::current(), QString(argv[0]));
  // Initialize resources in static libs
  Q_INIT_RESOURCE(CTKAppLauncherBase);

  QScopedPointer<ctkAppLauncher> appLauncher(new ctkAppLauncher);
  appLauncher->setArguments(appArguments.arguments());
  bool exec = appLauncher->initialize(launcherFile.absoluteFilePath());
  exec = appLauncher->configure() && exec;

  if (!exec)
    {
    return EXIT_SUCCESS;
    }

  QScopedPointer<QCoreApplication> app;
  if (appLauncher->disableSplash())
    {
    app.reset(new QCoreApplication(
                appArguments.argumentCount(ctkAppArguments::ARG_REGULAR_LIST),
                appArguments.argumentValues(ctkAppArguments::ARG_REGULAR_LIST)));
    }
  else
    {
    app.reset(new QApplication(
                appArguments.argumentCount(ctkAppArguments::ARG_REGULAR_LIST),
                appArguments.argumentValues(ctkAppArguments::ARG_REGULAR_LIST)));
    }
  appLauncher->setApplication(*app.data());

  QTimer::singleShot(0, appLauncher.data(), SLOT(startLauncher()));

  int res = app->exec();

  // Delete application launcher appLauncher before the application app so that
  // graphical items such as pixmaps, widgets, etc can be released.
  appLauncher.reset();

  return res;
}

// --------------------------------------------------------------------------
#ifndef CTKAPPLAUNCHER_WITHOUT_CONSOLE_IO_SUPPORT
int main(int argc, char *argv[])
{
  return appLauncherMain(argc, argv);
}
#elif defined Q_OS_WIN32
int __stdcall WinMain(HINSTANCE hInstance,
                      HINSTANCE hPrevInstance,
                      LPSTR lpCmdLine, int nShowCmd)
{
  Q_UNUSED(hInstance);
  Q_UNUSED(hPrevInstance);
  Q_UNUSED(nShowCmd);

  int argc;
  char **argv;
  ctkCommandLineParser::convertWindowsCommandLineToUnixArguments(lpCmdLine, &argc, &argv);

  int ret = appLauncherMain(argc, argv);

  for (int i = 0; i < argc; ++i)
    {
    delete [] argv[i];
    }
  delete [] argv;

  return ret;
}
#else
# error CTKAPPLAUNCHER_WITHOUT_CONSOLE_IO_SUPPORT is only supported on WIN32 !
#endif
