
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
  ${CMAKE_CURRENT_SOURCE_DIR}/App4TestStepPrerequisites.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/App4TestStepPrerequisites.cmake
  @ONLY
  )

#
# Helper macro
#
MACRO(APPLAUNCHER_ADD_CMAKESCRIPT_TEST testname script)
  ADD_TEST(cmake_${testname} ${CMAKE_COMMAND}
    -DTEST_${testname}:BOOL=ON
    -P ${CTKAppLauncher_SOURCE_DIR}/CMake/${script}.cmake)
  SET_TESTS_PROPERTIES(cmake_${testname} PROPERTIES
    LABELS ctkAppLauncher
    PASS_REGULAR_EXPRESSION "SUCCESS")
ENDMACRO()

#
# Add 'CMake script' Tests
#
APPLAUNCHER_ADD_CMAKESCRIPT_TEST(ctkAppLauncherListToQtSettingsArrayTest ctkAppLauncher)
APPLAUNCHER_ADD_CMAKESCRIPT_TEST(ctkAppLauncherAppendExtraAppToLaunchToListTest ctkAppLauncher)
APPLAUNCHER_ADD_CMAKESCRIPT_TEST(ctkAppLauncherExtraAppToLaunchListToQtSettingsTest ctkAppLauncher)

#
# Helper macro
#
MACRO(APPLAUNCHER_ADD_TEST testname depends)
  ADD_TEST(${testname} ${CMAKE_COMMAND}
    -DTEST_SOURCE_DIR:PATH=${CMAKE_CURRENT_SOURCE_DIR}
    -DTEST_BINARY_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}
    -P ${CMAKE_CURRENT_SOURCE_DIR}/${testname}.cmake)
  IF(NOT ${depends} STREQUAL "NODEPENDS")
    SET_TESTS_PROPERTIES(${testname} PROPERTIES DEPENDS ${depends})
  ENDIF()
  SET_PROPERTY(TEST ${testname} PROPERTY LABELS ctkAppLauncher)
ENDMACRO()

#
# Add Tests
#
APPLAUNCHER_ADD_TEST(App4TestConfigureStep NODEPENDS)
APPLAUNCHER_ADD_TEST(App4TestBuildStep App4TestConfigureStep)
APPLAUNCHER_ADD_TEST(AppLauncherTest1 App4TestBuildStep)
APPLAUNCHER_ADD_TEST(AppLauncherTest2 AppLauncherTest1)
APPLAUNCHER_ADD_TEST(AppLauncherTest3 AppLauncherTest2)
APPLAUNCHER_ADD_TEST(AppLauncherTest4 AppLauncherTest3)
APPLAUNCHER_ADD_TEST(AppLauncherTest5 AppLauncherTest4)
