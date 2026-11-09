/*=========================================================================

  Library:   CTK

  Copyright (c) Kitware Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0.txt

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

=========================================================================*/

// Qt includes
#include <QtTest/QtTest>

#define CTK_TEST_NOOP_MAIN(TestObject)    \
  int TestObject(int argc, char* argv[])  \
  {                                       \
    QObject tc;                           \
    return QTest::qExec(&tc, argc, argv); \
  }

#ifdef QT_GUI_LIB

//-----------------------------------------------------------------------------
# ifdef QT_MAC_USE_COCOA
// See http://doc.trolltech.com/4.7/qt.html#ApplicationAttribute-enum
// Setting the application to be a plugin will avoid the loading of qt_menu.nib files
#  define CTK_TEST_SKIP_NIB_MENU_LOADER QCoreApplication::setAttribute(Qt::AA_MacPluginApplication, true);
# else
#  define CTK_TEST_SKIP_NIB_MENU_LOADER
# endif

//-----------------------------------------------------------------------------
# define CTK_TEST_MAIN(TestObject)         \
   int TestObject(int argc, char* argv[])  \
   {                                       \
     CTK_TEST_SKIP_NIB_MENU_LOADER         \
     QApplication app(argc, argv);         \
     TestObject##er tc;                    \
     return QTest::qExec(&tc, argc, argv); \
   }

#else

//-----------------------------------------------------------------------------
# define CTK_TEST_MAIN(TestObject)         \
   int TestObject(int argc, char* argv[])  \
   {                                       \
     QCoreApplication app(argc, argv);     \
     QTEST_DISABLE_KEYPAD_NAVIGATION       \
     TestObject##er tc;                    \
     return QTest::qExec(&tc, argc, argv); \
   }

#endif // QT_GUI_LIB
