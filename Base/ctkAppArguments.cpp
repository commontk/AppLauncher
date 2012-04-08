
// Qt includes
#include <QList>
#include <QPair>
#include <QStringList>

// CTK includes
#include "ctkAppArguments.h"

// --------------------------------------------------------------------------
// ctkChar2DArrayPrivate

// --------------------------------------------------------------------------
class ctkChar2DArrayPrivate
{
public:
  ctkChar2DArrayPrivate() : Values(0), Count(0) {}
  virtual ~ctkChar2DArrayPrivate(){}
  char** Values;
  int Count;
  QStringList List;
};

// --------------------------------------------------------------------------
// ctkChar2DArray methods

// --------------------------------------------------------------------------
ctkChar2DArray::ctkChar2DArray() : d_ptr(new ctkChar2DArrayPrivate)
{
  this->setValues(QStringList());
}

// --------------------------------------------------------------------------
ctkChar2DArray::ctkChar2DArray(const QStringList& list) : d_ptr(new ctkChar2DArrayPrivate)
{
  this->setValues(list);
}

// --------------------------------------------------------------------------
ctkChar2DArray::~ctkChar2DArray()
{
  this->clear();
}

// --------------------------------------------------------------------------
void ctkChar2DArray::setValues(const QStringList& list)
{
  Q_D(ctkChar2DArray);
  this->clear();
  if (list.isEmpty())
    {
    return;
    }
  d->List = list;
  d->Count = list.count();
  d->Values = new char*[list.count()];
  for(int index = 0; index < d->List.count(); ++index)
    {
    QString item = d->List.at(index);
    d->Values[index] = new char[item.size() + 1];
    qstrcpy(d->Values[index], item.toLatin1().data());
    }
}

// --------------------------------------------------------------------------
void ctkChar2DArray::clear()
{
  Q_D(ctkChar2DArray);
  for (int index = 0; index < d->List.count(); ++index)
    {
    delete[] d->Values[index];
    }
  delete [] d->Values;
  d->Values = 0;
  d->Count = 0;
  d->List.clear();
}

// --------------------------------------------------------------------------
char** ctkChar2DArray::values()const
{
  Q_D(const ctkChar2DArray);
  return d->Values;
}

// --------------------------------------------------------------------------
int &ctkChar2DArray::count()
{
  Q_D(ctkChar2DArray);
  return d->Count;
}

// --------------------------------------------------------------------------
// ctkAppArgumentsPrivate

//-----------------------------------------------------------------------------
class ctkAppArgumentsPrivate
{
public:
  ctkAppArgumentsPrivate(int &argc, char **argv);
  virtual ~ctkAppArgumentsPrivate();

  void filterArguments();

  ctkAppArguments::ArgToFilterType findArgToFilter(const char* arg);

  void addArgumentToFilter(const ctkAppArguments::ArgToFilterType &argToFilter, bool filter);

  int &Argc;
  char **Argv;

  ctkAppArguments::ArgToFilterListType ArgToFilterList;

  QStringList Arguments;
  QStringList RegularArguments;
  QStringList ReservedArguments;
  ctkChar2DArray RegularArgumentsAsCharStarArray;
  ctkChar2DArray ReservedArgumentsAsCharStarArray;
};

// --------------------------------------------------------------------------
// ctkAppArgumentsPrivate methods

// --------------------------------------------------------------------------
ctkAppArgumentsPrivate::ctkAppArgumentsPrivate(int &argc, char **argv) :
  Argc(argc), Argv(argv)
{
  static const char *const empty = "";
  if (this->Argc == 0 || this->Argv == 0)
    {
    this->Argc = 0;
    this->Argv = const_cast<char **>(&empty);
    }
  for(int index = 0; index < this->Argc; ++index)
    {
    this->Arguments << this->Argv[index];
    }
  this->filterArguments();
}

// --------------------------------------------------------------------------
ctkAppArgumentsPrivate::~ctkAppArgumentsPrivate()
{
}

// --------------------------------------------------------------------------
void ctkAppArgumentsPrivate::filterArguments()
{
  this->RegularArguments.clear();
  this->ReservedArguments.clear();

  for(int index = 0; index < this->Argc; ++index)
    {
    ctkAppArguments::ArgToFilterType argToFilter = this->findArgToFilter(this->Argv[index]);
    if (argToFilter.first.isEmpty())
      {
      this->RegularArguments << this->Argv[index];
      continue;
      }
    if (argToFilter.second == ctkAppArguments::ARG_TO_FILTER_NO_VALUE ||
        argToFilter.second & ctkAppArguments::ARG_TO_FILTER_EQUAL_VALUE)
      {
      this->ReservedArguments << this->Argv[index];
      continue;
      }
    else if (argToFilter.second & ctkAppArguments::ARG_TO_FILTER_SPACE_VALUE)
      {
      this->ReservedArguments << this->Argv[index];
      if (index + 1 < this->Argc)
        {
        this->ReservedArguments << this->Argv[index + 1];
        ++index;
        continue;
        }
      }
    Q_ASSERT(false);
    }
  this->RegularArgumentsAsCharStarArray.setValues(this->RegularArguments);
  this->ReservedArgumentsAsCharStarArray.setValues(this->ReservedArguments);
}

