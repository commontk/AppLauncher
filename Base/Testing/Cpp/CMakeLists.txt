set(KIT ${PROJECT_NAME})

create_test_sourcelist(Tests ${KIT}CppTests.cpp
  ctkCommandLineParserTest1.cpp
  ctkAppLauncherTest1.cpp
  )

add_executable(${KIT}CppTests ${Tests})
target_link_libraries(${KIT}CppTests ${KIT} ${CTK_BASE_LIBRARIES})

if(QT_MAC_USE_COCOA)
  target_link_libraries(${KIT}CppTests "-framework cocoa")
endif()

set(label ctkAppLauncher)

macro( SIMPLE_TEST TESTNAME )
  add_test(NAME ${TESTNAME} COMMAND $<TARGET_FILE:${KIT}CppTests> ${TESTNAME} )
  set_property(TEST ${TESTNAME} PROPERTY LABELS ${label})
endmacro( SIMPLE_TEST  )

#
# Add Tests
#

SIMPLE_TEST( ctkCommandLineParserTest1 )
SIMPLE_TEST( ctkAppLauncherTest1 )
