
// CTK includes
#include <ctkAppArguments.h>
#include <ctkTest.h>


// ----------------------------------------------------------------------------
class ctkAppArgumentsTester : public QObject
{
  Q_OBJECT
  typedef ctkAppArgumentsTester Self;

public:
  typedef ctkAppArguments::ArgToFilterType ArgToFilterType;
  typedef ctkAppArguments::ArgToFilterListType ArgToFilterListType;

private:

  QStringList InputArguments;
  QStringList RegularArguments;
  QStringList ReservedArguments;
  ArgToFilterListType ArgToFilterList;
  ArgToFilterListType ExpectedArgToFilterList;

private slots:

  void initTestCase();

  void testArguments();
  void testArguments_data();

  void testArgumentValues();
  void testArgumentValues_data();

  void testArgumentCount();
  void testArgumentCount_data();

  void testAddArgumentToFilter();
  void testAddArgumentToFilter_data();

  void testSetArgumentToFilterList();
  void testSetArgumentToFilterList_data();

};

Q_DECLARE_METATYPE(ctkAppArguments::ArgListTypes)
Q_DECLARE_METATYPE(ctkAppArguments::ArgToFilterType)
Q_DECLARE_METATYPE(ctkAppArguments::ArgToFilterListType)

// ----------------------------------------------------------------------------
void ctkAppArgumentsTester::initTestCase()
{
  this->InputArguments = QStringList()
      << "--rarg1" << "rargvalue1"
      << "-rarg2" << "rargvalue2"
      << "-s" << "1"
      << "-rarg3=rargvalue3"
      << "--rarg4=rargvalue4"
      << "-rarg5"
      << "--help"
      << "-rarg6" << "rargvalue6"
      << "-rarg6=rargvalue6"
      << "-rarg7=rargvalue7"
      << "-rarg8" << "rargvalue8"
      << "-rarg8=rargvalue8"
      << "--rarg9"
      << "-rarg10" << "windows:dialogs=xp,fontengine=freetype"
      << "-rarg11" << "windows:dpiawareness=0,1,2";

  this->RegularArguments = QStringList()
      << "-s" << "1"
      << "--help";

  this->ReservedArguments = QStringList()
      << "--rarg1" << "rargvalue1"
      << "-rarg2" << "rargvalue2"
      << "-rarg3=rargvalue3"
      << "--rarg4=rargvalue4"
      << "-rarg5"
      << "-rarg6" << "rargvalue6"
      << "-rarg6=rargvalue6"
      << "-rarg7=rargvalue7"
      << "-rarg8" << "rargvalue8"
      << "-rarg8=rargvalue8"
      << "--rarg9"
      << "-rarg10" << "windows:dialogs=xp,fontengine=freetype"
      << "-rarg11" << "windows:dpiawareness=0,1,2";

  ArgToFilterListType argToFilterList = ArgToFilterListType()
      << ArgToFilterType("--rarg1", ctkAppArguments::ARG_TO_FILTER_SPACE_VALUE)
      << ArgToFilterType("-rarg2", ctkAppArguments::ARG_TO_FILTER_SPACE_VALUE)
      << ArgToFilterType("-rarg3", ctkAppArguments::ARG_TO_FILTER_EQUAL_VALUE)
      << ArgToFilterType("--rarg4", ctkAppArguments::ARG_TO_FILTER_EQUAL_VALUE)
      << ArgToFilterType("-rarg5", ctkAppArguments::ARG_TO_FILTER_NO_VALUE)
      << ArgToFilterType("-rarg6", ctkAppArguments::ARG_TO_FILTER_EQUAL_VALUE)
      << ArgToFilterType("-rarg6", ctkAppArguments::ARG_TO_FILTER_SPACE_VALUE)
      << ArgToFilterType("-rarg7=", ctkAppArguments::ARG_TO_FILTER_EQUAL_VALUE);

  this->ArgToFilterList = ArgToFilterListType()
      << argToFilterList
      << ArgToFilterType("-rarg8", ctkAppArguments::ARG_TO_FILTER_SPACE_VALUE | ctkAppArguments::ARG_TO_FILTER_EQUAL_VALUE)
      << ArgToFilterType("--rarg9")
      << ArgToFilterType("-rarg10", ctkAppArguments::ARG_TO_FILTER_SPACE_VALUE)
      << ArgToFilterType("-rarg11", ctkAppArguments::ARG_TO_FILTER_SPACE_VALUE);

  this->ExpectedArgToFilterList = ArgToFilterListType()
      << argToFilterList
      << ArgToFilterType("-rarg8", ctkAppArguments::ARG_TO_FILTER_EQUAL_VALUE)
      << ArgToFilterType("-rarg8", ctkAppArguments::ARG_TO_FILTER_SPACE_VALUE)
      << ArgToFilterType("--rarg9", ctkAppArguments::ARG_TO_FILTER_NO_VALUE)
      << ArgToFilterType("-rarg10", ctkAppArguments::ARG_TO_FILTER_SPACE_VALUE)
      << ArgToFilterType("-rarg11", ctkAppArguments::ARG_TO_FILTER_SPACE_VALUE);
}