// --------------------------------------------------------------------------
ctkAppArguments::ArgToFilterType ctkAppArgumentsPrivate::findArgToFilter(const char* arg)
{
  if (arg == 0)
    {
    return ctkAppArguments::ArgToFilterType();
    }

  foreach(const ctkAppArguments::ArgToFilterType& argToFilter, this->ArgToFilterList)
    {
    if (argToFilter.second == ctkAppArguments::ARG_TO_FILTER_NO_VALUE)
      {
      if (arg == argToFilter.first)
        {
        return argToFilter;
        }
      }
    else if (argToFilter.second & ctkAppArguments::ARG_TO_FILTER_EQUAL_VALUE)
      {
      if (QString(arg).startsWith(
            argToFilter.first.endsWith("=") ? argToFilter.first : QString(argToFilter.first).append("=")))
        {
        return argToFilter;
        }
      }
    else if (argToFilter.second & ctkAppArguments::ARG_TO_FILTER_SPACE_VALUE)
      {
      if (arg == argToFilter.first)
        {
        return argToFilter;
        }
      }
    }
  return ctkAppArguments::ArgToFilterType();
}

// --------------------------------------------------------------------------
void ctkAppArgumentsPrivate::addArgumentToFilter(const ctkAppArguments::ArgToFilterType &argToFilter, bool filter)
{
  if (argToFilter.second & ctkAppArguments::ARG_TO_FILTER_EQUAL_VALUE)
    {
    this->ArgToFilterList << ctkAppArguments::ArgToFilterType(argToFilter.first, ctkAppArguments::ARG_TO_FILTER_EQUAL_VALUE);
    }
  if (argToFilter.second & ctkAppArguments::ARG_TO_FILTER_SPACE_VALUE)
    {
    this->ArgToFilterList << ctkAppArguments::ArgToFilterType(argToFilter.first, ctkAppArguments::ARG_TO_FILTER_SPACE_VALUE);
    }
  if (argToFilter.second == ctkAppArguments::ARG_TO_FILTER_NO_VALUE)
    {
    this->ArgToFilterList << ctkAppArguments::ArgToFilterType(argToFilter.first, ctkAppArguments::ARG_TO_FILTER_NO_VALUE);
    }
  if (filter)
    {
    this->filterArguments();
    }
}

// --------------------------------------------------------------------------
// ctkAppArguments methods

// --------------------------------------------------------------------------
ctkAppArguments::ctkAppArguments(int &argc, char *argv[]):
  d_ptr(new ctkAppArgumentsPrivate(argc, argv))
{
}

// --------------------------------------------------------------------------
ctkAppArguments::~ctkAppArguments()
{
}

// --------------------------------------------------------------------------
QStringList ctkAppArguments::arguments(ctkAppArguments::ArgListTypes option)const
{
  Q_D(const ctkAppArguments);
  if (option == ctkAppArguments::ARG_REGULAR_LIST)
    {
    return d->RegularArguments;
    }
  else if (option == ctkAppArguments::ARG_RESERVED_LIST)
    {
    return d->ReservedArguments;
    }
  else //if (option == ctkAppArguments::ARG_FULL_LIST)
    {
    return d->Arguments;
    }
}

// --------------------------------------------------------------------------
char** ctkAppArguments::argumentValues(ctkAppArguments::ArgListTypes option) const
{
  Q_D(const ctkAppArguments);
  if (option == ctkAppArguments::ARG_REGULAR_LIST)
    {
    return d->RegularArgumentsAsCharStarArray.values();
    }
  else if (option == ctkAppArguments::ARG_RESERVED_LIST)
    {
    return d->ReservedArgumentsAsCharStarArray.values();
    }
  else // if (option == ctkAppArguments::ARG_FULL_LIST)
    {
    return d->Argv;
    }
}

// --------------------------------------------------------------------------
int& ctkAppArguments::argumentCount(ctkAppArguments::ArgListTypes option)
{
  Q_D(ctkAppArguments);
  if (option == ctkAppArguments::ARG_REGULAR_LIST)
    {
    return d->RegularArgumentsAsCharStarArray.count();
    }
  else if (option == ctkAppArguments::ARG_RESERVED_LIST)
    {
    return d->ReservedArgumentsAsCharStarArray.count();
    }
  else // if (option == ctkAppArguments::ARG_FULL_LIST)
    {
    return d->Argc;
    }
}

// --------------------------------------------------------------------------
void ctkAppArguments::addArgumentToFilter(const ArgToFilterType &argToFilter)
{
  Q_D(ctkAppArguments);
  d->addArgumentToFilter(argToFilter, /* filter = */ true);
}

// --------------------------------------------------------------------------
ctkAppArguments::ArgToFilterListType ctkAppArguments::argumentToFilterList()const
{
  Q_D(const ctkAppArguments);
  return d->ArgToFilterList;
}

// --------------------------------------------------------------------------
void ctkAppArguments::setArgumentToFilterList(const ArgToFilterListType& list)
{
  Q_D(ctkAppArguments);
  d->ArgToFilterList.clear();
  foreach(const ArgToFilterType& argToFilter, list)
    {
    d->addArgumentToFilter(argToFilter, /* filter = */ false);
    }
  d->filterArguments();
}
