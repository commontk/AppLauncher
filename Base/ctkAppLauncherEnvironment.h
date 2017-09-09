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
/// It supports saving the environment and retrieving it. This allows
/// the original launcher environment to be saved and later retrieved
/// from the launched process.
///
/// Each time the environment is saved, if the environment variable `APPLAUNCHER_LEVEL`
/// was set, its value `<level>` is incremented otherwise it is initialized to zero.
/// Then all variables (*) are copied and named after `APPLAUNCHER_<level>_<varname>`.
///
/// (*) expect the one named `APPLAUNCHER_LEVEL` or starting with `APPLAUNCHER_<level>_`.
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
  /// value, it returns 0 which corresponds to the system environment.
  static int currentLevel();

  /// Return the environment corresponding to the requested \c level.
  ///
  /// This function returns an environment object including all variables
  /// of the current environment and the one associated with the requested
  /// \c level. These variables are the one saved in the current environment
  /// using the `APPLAUNCHER_<level>_<varname>` convention.
  ///
  /// The variables matching `APPLAUNCHER_<level+1>_<varname>` are not returned.
  ///
  /// For example, assuming the current environment contains the following
  /// variables:
  ///
  /// \code
  /// APPLAUNCHER_LEVEL=1
  /// APPLAUNCHER_0_PATH=/path/to/level-0
  /// APPLAUNCHER_0_FRUIT=apple
  /// APPLAUNCHER_1_PATH=/path/to/level-1:/path/to/level-0
  /// APPLAUNCHER_1_FRUIT=banana
  /// PATH=/path/to/level-2:/path/to/level-1:/path/to/level-0
  /// FRUIT=kiwi
  /// \endcode
  ///
  /// calling `environment(1)` would return:
  ///
  /// \code
  /// APPLAUNCHER_LEVEL=0
  /// APPLAUNCHER_0_PATH=/path/to/level-0
  /// APPLAUNCHER_0_FRUIT=apple
  /// PATH=/path/to/level-1:/path/to/level-0
  /// FRUIT=banana
  /// \endcode
  ///
  /// and calling `environment(0)` would return:
  ///
  /// \code
  /// PATH=/path/to/level-0
  /// FRUIT=apple
  /// \endcode
  ///
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
