
set(LAUNCHER_BINARY_DIR ${CTKAppLauncher_BINARY_DIR})
set(LAUNCHER_NAME ${PROJECT_NAME})
set(LAUNCHER_VERSION ${CTKAppLauncher_VERSION})

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
macro(applauncher_add_cmakescript_test testname script)
  add_test(cmake_${testname} ${CMAKE_COMMAND}
    -DTEST_${testname}:BOOL=ON
    -P ${CTKAppLauncher_SOURCE_DIR}/CMake/${script}.cmake)
  set_tests_properties(cmake_${testname} PROPERTIES
    LABELS ctkAppLauncher
    PASS_REGULAR_EXPRESSION "SUCCESS")
endmacro()

#
# Add 'CMake script' Tests
#
applauncher_add_cmakescript_test(ctkAppLauncherListToQtSettingsArrayTest ctkAppLauncher)
applauncher_add_cmakescript_test(ctkAppLauncherAppendExtraAppToLaunchToListTest ctkAppLauncher)
applauncher_add_cmakescript_test(ctkAppLauncherExtraAppToLaunchListToQtSettingsTest ctkAppLauncher)
applauncher_add_cmakescript_test(midas_api_file_size_test MIDASAPICore)

#
# Helper macro
#
set(_previous_applauncher_test "NODEPENDS")
macro(applauncher_add_test testname)
  add_test(${testname} ${CMAKE_COMMAND}
    -DTEST_SOURCE_DIR:PATH=${CMAKE_CURRENT_SOURCE_DIR}
    -DTEST_BINARY_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}
    -P ${CMAKE_CURRENT_SOURCE_DIR}/${testname}.cmake)
  if(NOT ${_previous_applauncher_test} STREQUAL "NODEPENDS")
    set_tests_properties(${testname} PROPERTIES DEPENDS ${_previous_applauncher_test})
  endif()
  set(_previous_applauncher_test ${testname})
  set_property(TEST ${testname} PROPERTY LABELS ctkAppLauncher)
endmacro()

#
# Add Tests
#
applauncher_add_test(App4Test-ConfigureStep)
applauncher_add_test(App4Test-BuildStep)
applauncher_add_test(App4Test-TestRPATHDisabled)

applauncher_add_test(AppLauncher-Param-TestLauncherAdditionalSettings)
applauncher_add_test(AppLauncher-Param-TestLauncherDetach)
applauncher_add_test(AppLauncher-Param-TestLauncherDumpEnvironment)
applauncher_add_test(AppLauncher-Param-TestLauncherGenerateTemplate)
applauncher_add_test(AppLauncher-Param-TestLauncherHelp)
applauncher_add_test(AppLauncher-Param-TestLauncherLaunch-SearchPATH)
applauncher_add_test(AppLauncher-Param-TestLauncherLaunch-SearchPATH-WithLauncherExpression)
applauncher_add_test(AppLauncher-Param-TestLauncherLaunch-WithArguments)
applauncher_add_test(AppLauncher-Param-TestLauncherLaunch-WithoutValue)
applauncher_add_test(AppLauncher-Param-TestLauncherNoSplash)
applauncher_add_test(AppLauncher-Param-TestLauncherTimeout)
applauncher_add_test(AppLauncher-Param-TestLauncherVerbose)
applauncher_add_test(AppLauncher-Param-TestLauncherVersion)
applauncher_add_test(AppLauncher-Param-TestQtReservedArgs)

applauncher_add_test(AppLauncher-Settings-TestApplicationArguments)
applauncher_add_test(AppLauncher-Settings-TestApplicationPath)
applauncher_add_test(AppLauncher-Settings-TestApplicationPath-Invalid)
applauncher_add_test(AppLauncher-Settings-TestApplicationPath-WithArgumentsAsParam)
applauncher_add_test(AppLauncher-Settings-TestApplicationPath-Without)
applauncher_add_test(AppLauncher-Settings-TestEnvironment)
applauncher_add_test(AppLauncher-Settings-TestExtraAppLongArg)
applauncher_add_test(AppLauncher-Settings-TestExtraAppLongArg-WithParams)
applauncher_add_test(AppLauncher-Settings-TestExtraAppShortArg)
applauncher_add_test(AppLauncher-Settings-TestLauncherLaunch-SearchPATH)
applauncher_add_test(AppLauncher-Settings-TestPATH)

applauncher_add_test(AppLauncher-TestAppExitCode)
applauncher_add_test(AppLauncher-TestCurrentDirectory)
applauncher_add_test(AppLauncher-TestNoLaunchSettingsNoLaunchParams)
