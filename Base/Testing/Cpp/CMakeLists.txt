set(KIT ${PROJECT_NAME})

include_directories(${CMAKE_CURRENT_BINARY_DIR})
set(KIT_TEST_SRCS
  ctkAppArgumentsTest.cpp
  ctkAppLauncherTest1.cpp
  ctkCommandLineParserTest1.cpp
  )
create_test_sourcelist(Tests ${KIT}CppTests.cpp
  ${KIT_TEST_SRCS}
  )


foreach(file IN ITEMS
    ctkAppArgumentsTest.cpp
    ctkAppLauncherTest1.cpp
    )
  set(moc_file moc_${file})
  QT4_GENERATE_MOC(${file} ${moc_file})
  macro_add_file_dependencies(${file} ${CMAKE_CURRENT_BINARY_DIR}/${moc_file})
endforeach()

add_executable(${KIT}CppTests ${Tests})
target_link_libraries(${KIT}CppTests PUBLIC
  CTKAppLauncherBase
  Qt4::QtTest
  )

if(QT_MAC_USE_COCOA)
  target_link_libraries(${KIT}CppTests PRIVATE "-framework cocoa -framework IOKit")
endif()

set(label ctkAppLauncher)

macro( SIMPLE_TEST TESTNAME )
  add_test(NAME ${TESTNAME} COMMAND $<TARGET_FILE:${KIT}CppTests> ${TESTNAME} )
  set_property(TEST ${TESTNAME} PROPERTY LABELS ${label})
endmacro( SIMPLE_TEST  )

#
# Add Tests
#

SIMPLE_TEST( ctkAppArgumentsTest )
SIMPLE_TEST( ctkAppLauncherTest1 )
SIMPLE_TEST( ctkCommandLineParserTest1 )
