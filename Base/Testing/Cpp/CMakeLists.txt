set(KIT ${PROJECT_NAME})

include_directories(${CMAKE_CURRENT_BINARY_DIR})
set(KIT_TEST_SRCS
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
set(${KIT}CppTests_TARGET_LIBRARIES
  CTKAppLauncherBase
  )
if(CTKAppLauncher_QT_VERSION VERSION_GREATER "4")
  list(APPEND ${KIT}CppTests_TARGET_LIBRARIES Qt5::Test)
else()
  list(APPEND ${KIT}CppTests_TARGET_LIBRARIES Qt4::QtTest)
endif()
target_link_libraries(${KIT}CppTests PUBLIC ${${KIT}CppTests_TARGET_LIBRARIES})

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

add_simple_test(ctkAppArgumentsTest XDisplayRequired)
add_simple_test(ctkAppLauncherTest1 XDisplayRequired)
add_simple_test(ctkAppLauncherSettingsTest XDisplayRequired)
add_simple_test(ctkCommandLineParserTest1)
