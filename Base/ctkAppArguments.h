#ifndef __ctkAppArguments_h
#define __ctkAppArguments_h

// Qt includes
#include <QPair>
#include <QScopedPointer>

// --------------------------------------------------------------------------
class ctkChar2DArrayPrivate;
class QStringList;

// --------------------------------------------------------------------------
class ctkChar2DArray
{
public:
  ctkChar2DArray();
  ctkChar2DArray(const QStringList& list);
  virtual ~ctkChar2DArray();
  void setValues(const QStringList& list);
  void clear();
  char** values()const;
  int& count();
protected:
  QScopedPointer<ctkChar2DArrayPrivate> d_ptr;

private:
  Q_DECLARE_PRIVATE(ctkChar2DArray)
  Q_DISABLE_COPY(ctkChar2DArray)
};

// --------------------------------------------------------------------------
class ctkAppArgumentsPrivate;
template <typename T> class QList;

// --------------------------------------------------------------------------
class ctkAppArguments
{
public:
  typedef ctkAppArguments Self;
  ctkAppArguments(int& argc, char* argv[]);
  ~ctkAppArguments();

  enum ArgListType
    {
    ARG_RESERVED_LIST = 0x1,
    ARG_REGULAR_LIST = 0x2,
    ARG_FULL_LIST = ARG_RESERVED_LIST & ARG_REGULAR_LIST
    };
  Q_DECLARE_FLAGS(ArgListTypes, ArgListType)

  QStringList arguments(ArgListTypes option = ARG_FULL_LIST)const;

  char** argumentValues(ArgListTypes option = ARG_FULL_LIST) const;

  int& argumentCount(ArgListTypes option = ARG_FULL_LIST);

  enum ArgToFilterOption
    {
    ARG_TO_FILTER_NO_VALUE = 0x0,
    ARG_TO_FILTER_EQUAL_VALUE = 0x1,
    ARG_TO_FILTER_SPACE_VALUE = 0x2
    };
  Q_DECLARE_FLAGS(ArgToFilterOptions, ArgToFilterOption)

  class ArgToFilterType : public QPair<QString, ArgToFilterOptions>
  {
  public:
    typedef QPair<QString, ctkAppArguments::ArgToFilterOptions> Superclass;
    ArgToFilterType():Superclass(){}
    ArgToFilterType(const QString& arg, ctkAppArguments::ArgToFilterOptions options = ARG_TO_FILTER_NO_VALUE) :
      Superclass(arg, options){}
  };
  typedef QList< ArgToFilterType > ArgToFilterListType;

  void addArgumentToFilter(const ArgToFilterType& argToFilter);

  ArgToFilterListType argumentToFilterList()const;

  void setArgumentToFilterList(const ArgToFilterListType& list);

protected:
  QScopedPointer<ctkAppArgumentsPrivate> d_ptr;

private:
  Q_DECLARE_PRIVATE(ctkAppArguments)
  Q_DISABLE_COPY(ctkAppArguments)
};

Q_DECLARE_OPERATORS_FOR_FLAGS(ctkAppArguments::ArgToFilterOptions);

#endif
