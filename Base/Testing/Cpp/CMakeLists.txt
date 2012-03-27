set(KIT ${PROJECT_NAME})

include_directories(${CMAKE_CURRENT_BINARY_DIR})
set(KIT_TEST_SRCS
  ctkAppLauncherTest1.cpp
  ctkCommandLineParserTest1.cpp
  )
create_test_sourcelist(Tests ${KIT}CppTests.cpp
  ${KIT_TEST_SRCS}
  )

QT4_GENERATE_MOCS(
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

SIMPLE_TEST( ctkAppLauncherTest1 )
SIMPLE_TEST( ctkCommandLineParserTest1 )