// ----------------------------------------------------------------------------
void ctkAppArgumentsTester::testArguments()
{
  QFETCH(QStringList, inputArguments);
  QFETCH(ctkAppArguments::ArgListTypes, filteringOption);
  QFETCH(ArgToFilterListType, argToFilterList);
  QFETCH(QStringList, expectedArguments);

  ctkChar2DArray inputArgv(inputArguments);

  ctkAppArguments appArguments(inputArgv.count(), inputArgv.values());
  appArguments.setArgumentToFilterList(argToFilterList);

  QCOMPARE(appArguments.arguments(filteringOption), expectedArguments);
}

// ----------------------------------------------------------------------------
void ctkAppArgumentsTester::testArguments_data()
{
  QTest::addColumn<QStringList>("inputArguments");
  QTest::addColumn<ctkAppArguments::ArgListTypes>("filteringOption");
  QTest::addColumn<ArgToFilterListType>("argToFilterList");
  QTest::addColumn<QStringList>("expectedArguments");

  QTest::newRow("0") << this->InputArguments
                     << ctkAppArguments::ArgListTypes(ctkAppArguments::ARG_FULL_LIST)
                     << (ArgToFilterListType())
                     << this->InputArguments;

  QTest::newRow("1") << this->InputArguments
                     << ctkAppArguments::ArgListTypes(ctkAppArguments::ARG_REGULAR_LIST)
                     << (ArgToFilterListType())
                     << this->InputArguments;

  QTest::newRow("2") << this->InputArguments
                     << ctkAppArguments::ArgListTypes(ctkAppArguments::ARG_RESERVED_LIST)
                     << (ArgToFilterListType())
                     << QStringList();

  QTest::newRow("3") << this->InputArguments
                     << ctkAppArguments::ArgListTypes(ctkAppArguments::ARG_FULL_LIST)
                     << this->ArgToFilterList
                     << this->InputArguments;

  QTest::newRow("4") << this->InputArguments
                     << ctkAppArguments::ArgListTypes(ctkAppArguments::ARG_REGULAR_LIST)
                     << this->ArgToFilterList
                     << this->RegularArguments;

  QTest::newRow("5") << this->InputArguments
                     << ctkAppArguments::ArgListTypes(ctkAppArguments::ARG_RESERVED_LIST)
                     << this->ArgToFilterList
                     << this->ReservedArguments;
}

// ----------------------------------------------------------------------------
void ctkAppArgumentsTester::testArgumentValues()
{
  QFETCH(QStringList, inputArguments);
  QFETCH(ctkAppArguments::ArgListTypes, filteringOption);
  QFETCH(ArgToFilterListType, argToFilterList);
  QFETCH(QStringList, expectedArguments);

  ctkChar2DArray inputArgv(inputArguments);

  ctkAppArguments appArguments(inputArgv.count(), inputArgv.values());
  foreach (const Self::ArgToFilterType& argToFilter, argToFilterList)
  {
    appArguments.addArgumentToFilter(argToFilter);
  }

  char** filtedArgumentsAsCharStarArray = appArguments.argumentValues(QFlags<ctkAppArguments::ArgListType>(filteringOption));
  QStringList filtedArguments;
  for (int index = 0; index < appArguments.argumentCount(QFlags<ctkAppArguments::ArgListType>(filteringOption)); ++index)
  {
    filtedArguments << filtedArgumentsAsCharStarArray[index];
  }
  QCOMPARE(filtedArguments, expectedArguments);
}

// ----------------------------------------------------------------------------
void ctkAppArgumentsTester::testArgumentValues_data()
{
  this->testArguments_data();
}

