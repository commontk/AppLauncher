if(NOT DEFINED LAUNCHER_DIR)
  message(FATAL_ERROR "LAUNCHER_DIR is not defined")
endif()
if(NOT ("${TEST_TREE_TYPE}" STREQUAL "BuildTree" OR "${TEST_TREE_TYPE}" STREQUAL "InstallTree"))
  message(FATAL_ERROR "TEST_TREE_TYPE is expected to be either 'BuildTree' or 'InstallTree'")
endif()

set(LAUNCHER_NAME ${PROJECT_NAME})
set(LAUNCHER_VERSION ${CTKAppLauncher_VERSION})

set(APP4TEST_CMAKE_GENERATOR "${CMAKE_GENERATOR}")
set(APP4TEST_BUILD_TYPE "Release")
set(APP4TEST_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/App4Test)
set(APP4TEST_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/App4Test-build)

set(APP4CONFIGURELAUNCHERTEST_CMAKE_GENERATOR "${CMAKE_GENERATOR}")
set(APP4CONFIGURELAUNCHERTEST_BUILD_TYPE "Release")
set(APP4CONFIGURELAUNCHERTEST_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/App4ConfigureLauncherTest)
set(APP4CONFIGURELAUNCHERTEST_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/App4ConfigureLauncherTest-build)

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

configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/App4TestStepChecks.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/App4TestStepChecks.cmake
  COPYONLY
  )

configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/ConfiguredAppLauncherTestPrerequisites.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/ConfiguredAppLauncherTestPrerequisites.cmake
  @ONLY
  )

configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/App4ConfigureLauncherTestStepPrerequisites.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/App4ConfigureLauncherTestStepPrerequisites.cmake
  @ONLY
  )

#
# Helper function
#
function(applauncher_add_cmakescript_test testname script)
  add_test(cmake_${testname} ${CMAKE_COMMAND}
    -DTEST_${testname}:BOOL=ON
    -P ${CTKAppLauncher_SOURCE_DIR}/CMake/${script}.cmake)
  set_tests_properties(cmake_${testname} PROPERTIES
    LABELS ctkAppLauncher
    PASS_REGULAR_EXPRESSION "SUCCESS")
endfunction()

#
# Add 'CMake script' Tests - Since these tests are independent of the TEST_TREE_TYPE, include them once.
#
if(TEST_TREE_TYPE STREQUAL "BuildTree")
  applauncher_add_cmakescript_test(ctkAppLauncherListToQtSettingsArrayTest ctkAppLauncher)
  applauncher_add_cmakescript_test(ctkAppLauncherAppendExtraAppToLaunchToListTest ctkAppLauncher)
  applauncher_add_cmakescript_test(ctkAppLauncherExtraAppToLaunchListToQtSettingsTest ctkAppLauncher)
endif()

#
# Get Qt library directory
#
if(CTKAppLauncher_QT_VERSION VERSION_GREATER "4")
  get_target_property(_imported_location "Qt5::Core" IMPORTED_LOCATION_RELEASE)
  get_filename_component(QT_LIBRARY_DIR ${_imported_location} DIRECTORY)
  if(WIN32)
    set(QT_LIBRARY_DIR "${QT_LIBRARY_DIR}/../bin")
  endif()
endif()

#
# Helper function
#
function(applauncher_add_test testname)
  set(testscript ${testname})
  set(testname "${TEST_TREE_TYPE}_${testname}")
  add_test(NAME ${testname} COMMAND ${CMAKE_COMMAND}
    -DTEST_SOURCE_DIR:PATH=${CMAKE_CURRENT_SOURCE_DIR}
    -DTEST_BINARY_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}
    -DTEST_CONFIGURATION:STRING=$<CONFIG>
    ${ARGN}
    -P ${CMAKE_CURRENT_SOURCE_DIR}/${testscript}.cmake)
  # Current test depends on all previous tests
  # This is required to support:
  #  (1) running tests for BuildTree or InstallTree group in parallel
  #  (2) always running test within one group serially
  set_property(TEST "${testname}" PROPERTY RESOURCE_LOCK "${TEST_TREE_TYPE}-Launcher")
  if(NOT "${required_test_deps}" STREQUAL "")
     set_tests_properties(${testname} PROPERTIES DEPENDS "${required_test_deps}")
  endif()
  # Set labels
  set_property(TEST ${testname} PROPERTY LABELS "ctkAppLauncher")
  # Environment
  set_property(TEST ${testname} PROPERTY ENVIRONMENT "LD_LIBRARY_PATH=${QT_LIBRARY_DIR}")
endfunction()

#
# Add Tests
#

set(required_test_deps)

applauncher_add_test(App4Test-ConfigureStep)
applauncher_add_test(App4Test-BuildStep)
set_property(
  TEST "${TEST_TREE_TYPE}_App4Test-BuildStep"
  APPEND PROPERTY DEPENDS "${TEST_TREE_TYPE}_App4Test-ConfigureStep"
  )

set(required_test_deps
  ${TEST_TREE_TYPE}_App4Test-ConfigureStep
  ${TEST_TREE_TYPE}_App4Test-BuildStep
  )

