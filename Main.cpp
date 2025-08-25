
// Qt includes
#include <QApplication>
#include <QDebug>
#include <QDir>
#include <QFileInfo>
#include <QStringList>
#include <QTimer>
#include <QtPlugin>

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

  appArguments.setArgumentToFilterList(    //
    ctkAppArguments::ArgToFilterListType() //

    //
    // Qt4 built-in arguments - See https://qt-project.org/doc/qt-4.8/qapplication.html#QApplication
    //
    // clang-format off
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
    // clang-format on

    //
    // Qt5 built-in arguments - See https://doc.qt.io/qt-5/qapplication.html#QApplication
    //
    // -style/-style=
    // -stylesheet/-stylesheet=
    // -widgetcount
    // -reverse
    // -qmljsdebugger=

    //
    // Qt5 built-in arguments - See https://doc.qt.io/qt-5/qguiapplication.html#QGuiApplication
    //
    // clang-format off
    << ctkAppArguments::ArgToFilterType("-platform", ctkAppArguments::ARG_TO_FILTER_SPACE_VALUE)
    << ctkAppArguments::ArgToFilterType("-platformpluginpath", ctkAppArguments::ARG_TO_FILTER_SPACE_VALUE)
    << ctkAppArguments::ArgToFilterType("-platformtheme", ctkAppArguments::ARG_TO_FILTER_SPACE_VALUE)
    << ctkAppArguments::ArgToFilterType("-plugin", ctkAppArguments::ARG_TO_FILTER_SPACE_VALUE)
    // -qmljsdebugger=
    << ctkAppArguments::ArgToFilterType("-qwindowgeometry", ctkAppArguments::ARG_TO_FILTER_SPACE_VALUE)
    << ctkAppArguments::ArgToFilterType("-qwindowicon", ctkAppArguments::ARG_TO_FILTER_SPACE_VALUE)
    << ctkAppArguments::ArgToFilterType("-qwindowtitle", ctkAppArguments::ARG_TO_FILTER_SPACE_VALUE)
    // -reverse
    // -session/-session=
#if defined Q_WS_X11
    // -display
    // -geometry
#endif
    << ctkAppArguments::ArgToFilterType("-qwindowtitle", ctkAppArguments::ARG_TO_FILTER_SPACE_VALUE)
    << ctkAppArguments::ArgToFilterType("-fontengine", ctkAppArguments::ARG_TO_FILTER_SPACE_VALUE)
#if defined Q_OS_WIN32
    << ctkAppArguments::ArgToFilterType("-altgr")
    << ctkAppArguments::ArgToFilterType("-darkmode=", ctkAppArguments::ARG_TO_FILTER_EQUAL_VALUE)
    << ctkAppArguments::ArgToFilterType("-dialogs=", ctkAppArguments::ARG_TO_FILTER_EQUAL_VALUE)
    << ctkAppArguments::ArgToFilterType("-dpiawareness=", ctkAppArguments::ARG_TO_FILTER_EQUAL_VALUE)
    << ctkAppArguments::ArgToFilterType("-fontengine=", ctkAppArguments::ARG_TO_FILTER_EQUAL_VALUE)
    << ctkAppArguments::ArgToFilterType("-menus=", ctkAppArguments::ARG_TO_FILTER_EQUAL_VALUE)
    << ctkAppArguments::ArgToFilterType("-nocolorfonts")
    << ctkAppArguments::ArgToFilterType("-nodirectwrite")
    << ctkAppArguments::ArgToFilterType("-nomousefromtouch")
    << ctkAppArguments::ArgToFilterType("-nowmpointer")
    // -reverse
    << ctkAppArguments::ArgToFilterType("-tabletabsoluterange=", ctkAppArguments::ARG_TO_FILTER_EQUAL_VALUE)
#endif
#if defined Q_OS_MAC
    << ctkAppArguments::ArgToFilterType("-fontengine=", ctkAppArguments::ARG_TO_FILTER_EQUAL_VALUE)
#endif
    // clang-format on
  );

  QString executableName = argv[0];
#if defined Q_OS_WIN32
  // Specifying .exe file extension is optional on Windows (executableName can be
  // "CTKAppLauncher.exe" or just "CTKAppLauncher"). Make sure here that executable
  // path includes file extension so that the file can be found.
  if (!executableName.toLower().endsWith(".exe"))
  {
    executableName.append(".exe");
  }
#endif

  QFileInfo launcherFile(QDir::current(), executableName);
  // Initialize resources in static libs
  Q_INIT_RESOURCE(CTKAppLauncherBase);

  QScopedPointer<ctkAppLauncher> appLauncher(new ctkAppLauncher);
  appLauncher->setArguments(appArguments.arguments());
  if (!appLauncher->initialize(launcherFile.absoluteFilePath()))
  {
    return EXIT_FAILURE;
  }
  int status = appLauncher->configure();
  if (status != ctkAppLauncher::Continue)
  {
    return status == ctkAppLauncher::ExitWithSuccess ? EXIT_SUCCESS : EXIT_FAILURE;
  }

  QScopedPointer<QCoreApplication> app;
  if (appLauncher->disableSplash())
  {
    app.reset(new QCoreApplication( //
      appArguments.argumentCount(ctkAppArguments::ARG_REGULAR_LIST),
      appArguments.argumentValues(ctkAppArguments::ARG_REGULAR_LIST)));
  }
  else
  {
    // Initialize platform plugin in static build
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0) && defined Q_OS_WIN32 && defined QT_STATIC)
    Q_IMPORT_PLUGIN(QWindowsIntegrationPlugin)
#endif
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0) && defined Q_OS_LINUX && defined QT_STATIC)
    Q_IMPORT_PLUGIN(QXcbIntegrationPlugin)
#endif

    app.reset(new QApplication( //
      appArguments.argumentCount(ctkAppArguments::ARG_REGULAR_LIST),
      appArguments.argumentValues(ctkAppArguments::ARG_REGULAR_LIST)));
  }

  appLauncher.reset(new ctkAppLauncher);
  appLauncher->setArguments(appArguments.arguments());
  appLauncher->initialize(launcherFile.absoluteFilePath());
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
// NOTE: On Windows, wmain should be used to allow non-ASCII characters in command-line arguments
int main(int argc, char* argv[])
{
  // Uncomment the next two lines to stop at application start (to give a chance to connect with a debugger)
  // std::cout << "Attach debugger and hit Enter" << std::endl;
  // std::cin.get();

  return appLauncherMain(argc, argv);
}
#elif defined Q_OS_WIN32
int __stdcall wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, PWSTR lpCmdLine, int nShowCmd)
{
  // Uncomment the next line to stop at application start (to give a chance to connect with a debugger)
  // int msgboxID = MessageBox(NULL, "Attach your debugger", "Debug", MB_ICONWARNING);

  Q_UNUSED(hInstance);
  Q_UNUSED(hPrevInstance);
  Q_UNUSED(nShowCmd);

  int argc;
  char** argv;
  ctkCommandLineParser::convertWindowsCommandLineToUnixArguments(lpCmdLine, &argc, &argv);

  int ret = appLauncherMain(argc, argv);

  for (int i = 0; i < argc; ++i)
  {
    delete[] argv[i];
  }
  delete[] argv;

  return ret;
}
#else
# error CTKAPPLAUNCHER_WITHOUT_CONSOLE_IO_SUPPORT is only supported on WIN32 !
#endif
