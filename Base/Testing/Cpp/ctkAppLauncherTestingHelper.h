#ifndef __ctkAppLauncherTestingHelper_h
#define __ctkAppLauncherTestingHelper_h

// Qt includes
#include <QString>
#include <QStringList>

// STD includes
#include <cstdlib>

template <typename TYPE>
bool CheckList(int line, const QString& description, const QList<TYPE>& current, const QList<TYPE>& expected, const QString& testName);

bool CheckStringList(int line, const QString& description, const QStringList& current, const QStringList& expected);

bool CheckString(int line, const QString& description, const char* current, const char* expected, bool errorIfDifferent = true);

template <typename TYPE>
bool Check(int line, const QString& description, TYPE current, TYPE expected, const QString& _testName, bool errorIfDifferent = true);

bool CheckInt(int line, const QString& description, int current, int expected);

QString readFile(int line, const QString& filePath);
int writeFile(int line, const QString& filePath, const QString& content);
QString createUserAdditionalLauncherSettings(const QString& appNameTemplate, QString& appName, bool& ok);

//----------------------------------------------------------------------------
// Copied from CTK/Libs/Core/ctkCoreTestingMacros.h
#define CHECK_QSTRINGLIST(actual, expected)                         \
  {                                                                 \
    QStringList a = (actual);                                       \
    QStringList e = (expected);                                     \
    if (!CheckStringList(__LINE__, #actual " != " #expected, a, e)) \
    {                                                               \
      return EXIT_FAILURE;                                          \
    }                                                               \
  }

//----------------------------------------------------------------------------
/// Verifies if actual QStringList is the same as expected.
#define QCOMPARE_QSTRINGLIST(actual, expected)                      \
  {                                                                 \
    QStringList a = (actual);                                       \
    QStringList e = (expected);                                     \
    if (!CheckStringList(__LINE__, #actual " != " #expected, a, e)) \
    {                                                               \
      QFAIL("");                                                    \
    }                                                               \
  }

//----------------------------------------------------------------------------
// Copied from CTK/Libs/Core/ctkCoreTestingMacros.h
#define CHECK_QSTRING(actual, expected)                                                 \
  {                                                                                     \
    QString a = (actual);                                                               \
    QString e = (expected);                                                             \
    if (!CheckString(__LINE__, #actual " != " #expected, qPrintable(a), qPrintable(e))) \
    {                                                                                   \
      return EXIT_FAILURE;                                                              \
    }                                                                                   \
  }

//----------------------------------------------------------------------------
// Copied from CTK/Libs/Core/ctkCoreTestingMacros.h
#define CHECK_INT(actual, expected)                                          \
  {                                                                          \
    if (!CheckInt(__LINE__, #actual " != " #expected, (actual), (expected))) \
    {                                                                        \
      return EXIT_FAILURE;                                                   \
    }                                                                        \
  }

//----------------------------------------------------------------------------
// Copied from CTK/Libs/Core/ctkCoreTestingMacros.h
#define CHECK_BOOL(actual, expected)                                                         \
  {                                                                                          \
    if (!CheckInt(__LINE__, #actual " != " #expected, (actual) ? 1 : 0, (expected) ? 1 : 0)) \
    {                                                                                        \
      return EXIT_FAILURE;                                                                   \
    }                                                                                        \
  }

//----------------------------------------------------------------------------
#define CHECK_EXIT_SUCCESS(actual)                                                                                             \
  {                                                                                                                            \
    int a = (actual);                                                                                                          \
    if (a != EXIT_SUCCESS)                                                                                                     \
    {                                                                                                                          \
      qWarning() << "\nLine " << __LINE__ << " - " << #actual " != EXIT_SUCCESS" << " : " << "CheckExitSuccess" << "  failed"; \
      return EXIT_FAILURE;                                                                                                     \
    }                                                                                                                          \
  }

//----------------------------------------------------------------------------
#define CHECK_QSTRING_NOT_NULL(actual)                                                                                    \
  {                                                                                                                       \
    QString a = (actual);                                                                                                 \
    if (a.isNull())                                                                                                       \
    {                                                                                                                     \
      qWarning() << "\nLine " << __LINE__ << " - " << #actual " is Null" << " : " << "CheckQStringNotNull" << "  failed"; \
      return EXIT_FAILURE;                                                                                                \
    }                                                                                                                     \
  }

#include "ctkAppLauncherTestingHelper.txx"

#endif