applauncher_add_test(App4Test-TestRPATHDisabled)

if(TEST_TREE_TYPE STREQUAL "InstallTree")
  applauncher_add_test(
    AppLauncher-Install
    -DLAUNCHER_BUILD_DIR:PATH=${LAUNCHER_BUILD_DIR}
    -DLAUNCHER_INSTALL_DIR:PATH=${LAUNCHER_INSTALL_DIR}
    -DCTKAppLauncherTest_INSTALL_LauncherLibrary:BOOL=0
    )
  set_property(TEST "${TEST_TREE_TYPE}_AppLauncher-Install" APPEND PROPERTY RESOURCE_LOCK "AppLauncherConfigure")
  set_property(TEST "${TEST_TREE_TYPE}_AppLauncher-Install" APPEND PROPERTY LABELS "CompilerRequired")

  list(APPEND required_test_deps
    ${TEST_TREE_TYPE}_AppLauncher-Install
    )
endif()


applauncher_add_test(AppLauncher-Param-TestLauncherAdditionalSettings)
applauncher_add_test(AppLauncher-Param-TestLauncherDetach)
applauncher_add_test(AppLauncher-Param-TestLauncherDumpEnvironment)
applauncher_add_test(AppLauncher-Param-TestLauncherGenerateTemplate)
applauncher_add_test(AppLauncher-Param-TestLauncherHelp)
applauncher_add_test(AppLauncher-Param-TestLauncherIgnoreUserAdditionalSettings)
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
applauncher_add_test(AppLauncher-Settings-TestEnvironment-NotFound)
applauncher_add_test(AppLauncher-Settings-TestHelpLongArg)
applauncher_add_test(AppLauncher-Settings-TestHelpShortArg)
applauncher_add_test(AppLauncher-Settings-TestExtraApp-IgnoreHelp)
applauncher_add_test(AppLauncher-Settings-TestExtraAppLongArg)
applauncher_add_test(AppLauncher-Settings-TestExtraAppLongArg-WithParams)
applauncher_add_test(AppLauncher-Settings-TestExtraAppShortArg)
applauncher_add_test(AppLauncher-Settings-TestLauncherAdditionalSettings)
applauncher_add_test(AppLauncher-Settings-TestLauncherAdditionalSettings-FileBaseName)
applauncher_add_test(AppLauncher-Settings-TestLauncherAdditionalSettings-WithoutRevision)
applauncher_add_test(AppLauncher-Settings-TestLauncherLaunch-SearchPATH)
applauncher_add_test(AppLauncher-Settings-TestPATH)

applauncher_add_test(AppLauncher-TestAppExitCode)
applauncher_add_test(AppLauncher-TestCurrentDirectory)
applauncher_add_test(AppLauncher-TestLauncherAdditionalSettings)
applauncher_add_test(AppLauncher-TestLauncherAdditionalSettings-CheckForSettingsOverwrite)
applauncher_add_test(AppLauncher-TestNoLaunchSettingsNoLaunchParams)
if(UNIX)
  applauncher_add_test(AppLauncher-TestSymbolicLink)
  applauncher_add_test(AppLauncher-TestSymbolicLinkInPATH)
endif()

applauncher_add_test(App4ConfigureLauncherTest-ConfigureStep)
applauncher_add_test(App4ConfigureLauncherTest-BuildStep)
set_property(
  TEST "${TEST_TREE_TYPE}_App4ConfigureLauncherTest-BuildStep"
  APPEND PROPERTY DEPENDS "${TEST_TREE_TYPE}_App4ConfigureLauncherTest-ConfigureStep"
  )
applauncher_add_test(ConfiguredAppLauncher-ConfigurationContents)
set_property(
  TEST "${TEST_TREE_TYPE}_ConfiguredAppLauncher-ConfigurationContents"
  APPEND PROPERTY DEPENDS "${TEST_TREE_TYPE}_App4ConfigureLauncherTest-BuildStep"
  )
applauncher_add_test(ConfiguredAppLauncher-LauncherExecutable)
set_property(
  TEST "${TEST_TREE_TYPE}_ConfiguredAppLauncher-LauncherExecutable"
  APPEND PROPERTY DEPENDS "${TEST_TREE_TYPE}_ConfiguredAppLauncher-ConfigurationContents"
  )

foreach(test IN ITEMS
    AppLauncher-Settings-TestHelpLongArg
    AppLauncher-Settings-TestHelpShortArg
    )
  set_property(TEST "${TEST_TREE_TYPE}_${test}" APPEND PROPERTY LABELS "XDisplayRequired")
endforeach()

foreach(test IN ITEMS
    App4Test-ConfigureStep
    App4Test-BuildStep
    App4Test-TestRPATHDisabled
    App4ConfigureLauncherTest-ConfigureStep
    App4ConfigureLauncherTest-BuildStep
    ConfiguredAppLauncher-ConfigurationContents
    ConfiguredAppLauncher-LauncherExecutable
    )
  set_property(TEST "${TEST_TREE_TYPE}_${test}" APPEND PROPERTY LABELS "CompilerRequired")
endforeach()
