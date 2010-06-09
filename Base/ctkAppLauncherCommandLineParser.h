#ifndef __ctkAppLauncherCommandLineParser_h
#define __ctkAppLauncherCommandLineParser_h

// Qt includes
#include <QString>
#include <QStringList>

// --------------------------------------------------------------------------
class ctkAppLauncherCommandLineParser
{
public:

  ctkAppLauncherCommandLineParser();
  ~ctkAppLauncherCommandLineParser();
  
  bool parseArguments(const QStringList& arguments);

  QString errorString();
  
  const QStringList& unparsedArguments();
  
  bool argumentAdded(const QString& argument);

  bool argumentParsed(const QString& argument);
  
  void addBooleanArgument(const char* longarg, const char* shortarg, bool* var, 
                          const QString& argHelp, const bool& defaultValue = false, 
                          bool ignoreRest = false);

  void addStringArgument(const char* longarg, const char* shortarg, QString* var, 
                         const QString& argHelp, const QString& defaultValue = QString(), 
                         bool ignoreRest = false);

  void addIntegerArgument(const char* longarg, const char* shortarg, int* var,
                         const QString& argHelp, const int& defaultValue = 0,
                         bool ignoreRest = false);

  void addStringListArgument(const char* longarg, const char* shortarg, QStringList* var,
                             const QString& argHelp,
                             const QStringList& defaultValue = QStringList());

  bool setExactMatchRegularExpression(const QString& argument, const QString& expression,
                                      const QString& ExactMatchFailedMessage);

  int fieldWidth();

  QString helpText(const char charPad = ' ');
  
private:
  class ctkInternal;
  ctkInternal * Internal;
};
#endif
