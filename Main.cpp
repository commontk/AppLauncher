
// Qt includes
#include <QApplication>
#include <QStringList>
#include <QTimer>
#include <QDebug>

// STD includes
#include <cstdlib>

#include "ctkAppArguments.h"
#include "ctkAppLauncher.h"

int main(int argc, char** argv)
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

  QApplication app(appArguments.argumentCount(ctkAppArguments::ARG_REGULAR_LIST),
                   appArguments.argumentValues(ctkAppArguments::ARG_REGULAR_LIST));

  // Initialize resources in static libs
  Q_INIT_RESOURCE(CTKAppLauncherBase);

  ctkAppLauncher appLauncher(app);
  appLauncher.setArguments(appArguments.arguments());

  QTimer::singleShot(0, &appLauncher, SLOT(startLauncher()));

  return app.exec();
}
