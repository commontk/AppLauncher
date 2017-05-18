#ifndef __ctkAppLauncherSettings_h
#define __ctkAppLauncherSettings_h

// Qt includes
#include <QObject>

class ctkAppLauncherSettingsPrivate;

// --------------------------------------------------------------------------
class ctkAppLauncherSettings : public QObject
{
  Q_OBJECT
public:
  typedef ctkAppLauncherSettings Self;
  typedef QObject Superclass;

  ctkAppLauncherSettings(QObject* parentObject = 0);
  ~ctkAppLauncherSettings();

protected:
  ctkAppLauncherSettings(ctkAppLauncherSettingsPrivate* pimpl, QObject* parentObject);
  QScopedPointer<ctkAppLauncherSettingsPrivate> d_ptr;

private:
  Q_DECLARE_PRIVATE(ctkAppLauncherSettings)
  Q_DISABLE_COPY(ctkAppLauncherSettings)
};

#endif
