
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
macro(applauncher_add_test testname depends)
  add_test(${testname} ${CMAKE_COMMAND}
    -DTEST_SOURCE_DIR:PATH=${CMAKE_CURRENT_SOURCE_DIR}
    -DTEST_BINARY_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}
    -P ${CMAKE_CURRENT_SOURCE_DIR}/${testname}.cmake)
  if(NOT ${depends} STREQUAL "NODEPENDS")
    set_tests_properties(${testname} PROPERTIES DEPENDS ${depends})
  endif()
  set_property(TEST ${testname} PROPERTY LABELS ctkAppLauncher)
endmacro()

#
# Add Tests
#
applauncher_add_test(App4TestConfigureStep NODEPENDS)
applauncher_add_test(App4TestBuildStep App4TestConfigureStep)
applauncher_add_test(AppLauncherTest1 App4TestBuildStep)
applauncher_add_test(AppLauncherTest2 AppLauncherTest1)
applauncher_add_test(AppLauncherTest3 AppLauncherTest2)
applauncher_add_test(AppLauncherTest4 AppLauncherTest3)
applauncher_add_test(AppLauncherTest5 AppLauncherTest4)
applauncher_add_test(AppLauncherTest6 AppLauncherTest5)
applauncher_add_test(AppLauncherTest7 AppLauncherTest6)
applauncher_add_test(AppLauncherTest8 AppLauncherTest7)
applauncher_add_test(AppLauncherTestNoSplashScreen AppLauncherTest8)
applauncher_add_test(AppLauncherTestLauncherDetach AppLauncherTestNoSplashScreen)
