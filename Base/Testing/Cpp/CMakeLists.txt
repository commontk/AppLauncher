set(KIT ${PROJECT_NAME})

create_test_sourcelist(Tests ${KIT}CppTests.cpp
  ctkCommandLineParserTest1.cpp
  ctkAppLauncherTest1.cpp
  #EXTRA_INCLUDE TestingMacros.h
  )

SET (TestsToRun ${Tests})
REMOVE (TestsToRun ${KIT}CppTests.cpp)

set(LIBRARY_NAME ${PROJECT_NAME})

add_executable(${KIT}CppTests ${Tests})
target_link_libraries(${KIT}CppTests ${LIBRARY_NAME} ${CTK_BASE_LIBRARIES})

if(QT_MAC_USE_COCOA)
  target_link_libraries(${KIT}CppTests "-framework cocoa")
endif()

set(KIT_TESTS ${CPP_TEST_PATH}/${KIT}CppTests)

set(label ctkAppLauncher)

macro( SIMPLE_TEST  TESTNAME )
  add_test( ${TESTNAME} ${KIT_TESTS} ${TESTNAME} )
  set_property(TEST ${TESTNAME} PROPERTY LABELS ${label})
endmacro( SIMPLE_TEST  )

#
# Add Tests
#

SIMPLE_TEST( ctkCommandLineParserTest1 )
SIMPLE_TEST( ctkAppLauncherTest1 )
set_tests_properties(ctkAppLauncherTest1 PROPERTIES DEPENDS ctkAppLauncherCommandLineParserTest1)
