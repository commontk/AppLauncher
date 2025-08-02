set(KIT ${PROJECT_NAME})

if(CTKAppLauncher_QT_VERSION VERSION_GREATER "4" AND WIN32)
  set(CMAKE_TESTDRIVER_EXTRA_INCLUDES "${CMAKE_TESTDRIVER_EXTRA_INCLUDES}
  #include <QtPlugin>
  #if (defined QT_STATIC)
  Q_IMPORT_PLUGIN(QWindowsIntegrationPlugin)
  #endif
  ")
endif()

if(CTKAppLauncher_QT_VERSION VERSION_GREATER "4" AND UNIX AND NOT APPLE)
  set(CMAKE_TESTDRIVER_EXTRA_INCLUDES "${CMAKE_TESTDRIVER_EXTRA_INCLUDES}
  #include <QtPlugin>
  #if (defined QT_STATIC)
  Q_IMPORT_PLUGIN(QXcbIntegrationPlugin)
  #endif
  ")
endif()

add_library(CTKAppLauncherTestingHelper STATIC
  ctkAppLauncherTestingHelper.cpp
  ctkAppLauncherTestingHelper.h
  ctkAppLauncherTestingHelper.txx
  )
target_link_libraries(CTKAppLauncherTestingHelper PUBLIC ${QT_LIBRARIES})

include_directories(${CMAKE_CURRENT_BINARY_DIR})
set(KIT_TEST_SRCS
  ctkAppLauncherEnvironmentTest.cpp
  ctkAppArgumentsTest.cpp
  ctkAppLauncherTest1.cpp
  ctkAppLauncherSettingsTest.cpp
  ctkCommandLineParserTest1.cpp
  )
create_test_sourcelist(Tests ${KIT}CppTests.cpp
  ${KIT_TEST_SRCS}
  )

include(MacroAddFileDependencies)

foreach(file IN ITEMS
    ctkAppLauncherEnvironmentTest.cpp
    ctkAppArgumentsTest.cpp
    ctkAppLauncherTest1.cpp
    ctkAppLauncherSettingsTest.cpp
    )
  set(moc_file moc_${file})
  if(CTKAppLauncher_QT_VERSION VERSION_GREATER "4")
    QT5_GENERATE_MOC(${file} ${moc_file})
  else()
    QT4_GENERATE_MOC(${file} ${moc_file})
  endif()
  macro_add_file_dependencies(${file} ${CMAKE_CURRENT_BINARY_DIR}/${moc_file})
endforeach()

add_executable(${KIT}CppTests ${Tests})
target_include_directories(${KIT}CppTests PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}
  )
set(${KIT}CppTests_TARGET_LIBRARIES
  CTKAppLauncherBase
  CTKAppLauncherTestingHelper
  )
if(CTKAppLauncher_QT_VERSION VERSION_GREATER "4")
  list(APPEND ${KIT}CppTests_TARGET_LIBRARIES Qt5::Test)
else()
  list(APPEND ${KIT}CppTests_TARGET_LIBRARIES Qt4::QtTest)
endif()
target_link_libraries(${KIT}CppTests PUBLIC ${${KIT}CppTests_TARGET_LIBRARIES} ${QT_LIBRARIES})

if(QT_MAC_USE_COCOA)
  target_link_libraries(${KIT}CppTests PRIVATE "-framework cocoa -framework IOKit")
endif()

set(label ctkAppLauncher)

macro(add_simple_test TESTNAME)
  add_test(NAME ${TESTNAME} COMMAND $<TARGET_FILE:${KIT}CppTests> ${TESTNAME} )
  set_property(TEST ${TESTNAME} PROPERTY LABELS ${label} ${ARGN})
endmacro()

#
# Add Tests
#

add_simple_test(ctkAppLauncherEnvironmentTest XDisplayRequired)
add_simple_test(ctkAppArgumentsTest XDisplayRequired)
add_simple_test(ctkAppLauncherTest1 XDisplayRequired)
add_simple_test(ctkAppLauncherSettingsTest XDisplayRequired)
add_simple_test(ctkCommandLineParserTest1)
