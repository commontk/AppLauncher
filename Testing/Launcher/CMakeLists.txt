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
set(APP4CONFIGURELAUNCHERTEST_ROOT_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})

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
function(applauncher_add_test name)
  set(previous_testname ${testname} PARENT_SCOPE)
  set(testscript ${name})
  set(name "${TEST_TREE_TYPE}_${name}${TEST_SUFFIX}")
  set(options ${ARGN})
  add_test(NAME ${name} COMMAND ${CMAKE_COMMAND}
    -DTEST_SOURCE_DIR:PATH=${CMAKE_CURRENT_SOURCE_DIR}
    -DTEST_BINARY_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}
    -DTEST_CONFIGURATION:STRING=$<CONFIG>
    ${options}
    -P ${CMAKE_CURRENT_SOURCE_DIR}/${testscript}.cmake)
  # Current test depends on all previous tests
  # This is required to support:
  #  (1) running tests for BuildTree or InstallTree group in parallel
  #  (2) always running test within one group serially
  set_property(TEST "${name}" PROPERTY RESOURCE_LOCK "${TEST_TREE_TYPE}-Launcher")
  if(NOT "${required_test_deps}" STREQUAL "")
     set_tests_properties(${name} PROPERTIES DEPENDS "${required_test_deps}")
  endif()
  # Set labels
  set_property(TEST ${name} PROPERTY LABELS "ctkAppLauncher")
  foreach(label IN LISTS TEST_LABELS)
    set_property(TEST "${name}" APPEND PROPERTY LABELS ${label})
  endforeach()

  # Environment
  set_property(TEST ${name} PROPERTY ENVIRONMENT "LD_LIBRARY_PATH=${QT_LIBRARY_DIR}")

  set(testname ${name} PARENT_SCOPE)
  set(test_options ${options} PARENT_SCOPE)
endfunction()

#
# Add Tests
#

set(required_test_deps)

#-----------------------------------------------------------------------------
set(TEST_LABELS "CompilerRequired")
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
applauncher_add_test(App4Test-ConfigureStep)
applauncher_add_test(App4Test-BuildStep)
set_property(TEST "${testname}" APPEND PROPERTY DEPENDS "${previous_testname}")

set(required_test_deps
  ${TEST_TREE_TYPE}_App4Test-ConfigureStep
  ${TEST_TREE_TYPE}_App4Test-BuildStep
  )

#-----------------------------------------------------------------------------
applauncher_add_test(App4Test-TestRPATHDisabled)

#-----------------------------------------------------------------------------
if(TEST_TREE_TYPE STREQUAL "InstallTree")
  applauncher_add_test(
    AppLauncher-Install
    -DLAUNCHER_BUILD_DIR:PATH=${LAUNCHER_BUILD_DIR}
    -DLAUNCHER_INSTALL_DIR:PATH=${LAUNCHER_INSTALL_DIR}
    -DCTKAppLauncherTest_INSTALL_LauncherLibrary:BOOL=0
    )
  set_property(TEST ${testname} APPEND PROPERTY RESOURCE_LOCK "AppLauncherConfigure")

  list(APPEND required_test_deps
    ${testname}
    )
endif()

#-----------------------------------------------------------------------------
set(TEST_LABELS "")
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
applauncher_add_test(AppLauncher-Param-TestLauncherAdditionalSettings)
applauncher_add_test(AppLauncher-Param-TestLauncherAdditionalSettingsExcludeGroups)
applauncher_add_test(AppLauncher-Param-TestLauncherDetach)
applauncher_add_test(AppLauncher-Param-TestLauncherDumpEnvironment)
applauncher_add_test(AppLauncher-Param-TestLauncherGenerateTemplate)
applauncher_add_test(AppLauncher-Param-TestLauncherHelp)
applauncher_add_test(AppLauncher-Param-TestLauncherIgnoreUserAdditionalSettings)
applauncher_add_test(AppLauncher-Param-TestLauncherLaunch-SearchPATH)
applauncher_add_test(AppLauncher-Param-TestLauncherLaunch-SearchPATH-WithLauncherExpression)
applauncher_add_test(AppLauncher-Param-TestLauncherLaunch-WithArguments)
applauncher_add_test(AppLauncher-Param-TestLauncherLaunch-WithoutValue)
applauncher_add_test(AppLauncher-Param-TestLauncherLoadEnvironmentLevel0)
applauncher_add_test(AppLauncher-Param-TestLauncherLoadEnvironmentLevel1)
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
applauncher_add_test(AppLauncher-Settings-TestEnvironment-Deprecated-GeneralAdditionalPathVariables)
applauncher_add_test(AppLauncher-Settings-TestEnvironment-NotFound)
applauncher_add_test(AppLauncher-Settings-TestHelpLongArg)
set_property(TEST "${testname}" APPEND PROPERTY LABELS "XDisplayRequired")
applauncher_add_test(AppLauncher-Settings-TestHelpShortArg)
set_property(TEST "${testname}" APPEND PROPERTY LABELS "XDisplayRequired")
applauncher_add_test(AppLauncher-Settings-TestExtraApp-IgnoreHelp)
applauncher_add_test(AppLauncher-Settings-TestExtraAppLongArg)
applauncher_add_test(AppLauncher-Settings-TestExtraAppLongArg-WithParams)
applauncher_add_test(AppLauncher-Settings-TestExtraAppShortArg)
applauncher_add_test(AppLauncher-Settings-TestLauncherUserAdditionalSettings)
applauncher_add_test(AppLauncher-Settings-TestLauncherUserAdditionalSettings-FileBaseName)
applauncher_add_test(AppLauncher-Settings-TestLauncherUserAdditionalSettings-WithoutRevision)
applauncher_add_test(AppLauncher-Settings-TestLauncherLaunch-SearchPATH)
applauncher_add_test(AppLauncher-Settings-TestLauncherLoadEnvironmentLevel0)
applauncher_add_test(AppLauncher-Settings-TestLauncherLoadEnvironmentLevel1)
applauncher_add_test(AppLauncher-Settings-TestPATH)

