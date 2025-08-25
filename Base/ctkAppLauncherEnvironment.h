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
  /// associated with the requested \c level. These variables are the one that
  /// were saved in the current environment using the `APPLAUNCHER_<level>_<varname>`
  /// convention. If requested level is not found, an empty environment object
  /// is returned.
  ///
  /// The variables matching `APPLAUNCHER_<level+1>_<varname>` are not returned.
  ///
  /// For example, assuming the current environment contains the following
  /// variables:
  ///
  /// \code
  /// APPLAUNCHER_LEVEL=2
  /// APPLAUNCHER_0_PATH=/path/to/level-0
  /// APPLAUNCHER_0_FRUIT=apple
  /// APPLAUNCHER_0_LEVEL_0_VAR=level-0
  /// APPLAUNCHER_1_PATH=/path/to/level-1:/path/to/level-0
  /// APPLAUNCHER_1_FRUIT=banana
  /// APPLAUNCHER_1_LEVEL_1_VAR=level-1
  /// PATH=/path/to/level-2:/path/to/level-1:/path/to/level-0
  /// FRUIT=kiwi
  /// LEVEL_2_VAR=level-2
  /// \endcode
  ///
  /// calling `environment(1)` would return:
  ///
  /// \code
  /// APPLAUNCHER_LEVEL=1
  /// APPLAUNCHER_0_PATH=/path/to/level-0
  /// APPLAUNCHER_0_FRUIT=apple
  /// APPLAUNCHER_0_LEVEL_0_VAR=level-0
  /// PATH=/path/to/level-1:/path/to/level-0
  /// FRUIT=banana
  /// LEVEL_1=level-1
  /// \endcode
  ///
  /// and calling `environment(0)` would return:
  ///
  /// \code
  /// PATH=/path/to/level-0
  /// FRUIT=apple
  /// LEVEL_0_VAR=level-0
  /// \endcode
  ///
  static QProcessEnvironment environment(int level);

  /// Update \c env including a saved copy of \c variables found in \c systemEnvironment.
  ///
  /// The saved \c variables are prefixed with `APPLAUNCHER_<level>_<varname>`
  /// where `<level>` was retrieved using currentLevel().
  ///
  /// The environment variable `APPLAUNCHER_LEVEL` is either set to 1 if it
  /// was not set or incremented. The function currentLevel() returns its value.
  ///
  /// \sa currentLevel()
  static void saveEnvironment( //
    const QProcessEnvironment& systemEnvironment,
    const QStringList& variables,
    QProcessEnvironment& env);

  /// Update current environment using \c environment.
  ///
  /// Variables found only in current environment are unset.
  static void updateCurrentEnvironment(const QProcessEnvironment& environment);

  /// Returns variable names associated with \c env.
  ///
  /// Since QProcessEnvironment::keys() was introduced in Qt 4.8, this function
  /// implements a fallback for older version of Qt.
  static QStringList envKeys(const QProcessEnvironment& env);

  /// Return an updated list of names excluding AppLauncher reserved variable names.
  ///
  /// \sa isReservedVariableName(const QString& varname)
  static QStringList excludeReservedVariableNames(const QStringList& variableNames);

  /// Return true if \c varname is an AppLauncher reserved variable name.
  ///
  /// AppLauncher reserved name include `APPLAUNCHER_LEVEL`
  /// as well as name prefixed with `APPLAUNCHER_<level>_` where `<level>` is an integer.
  static bool isReservedVariableName(const QString& varname);

  /// Return first variable name found in \c names by performing a case insensitive search for \c variableName.
  ///
  /// If no variable was found, \c variableName is returned.
  static QString casedVariableName(const QStringList& names, const QString& variableName);

protected:
  ctkAppLauncherEnvironment(ctkAppLauncherEnvironmentPrivate* pimpl, QObject* parentObject);
  QScopedPointer<ctkAppLauncherEnvironmentPrivate> d_ptr;

private:
  Q_DECLARE_PRIVATE(ctkAppLauncherEnvironment)
  Q_DISABLE_COPY(ctkAppLauncherEnvironment)
};

#endif
