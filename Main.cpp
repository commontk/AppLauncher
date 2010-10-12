
// Qt includes
#include <QApplication>
#include <QTimer>
#include <QDebug>

// STD includes
#include <cstdlib>

#include "ctkAppLauncher.h"

int main(int argc, char** argv)
{
  #ifdef QT_MAC_USE_COCOA
  // See http://doc.trolltech.com/4.7/qt.html#ApplicationAttribute-enum
  // Setting the application to be a plugin will avoid the loading of qt_menu.nib files
  QCoreApplication::setAttribute(Qt::AA_MacPluginApplication, true);
  #endif
  QApplication app(argc, argv);
  
  // Initialize resources in static libs
  Q_INIT_RESOURCE(CTKAppLauncherBase);
  
  ctkAppLauncher appLauncher(app);
  
  QTimer::singleShot(0, &appLauncher, SLOT(startLauncher()));

  return app.exec();
}
