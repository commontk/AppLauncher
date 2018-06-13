
// Qt includes
#include <QDebug>

//----------------------------------------------------------------------------
// Copied from CTK/Libs/Core/ctkCoreTestingUtilities.{h,cpp,tpp}
template<typename TYPE>
bool CheckList(int line, const QString& description,
               const QList<TYPE>& current, const QList<TYPE>& expected,
               const QString& testName)
{
  QString msg;
  if (current.count() != expected.count())
    {
    qWarning() << "\nLine " << line << " - " << description
               << " : " << testName << " failed"
               << "\nCompared lists have different sizes."
               << "\n\tcurrent size :" << current.count()
               << "\n\texpected size:" << expected.count()
               << "\n\tcurrent:" << current
               << "\n\texpected:" << expected;
    return false;
    }
  for (int idx = 0; idx < current.count(); ++idx)
    {
    if (current.at(idx) != expected.at(idx))
      {
      qWarning() << "\nLine " << line << " - " << description
                 << " : " << testName << " failed"
                 << "\nCompared lists differ at index " << idx
                 << "\n\tcurrent[" << idx << "] :" << current.at(idx)
                 << "\n\texpected[" << idx << "]:" << expected.at(idx)
                 << "\n\tcurrent:" << current
                 << "\n\texpected:" << expected;
      return false;
      }
    }
  return true;
}

//----------------------------------------------------------------------------
// Copied from CTK/Libs/Core/ctkCoreTestingUtilities.{h,cpp,tpp}
template<typename TYPE>
bool Check(int line, const QString& description,
           TYPE current, TYPE expected,
           const QString& _testName,
           bool errorIfDifferent)
{
  QString testName = _testName.isEmpty() ? "Check" : _testName;
  if (errorIfDifferent)
    {
    if(current != expected)
      {
      qWarning() << "\nLine " << line << " - " << description
                 << " : " << testName << " failed"
                 << "\n\tcurrent :" << current
                 << "\n\texpected:" << expected;
      return false;
      }
    }
  else
    {
    if(current == expected)
      {
      qWarning() << "\nLine " << line << " - " << description
                 << " : " << testName << " failed"
                 << "\n\tcurrent :" << current
                 << "\n\texpected to be different from:" << expected;
      return false;
      }
    }
  return true;
}
