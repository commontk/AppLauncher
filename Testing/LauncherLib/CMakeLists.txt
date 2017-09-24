if(NOT DEFINED LAUNCHER_DIR)
  message(FATAL_ERROR "LAUNCHER_DIR is not defined")
endif()
if(NOT ("${TEST_TREE_TYPE}" STREQUAL "BuildTree" OR "${TEST_TREE_TYPE}" STREQUAL "InstallTree"))
  message(FATAL_ERROR "TEST_TREE_TYPE is expected to be either 'BuildTree' or 'InstallTree'")
endif()

set(APPLIB_CMAKE_GENERATOR "${CMAKE_GENERATOR}")
set(APPLIB_BUILD_TYPE "Release")
set(APPLIB_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/AppWithLauncherLib)
set(APPLIB_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/AppWithLauncherLib-build)

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
  set_property(TEST "${testname}" PROPERTY RESOURCE_LOCK "${TEST_TREE_TYPE}-LauncherLib")
  # Set labels
  set_property(TEST ${testname} PROPERTY LABELS "ctkAppLauncher" "CompilerRequired")

  set(testname ${testname} PARENT_SCOPE)
endfunction()


set(CTKAppLauncherLib_DIR ${LAUNCHER_DIR})

if(TEST_TREE_TYPE STREQUAL "InstallTree")
  applauncher_add_test(
    AppWithLauncherLib-Install
    -DLAUNCHER_BUILD_DIR:PATH=${LAUNCHER_BUILD_DIR}
    -DLAUNCHER_INSTALL_DIR:PATH=${LAUNCHER_INSTALL_DIR}
    )
  set(install_step_testname ${testname})
  set_property(TEST "${install_step_testname}" PROPERTY RESOURCE_LOCK "AppLauncherConfigure")
  set(CTKAppLauncherLib_DIR ${LAUNCHER_DIR}/${CTK_INSTALL_CONFIG_DIR})
endif()

set(test_args
  -DTEST_TREE_TYPE:STRING=${TEST_TREE_TYPE}
  -DAPPLIB_SOURCE_DIR:PATH=${APPLIB_SOURCE_DIR}
  -DAPPLIB_BINARY_DIR:PATH=${APPLIB_BINARY_DIR}
  -DCMAKE_CONFIGURATION_TYPES:STRING=${CMAKE_CONFIGURATION_TYPES}
  -DAPPLIB_BUILD_TYPE:STRING=${APPLIB_BUILD_TYPE}
  -DAPPLIB_CMAKE_GENERATOR:STRING=${APPLIB_CMAKE_GENERATOR}
  -DCTKAppLauncherLib_DIR:PATH=${CTKAppLauncherLib_DIR}
  -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
  -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
  -DCTKAppLauncher_QT_VERSION:STRING=${CTKAppLauncher_QT_VERSION}
  )
if(CTKAppLauncher_QT_VERSION VERSION_GREATER "4")
  list(APPEND test_args
    -DQt5_DIR:PATH=${Qt5_DIR}
    )
else()
  list(APPEND test_args
    -DQT_QMAKE_EXECUTABLE:FILEPATH=${QT_QMAKE_EXECUTABLE}
    )
endif()
foreach(varname IN ITEMS
    CMAKE_OSX_ARCHITECTURES
    CMAKE_OSX_DEPLOYMENT_TARGET
    CMAKE_OSX_SYSROOT
    CMAKE_GENERATOR_PLATFORM
    CMAKE_GENERATOR_TOOLSET
    )
  if(DEFINED ${varname})
    list(APPEND test_args
      -D${varname}:STRING=${${varname}}
      )
  endif()
endforeach()

applauncher_add_test(AppWithLauncherLib-ConfigureStep ${test_args})
if(TEST_TREE_TYPE STREQUAL "InstallTree")
  set_property(TEST ${testname} APPEND PROPERTY DEPENDS ${install_step_testname})
endif()
set(configure_step_testname ${testname})

applauncher_add_test(AppWithLauncherLib-BuildStep ${test_args})
set_property(TEST ${testname} APPEND PROPERTY DEPENDS ${configure_step_testname})
set(build_step_testname ${testname})

applauncher_add_test(AppWithLauncherLib-RunStep ${test_args})
set_property(TEST ${testname} APPEND PROPERTY DEPENDS ${build_step_testname})

applauncher_add_test(AppWithLauncherLib-RunWithLauncherStep ${test_args})
set_property(TEST ${testname} APPEND PROPERTY DEPENDS ${build_step_testname})

set_property(TEST ${testname} PROPERTY LABELS "ctkAppLauncher") # Remove "CompilerRequired" label
if(TEST_TREE_TYPE STREQUAL "InstallTree")
  set_tests_properties(${testname} PROPERTIES DEPENDS "InstallTree_AppLauncher-Install")
endif()
