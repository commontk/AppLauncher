
// Qt includes
#include <QApplication>
#include <QDir>
#include <QHash>
#include <QFile>
#include <QFileInfo>
#include <QSettings>

// CTK includes
#include "ctkAppLauncherSettings.h"
#include "ctkAppLauncherSettings_p.h"
#include "ctkSettingsHelper.h"

// STD includes
#include <iostream>

// --------------------------------------------------------------------------
ctkAppLauncherSettingsPrivate::ctkAppLauncherSettingsPrivate()
{
  this->LauncherSettingSubDirs << "." << "bin" << "lib";

#if defined(Q_OS_WIN32)
  this->PathSep = ";";
  this->LibraryPathVariableName = "PATH";
#else
  this->PathSep = ":";
# if defined(Q_OS_MAC)
  this->LibraryPathVariableName = "DYLD_LIBRARY_PATH";
# elif defined(Q_OS_LINUX)
  this->LibraryPathVariableName = "LD_LIBRARY_PATH";
# else
  // TODO support solaris?
#  error CTK launcher is not supported on this platform
# endif
#endif

  this->SystemEnvironment = QProcessEnvironment::systemEnvironment();
}

// --------------------------------------------------------------------------
bool ctkAppLauncherSettingsPrivate::verbose() const
{
  return false;
}

// --------------------------------------------------------------------------
// ctkAppLauncherSettings

// --------------------------------------------------------------------------
ctkAppLauncherSettings::ctkAppLauncherSettings(QObject* parentObject) :
  Superclass(parentObject), d_ptr(new ctkAppLauncherSettingsPrivate)
{
  Q_D(ctkAppLauncherSettings);
  d->Initialized = true;
}

//-----------------------------------------------------------------------------
ctkAppLauncherSettings::ctkAppLauncherSettings(
  ctkAppLauncherSettingsPrivate* pimpl, QObject* parentObject)
  : Superclass(parentObject), d_ptr(pimpl)
{
  // Note: You are responsible to call init() in the constructor of derived class.
}

// --------------------------------------------------------------------------
ctkAppLauncherSettings::~ctkAppLauncherSettings()
{
}
