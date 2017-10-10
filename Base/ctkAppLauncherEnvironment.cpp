
#include <ctkAppLauncherEnvironment.h>

// Qt includes
#include <QSet>

// STD includes
#include <cstdlib>

// --------------------------------------------------------------------------
// ctkAppLauncherEnvironmentPrivate

// --------------------------------------------------------------------------
class ctkAppLauncherEnvironmentPrivate
{
  Q_DECLARE_PUBLIC(ctkAppLauncherEnvironment)
protected:
  ctkAppLauncherEnvironment* q_ptr;
public:
  ctkAppLauncherEnvironmentPrivate(ctkAppLauncherEnvironment& object);

  static QRegExp LevelVarNameRegex;
};

// --------------------------------------------------------------------------
QRegExp ctkAppLauncherEnvironmentPrivate::LevelVarNameRegex = QRegExp("^APPLAUNCHER\\_(\\d+)\\_");

// --------------------------------------------------------------------------
ctkAppLauncherEnvironmentPrivate::ctkAppLauncherEnvironmentPrivate(ctkAppLauncherEnvironment& object)
  : q_ptr(&object)
{
}

// --------------------------------------------------------------------------
// ctkAppLauncherEnvironment

// --------------------------------------------------------------------------
ctkAppLauncherEnvironment::ctkAppLauncherEnvironment(QObject* parentObject) :
  Superclass(parentObject), d_ptr(new ctkAppLauncherEnvironmentPrivate(*this))
{
}

// --------------------------------------------------------------------------
ctkAppLauncherEnvironment::~ctkAppLauncherEnvironment()
{
}

// --------------------------------------------------------------------------
int ctkAppLauncherEnvironment::currentLevel()
{
  const char* levelStr = getenv("APPLAUNCHER_LEVEL");
  if (!levelStr)
    {
    return 0;
    }
  int level = QString("%1").arg(levelStr).toInt();
  return level >= 0 ? level : 0;
}

// --------------------------------------------------------------------------
QProcessEnvironment ctkAppLauncherEnvironment::environment(int requestedLevel)
{
  QProcessEnvironment currentEnv = QProcessEnvironment::systemEnvironment();
  if (requestedLevel == Self::currentLevel())
    {
    return currentEnv;
    }
  else if (requestedLevel > Self::currentLevel() || requestedLevel < 0)
    {
    return QProcessEnvironment();
    }
  QProcessEnvironment env(currentEnv);
#if QT_VERSION >= 0x040800
  QStringList currentEnvKeys = currentEnv.keys();
#else
  QStringList currentEnvKeys;
  foreach (const QString& pair, currentEnv.toStringList())
    {
    currentEnvKeys.append(pair.split("=").first());
    }
#endif
  QStringList requestedEnvKeys;
  foreach(const QString& varname, currentEnvKeys)
    {
    if (ctkAppLauncherEnvironmentPrivate::LevelVarNameRegex.indexIn(varname) == 0)
      {
      int currentLevel = ctkAppLauncherEnvironmentPrivate::LevelVarNameRegex.cap(1).toInt();
      if (currentLevel == requestedLevel)
        {
        QString currentVarName = QString(varname).remove(0, ctkAppLauncherEnvironmentPrivate::LevelVarNameRegex.matchedLength());
        env.insert(currentVarName, currentEnv.value(varname));
        env.remove(varname);
        requestedEnvKeys.append(currentVarName);
        }
      else if (currentLevel > requestedLevel)
        {
        env.remove(varname);
        }
      }
    }
  if (requestedLevel == 0)
    {
    env.remove("APPLAUNCHER_LEVEL");
    }
  else if (requestedLevel > 0)
    {
    env.insert("APPLAUNCHER_LEVEL", QString("%1").arg(requestedLevel));
    }

  // Remove variables that are present in current environment but not
  // associated with the requested saved level.
  QSet<QString> variablesToRemove =
      ctkAppLauncherEnvironment::excludeReservedVariableNames(currentEnvKeys).toSet()
      - ctkAppLauncherEnvironment::excludeReservedVariableNames(requestedEnvKeys).toSet();
  foreach(const QString& varname, variablesToRemove.values())
    {
    env.remove(varname);
    }

  return env;
}

// --------------------------------------------------------------------------
void ctkAppLauncherEnvironment::saveEnvironment(
    const QProcessEnvironment& systemEnvironment,
    const QStringList& variables, QProcessEnvironment& env)
{
  // Keep track of launcher level
  int launcher_level = 1;
  if (systemEnvironment.contains("APPLAUNCHER_LEVEL"))
    {
    launcher_level =
        systemEnvironment.value("APPLAUNCHER_LEVEL").toInt() + 1;
    }
  env.insert("APPLAUNCHER_LEVEL", QString("%1").arg(launcher_level));

  // Save value environment variables
  foreach(const QString& varname, variables)
    {
    if (!systemEnvironment.contains(varname)
        || ctkAppLauncherEnvironment::isReservedVariableName(varname))
      {
      continue;
      }
    QString saved_varname = QString("APPLAUNCHER_%1_%2").arg(launcher_level - 1).arg(varname);
    QString saved_value = systemEnvironment.value(varname, "");
    env.insert(saved_varname, saved_value);
    }
}

// --------------------------------------------------------------------------
bool ctkAppLauncherEnvironment::isReservedVariableName(const QString& varname)
{
  return
      ctkAppLauncherEnvironmentPrivate::LevelVarNameRegex.indexIn(varname) == 0
      || varname == "APPLAUNCHER_LEVEL";
}

// --------------------------------------------------------------------------
QString ctkAppLauncherEnvironment::casedVariableName(const QStringList& names, const QString& variableName)
{
  QRegExp rx(variableName, Qt::CaseInsensitive);
  int index = names.indexOf(rx);
  if (index >= 0)
    {
    return names.value(index);
    }
  else
    {
    return variableName;
    }
}

// --------------------------------------------------------------------------
QStringList ctkAppLauncherEnvironment::excludeReservedVariableNames(const QStringList& variableNames)
{
  QStringList updatedList;
  foreach(const QString& varname, variableNames)
    {
    if (ctkAppLauncherEnvironment::isReservedVariableName(varname))
      {
      continue;
      }
    updatedList.append(varname);
    }
  return updatedList;
}
