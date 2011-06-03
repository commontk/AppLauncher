
set(LAUNCHER_BINARY_DIR ${CTKAppLauncher_BINARY_DIR})
set(LAUNCHER_NAME ${PROJECT_NAME})

set(APP4TEST_CMAKE_GENERATOR "${CMAKE_GENERATOR}")
set(APP4TEST_BUILD_TYPE "Release")
set(APP4TEST_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/App4Test)
set(APP4TEST_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/App4Test-build)

#
# Configure Test Prerequisites
#
configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/AppLauncherTestPrerequisites.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/AppLauncherTestPrerequisites.cmake
  @ONLY
  )

configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/AppLauncherTest1Prerequisites.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/AppLauncherTest1Prerequisites.cmake
  @ONLY
  )

MACRO(APPLAUNCHER_ADD_TEST testname depends)
  ADD_TEST(${testname} ${CMAKE_COMMAND}
    -DTEST_SOURCE_DIR:PATH=${CMAKE_CURRENT_SOURCE_DIR}
    -DTEST_BINARY_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}
    -P ${CMAKE_CURRENT_SOURCE_DIR}/${testname}.cmake.in)
  IF(NOT ${depends} STREQUAL "NODEPENDS")
    SET_TESTS_PROPERTIES(${testname} PROPERTIES DEPENDS ${depends})
  ENDIF()
  SET_PROPERTY(TEST ${testname} PROPERTY LABELS ctkAppLauncher)
ENDMACRO()

#
# Add Tests
#

APPLAUNCHER_ADD_TEST(AppLauncherTest1 NODEPENDS)
APPLAUNCHER_ADD_TEST(AppLauncherTest2 AppLauncherTest1)
APPLAUNCHER_ADD_TEST(AppLauncherTest3 AppLauncherTest2)
APPLAUNCHER_ADD_TEST(AppLauncherTest4 AppLauncherTest3)
APPLAUNCHER_ADD_TEST(AppLauncherTest5 AppLauncherTest4)
