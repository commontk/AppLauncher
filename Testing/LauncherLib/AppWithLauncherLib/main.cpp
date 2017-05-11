

// Qt includes
#include <QDebug>
#include <QSettings>
#include <QStringList>

// CTKAppLauncher includes
#include <ctkSettingsHelper.h>

// STD includes
#include <cstdlib>

int main(int, char*[])
{
  QSettings settings("settings.ini", QSettings::IniFormat);

  QStringList current = ctk::readArrayValues(settings, "Paths", "path");
  QStringList expected = QStringList() << "/foo" << "/bar";

  if (current != expected)
    {
    return EXIT_FAILURE;
    }

  return EXIT_SUCCESS;
}