// ----------------------------------------------------------------------------
void ctkAppArgumentsTester::testArgumentCount()
{
  QFETCH(QStringList, inputArguments);
  QFETCH(ctkAppArguments::ArgListTypes, filteringOption);
  QFETCH(ArgToFilterListType, argToFilterList);
  QFETCH(int, expectedArgumentCount);

  ctkChar2DArray inputArgv(inputArguments);

  ctkAppArguments appArguments(inputArgv.count(), inputArgv.values());
  foreach (const Self::ArgToFilterType& argToFilter, argToFilterList)
  {
    appArguments.addArgumentToFilter(argToFilter);
  }

  QCOMPARE(appArguments.arguments(QFlags<ctkAppArguments::ArgListType>(filteringOption)).count(),
           expectedArgumentCount);
}

// ----------------------------------------------------------------------------
void ctkAppArgumentsTester::testArgumentCount_data()
{
  QTest::addColumn<QStringList>("inputArguments");
  QTest::addColumn<ctkAppArguments::ArgListTypes>("filteringOption");
  QTest::addColumn<ArgToFilterListType>("argToFilterList");
  QTest::addColumn<int>("expectedArgumentCount");

  QTest::newRow("0") << this->InputArguments
                     << ctkAppArguments::ArgListTypes(ctkAppArguments::ARG_FULL_LIST)
                     << (ArgToFilterListType())
                     << this->InputArguments.count();

  QTest::newRow("1") << this->InputArguments
                     << ctkAppArguments::ArgListTypes(ctkAppArguments::ARG_REGULAR_LIST)
                     << (ArgToFilterListType())
                     << this->InputArguments.count();

  QTest::newRow("2") << this->InputArguments
                     << ctkAppArguments::ArgListTypes(ctkAppArguments::ARG_RESERVED_LIST)
                     << (ArgToFilterListType())
                     << QStringList().count();

  QTest::newRow("3") << this->InputArguments
                     << ctkAppArguments::ArgListTypes(ctkAppArguments::ARG_FULL_LIST)
                     << this->ArgToFilterList
                     << this->InputArguments.count();

  QTest::newRow("4") << this->InputArguments
                     << ctkAppArguments::ArgListTypes(ctkAppArguments::ARG_REGULAR_LIST)
                     << this->ArgToFilterList
                     << this->RegularArguments.count();

  QTest::newRow("5") << this->InputArguments
                     << ctkAppArguments::ArgListTypes(ctkAppArguments::ARG_RESERVED_LIST)
                     << this->ArgToFilterList
                     << this->ReservedArguments.count();
}

// ----------------------------------------------------------------------------
void ctkAppArgumentsTester::testAddArgumentToFilter()
{
  QFETCH(ArgToFilterListType, argToFilterList);
  QFETCH(ArgToFilterListType, expectedArgToFilterList);

  ctkChar2DArray inputArgv;
  ctkAppArguments appArguments(inputArgv.count(), inputArgv.values());
  QVERIFY(appArguments.argumentToFilterList().isEmpty());

  foreach (const ArgToFilterType& argToFilter, argToFilterList)
  {
    appArguments.addArgumentToFilter(argToFilter);
  }
  QCOMPARE(appArguments.argumentToFilterList(), expectedArgToFilterList);
}

// ----------------------------------------------------------------------------
void ctkAppArgumentsTester::testAddArgumentToFilter_data()
{
  QTest::addColumn<ArgToFilterListType>("argToFilterList");
  QTest::addColumn<ArgToFilterListType>("expectedArgToFilterList");

  QTest::newRow("0") << this->ArgToFilterList
                     << this->ExpectedArgToFilterList;
}

// ----------------------------------------------------------------------------
void ctkAppArgumentsTester::testSetArgumentToFilterList()
{
  QFETCH(ArgToFilterListType, argToFilterList);
  QFETCH(ArgToFilterListType, expectedArgToFilterList);

  ctkChar2DArray inputArgv;
  ctkAppArguments appArguments(inputArgv.count(), inputArgv.values());
  QVERIFY(appArguments.argumentToFilterList().isEmpty());
  appArguments.setArgumentToFilterList(argToFilterList);
  QCOMPARE(appArguments.argumentToFilterList(), expectedArgToFilterList);
}

// ----------------------------------------------------------------------------
void ctkAppArgumentsTester::testSetArgumentToFilterList_data()
{
  this->testAddArgumentToFilter_data();
}

// ----------------------------------------------------------------------------
CTK_TEST_MAIN(ctkAppArgumentsTest)
#include "moc_ctkAppArgumentsTest.cpp"