applauncher_add_test(AppLauncher-TestAppExitCode)
applauncher_add_test(AppLauncher-TestCurrentDirectory)
applauncher_add_test(AppLauncher-TestLauncherAdditionalSettings)
applauncher_add_test(AppLauncher-TestLauncherAdditionalSettings-CheckForSettingsOverwrite)
applauncher_add_test(AppLauncher-TestLauncherAdditionalSettings-ExcludeGroups-General)
applauncher_add_test(AppLauncher-TestLauncherAdditionalSettings-ExcludeGroups-General-Environment)
applauncher_add_test(AppLauncher-TestLauncherAdditionalSettings-ExcludeGroups-General-Environment-EnvironmentVariables)
applauncher_add_test(AppLauncher-TestLauncherAdditionalSettings-ExcludeGroups-General-Environment-EnvironmentVariables-Paths-LibraryPaths)
applauncher_add_test(AppLauncher-TestPlaceHolderStrings)
applauncher_add_test(AppLauncher-TestNoLaunchSettingsNoLaunchParams)
applauncher_add_test(AppLauncher-TestSaveLauncherEnvironment)
if(UNIX)
  applauncher_add_test(AppLauncher-TestSymbolicLink)
  applauncher_add_test(AppLauncher-TestSymbolicLinkInPATH)
endif()
if (WIN32)
  applauncher_add_test(AppLauncher-TestWithoutExeExtension)
endif()

#-----------------------------------------------------------------------------
set(TEST_LABELS "CompilerRequired")
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
set(TEST_SUFFIX "-Deprecated")
applauncher_add_test(App4ConfigureLauncherTest-ConfigureStep -DWITH_CONFIG_FILE:BOOL=0 -DSCRIPT_MODE=Configure -DTEST_FUNCTION:STRING=Deprecated -DTEST_GENERATOR:STRING=DefaultGenerator)
applauncher_add_test(App4ConfigureLauncherTest-BuildStep ${test_options})
set_property(TEST "${testname}" APPEND PROPERTY DEPENDS "${previous_testname}")
set(TEST_SUFFIX "")

#-----------------------------------------------------------------------------
set(TEST_SUFFIX "-WithConfigFile-Deprecated")
applauncher_add_test(App4ConfigureLauncherTest-ConfigureStep -DWITH_CONFIG_FILE:BOOL=1 -DSCRIPT_MODE=Configure -DTEST_FUNCTION:STRING=Deprecated -DTEST_GENERATOR:STRING=DefaultGenerator)
applauncher_add_test(App4ConfigureLauncherTest-BuildStep ${test_options})
set_property(TEST "${testname}" APPEND PROPERTY DEPENDS "${previous_testname}")
set(TEST_SUFFIX "")

#-----------------------------------------------------------------------------
set(TEST_SUFFIX "-WithConfigFile-ForTarget")
applauncher_add_test(App4ConfigureLauncherTest-ConfigureStep -DWITH_CONFIG_FILE:BOOL=1 -DSCRIPT_MODE=Configure -DTEST_FUNCTION:STRING=ForTarget -DTEST_GENERATOR:STRING=DefaultGenerator)
applauncher_add_test(App4ConfigureLauncherTest-BuildStep ${test_options})
set_property(TEST "${testname}" APPEND PROPERTY DEPENDS "${previous_testname}")

