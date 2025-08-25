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

namespace ctkTest
{
static void mouseEvent(QTest::MouseAction action, QWidget* widget, Qt::MouseButton button, Qt::KeyboardModifiers stateKey, QPoint pos, int delay = -1)
{
  if (action != QTest::MouseMove)
  {
    QTest::mouseEvent(action, widget, button, stateKey, pos, delay);
    return;
  }
  QTEST_ASSERT(widget);
  // extern int Q_TESTLIB_EXPORT defaultMouseDelay();
  // if (delay == -1 || delay < defaultMouseDelay())
  //     delay = defaultMouseDelay();
  if (delay > 0)
    QTest::qWait(delay);

  if (pos.isNull())
    pos = widget->rect().center();

  QTEST_ASSERT(button == Qt::NoButton || button & Qt::MouseButtonMask);
  QTEST_ASSERT(stateKey == 0 || stateKey & Qt::KeyboardModifierMask);

  stateKey &= static_cast<unsigned int>(Qt::KeyboardModifierMask);

  QMouseEvent me(QEvent::User, QPoint(), Qt::LeftButton, button, stateKey);

  me = QMouseEvent(QEvent::MouseMove, pos, widget->mapToGlobal(pos), button, button, stateKey);
  QSpontaneKeyEvent::setSpontaneous(&me);
  if (!qApp->notify(widget, &me))
  {
    static const char* mouseActionNames[] = { "MousePress", "MouseRelease", "MouseClick", "MouseDClick", "MouseMove" };
    QString warning = QLatin1String("Mouse event \"%1\" not accepted by receiving widget");
    QTest::qWarn(warning.arg(QLatin1String(mouseActionNames[static_cast<int>(action)])).toLocal8Bit());
  }
}

inline void mouseMove(QWidget* widget, Qt::MouseButton button, Qt::KeyboardModifiers stateKey = 0, QPoint pos = QPoint(), int delay = -1)
{
  ctkTest::mouseEvent(QTest::MouseMove, widget, button, stateKey, pos, delay);
}

} // namespace ctkTest
