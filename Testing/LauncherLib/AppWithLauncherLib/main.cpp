

// Qt includes
#include <QDebug>
#include <QFile>
#include <QSettings>
#include <QStringList>

// CTKAppLauncher includes
#include <ctkSettingsHelper.h>

// STD includes
#include <cstdlib>

int main(int, char*[])
{
  QSettings settings("settings.ini", QSettings::IniFormat);
  if (!QFile(settings.fileName()).exists())
    {
    qWarning() << "Line" << __LINE__ << __FILE__ << "\n"
               << "Settings file" << settings.fileName() << "does not exist";
    return EXIT_FAILURE;
    }

  QStringList current = ctk::readArrayValues(settings, "Paths", "path");
  QStringList expected = QStringList() << "/foo" << "/bar";

  if (current != expected)
    {
    qWarning() << "Line" << __LINE__ << __FILE__ << "\n"
               << "Problem with ctk::readArrayValues\n"
               << "  current:" << current
               << "  expected:" << expected;
    return EXIT_FAILURE;
    }

  return EXIT_SUCCESS;
}