applauncher_add_test(ConfiguredAppLauncher-ConfigurationContents ${test_options})
set_property(TEST ${testname} APPEND PROPERTY DEPENDS ${previous_testname})
applauncher_add_test(ConfiguredAppLauncher-LauncherExecutable ${test_options})
set_property(TEST "${testname}" APPEND PROPERTY DEPENDS "${previous_testname}")
set(TEST_SUFFIX "")

#-----------------------------------------------------------------------------
find_program(NINJA_EXECUTABLE ninja)
if(UNIX AND NINJA_EXECUTABLE AND CMAKE_GENERATOR MATCHES "Ninja|Unix Makefiles")
  set(TEST_SUFFIX "-ConfigureMode-WithConfigFile-ForTarget-NinjaGenerator")
  applauncher_add_test(App4ConfigureLauncherTest-ConfigureStep -DWITH_CONFIG_FILE:BOOL=1 -DSCRIPT_MODE=Configure -DTEST_FUNCTION:STRING=ForTarget -DTEST_GENERATOR:STRING=NinjaGenerator)
  applauncher_add_test(App4ConfigureLauncherTest-BuildStep ${test_options})
  set_property(TEST "${testname}" APPEND PROPERTY DEPENDS "${previous_testname}")

  applauncher_add_test(ConfiguredAppLauncher-ConfigurationContents ${test_options})
  set_property(TEST ${testname} APPEND PROPERTY DEPENDS ${previous_testname})
  applauncher_add_test(ConfiguredAppLauncher-LauncherExecutable ${test_options})
  set_property(TEST "${testname}" APPEND PROPERTY DEPENDS "${previous_testname}")
  set(TEST_SUFFIX "")
endif()

#-----------------------------------------------------------------------------
set(TEST_SUFFIX "-ConfigureMode-WithConfigFile-ForExecutable")
applauncher_add_test(App4ConfigureLauncherTest-ConfigureStep -DWITH_CONFIG_FILE:BOOL=1 -DSCRIPT_MODE=Configure -DTEST_FUNCTION:STRING=ForExecutable -DTEST_GENERATOR:STRING=DefaultGenerator)
applauncher_add_test(App4ConfigureLauncherTest-BuildStep ${test_options})
set_property(TEST "${testname}" APPEND PROPERTY DEPENDS "${previous_testname}")

applauncher_add_test(ConfiguredAppLauncher-ConfigurationContents ${test_options})
set_property(TEST ${testname} APPEND PROPERTY DEPENDS ${previous_testname})
applauncher_add_test(ConfiguredAppLauncher-LauncherExecutable ${test_options})
set_property(TEST "${testname}" APPEND PROPERTY DEPENDS "${previous_testname}")
set(TEST_SUFFIX "")

#-----------------------------------------------------------------------------
set(TEST_SUFFIX "-ScriptMode-WithConfigFile-ForExecutable")
applauncher_add_test(App4ConfigureLauncherTest-ConfigureStep -DWITH_CONFIG_FILE:BOOL=1 -DSCRIPT_MODE=Script -DTEST_FUNCTION:STRING=ForExecutable -DTEST_GENERATOR:STRING=DefaultGenerator)
applauncher_add_test(App4ConfigureLauncherTest-BuildStep ${test_options})
set_property(TEST "${testname}" APPEND PROPERTY DEPENDS "${previous_testname}")

applauncher_add_test(ConfiguredAppLauncher-ConfigurationContents ${test_options})
set_property(TEST ${testname} APPEND PROPERTY DEPENDS ${previous_testname})
applauncher_add_test(ConfiguredAppLauncher-LauncherExecutable ${test_options})
set_property(TEST "${testname}" APPEND PROPERTY DEPENDS "${previous_testname}")
set(TEST_SUFFIX "")

#-----------------------------------------------------------------------------
set(TEST_LABELS "")
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# Test "find_package(CTKAppLauncher)" can be used in script mode
set(script "AppLauncher-ScriptMode-FindPackage")
set(testname "${TEST_TREE_TYPE}_${script}")
add_test(
  NAME ${testname}
  COMMAND ${CMAKE_COMMAND}
    -DCTKAppLauncher_DIR:PATH=${LAUNCHER_DIR}
    -P ${CMAKE_CURRENT_SOURCE_DIR}/${script}.cmake
  )
set_tests_properties(${testname} PROPERTIES LABELS ctkAppLauncher)
if(TEST_TREE_TYPE STREQUAL "InstallTree")
  set_tests_properties(${testname} PROPERTIES DEPENDS "${TEST_TREE_TYPE}_AppLauncher-Install")
endif()
