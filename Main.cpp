
// Qt includes
#include <QApplication>
#include <QTimer>
#include <QDebug>

// STD includes
#include <cstdlib>

#include "ctkAppLauncher.h"

int main(int argc, char** argv)
{
  QApplication app(argc, argv);
  
  // Initialize resources in static libs
  Q_INIT_RESOURCE(CTKAppLauncherBase);
  
  ctkAppLauncher appLauncher(app);
  
  QTimer::singleShot(0, &appLauncher, SLOT(startLauncher()));

  return app.exec();
}
