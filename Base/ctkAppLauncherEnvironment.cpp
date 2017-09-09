
#include <ctkAppLauncherEnvironment.h>

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
};

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
  QProcessEnvironment env(currentEnv);
  QRegExp levelVarNameRegex("^APPLAUNCHER\\_(\\d+)\\_");
  foreach(const QString& varname, currentEnv.keys())
    {
    if (levelVarNameRegex.indexIn(varname) == 0)
      {
      int currentLevel = levelVarNameRegex.cap(1).toInt();
      if (currentLevel == requestedLevel)
        {
        QString currentVarName = QString(varname).remove(0, levelVarNameRegex.matchedLength());
        env.insert(currentVarName, currentEnv.value(varname));
        env.remove(varname);
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
    env.insert("APPLAUNCHER_LEVEL", QString("%1").arg(requestedLevel - 1));
    }
  return env;
}

// --------------------------------------------------------------------------
void ctkAppLauncherEnvironment::saveEnvironment(
    const QProcessEnvironment& systemEnvironment,
    const QStringList& variables, QProcessEnvironment& env)
{
  // Keep track of launcher level
  int launcher_level = 0;
  if (systemEnvironment.contains("APPLAUNCHER_LEVEL"))
    {
    launcher_level =
        systemEnvironment.value("APPLAUNCHER_LEVEL").toInt() + 1;
    }
  env.insert("APPLAUNCHER_LEVEL", QString("%1").arg(launcher_level));

  // Save value environment variables
  foreach(const QString& varname, variables)
    {
    if (!systemEnvironment.contains(varname))
      {
      continue;
      }
    QString saved_varname = QString("APPLAUNCHER_%1_%2").arg(launcher_level).arg(varname);
    QString saved_value = systemEnvironment.value(varname, "");
    env.insert(saved_varname, saved_value);
    }
}
