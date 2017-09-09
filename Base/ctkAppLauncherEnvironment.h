#ifndef __ctkAppLauncherEnvironment_h
#define __ctkAppLauncherEnvironment_h

// Qt includes
#include <QObject>
#include <QProcessEnvironment>

class ctkAppLauncherEnvironmentPrivate;

///
/// \brief The ctkAppLauncherEnvironment class provides an interface for
/// interacting with the AppLauncher environment variables.
///
/// It supports retrieving the original launcher environment from
/// a launched process.
///
/// APPLAUNCHER_* environment variable prefix
/// -----------------------------------------
///
/// Each time the launcher starts an application, it keeps track of the
/// the modified/added/removed environment variables using other environment
/// variables.
///
/// With each invocation of the launcher, the variable `APPLAUNCHER_LEVEL` is
/// set to `<level>` where `<level>` is an integer greater or equal to zero.
/// Additonally, for every modified/added/removed variables, a variable named
/// after `APPLAUNCHER_<level>_<varname>` is also added.
///
///
class ctkAppLauncherEnvironment : public QObject
{
  Q_OBJECT
public:
  typedef ctkAppLauncherEnvironment Self;
  typedef QObject Superclass;

  ctkAppLauncherEnvironment(QObject* parentObject = 0);
  ~ctkAppLauncherEnvironment();

  /// Returns the current applauncher level.
  ///
  /// This is the value of the `APPLAUNCHER_LEVEL`
  /// environment variable.
  ///
  /// If the environment variable is not set or set to an invalid
  /// value, it returns 0.
  static int currentLevel();

  /// Return the environment corresponding to the requested \c level.
  ///
  /// This function returns an environment object including all variables
  /// of the current environment and the one associated with the requested
  /// \c level. These variables are the one saved in the current environment
  /// using the `APPLAUNCHER_<level>_<varname>` convention.
  ///
  /// The variables matching `APPLAUNCHER_<level+1>_<varname>` are not returned.
  static QProcessEnvironment environment(int level);

  /// Updated \c env including a saved copy of \c variables found in \c systemEnvironment.
  ///
  /// The saved \c variables are prefixed with `APPLAUNCHER_<level+1>_<varname>`
  /// where `<level>` was retrieved using currentLevel().
  ///
  /// \sa currentLevel()
  static void saveEnvironment(
      const QProcessEnvironment& systemEnvironment,
      const QStringList& variables, QProcessEnvironment& env);

protected:
  ctkAppLauncherEnvironment(ctkAppLauncherEnvironmentPrivate* pimpl, QObject* parentObject);
  QScopedPointer<ctkAppLauncherEnvironmentPrivate> d_ptr;

private:
  Q_DECLARE_PRIVATE(ctkAppLauncherEnvironment)
  Q_DISABLE_COPY(ctkAppLauncherEnvironment)
};

#endif
