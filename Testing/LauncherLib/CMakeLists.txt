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
# Helper macro
#
set(_previous_applauncher_test "NODEPENDS")
function(applauncher_add_test testname)
  set(testscript ${testname})
  set(testname "${TEST_TREE_TYPE}_${testname}")
  add_test(NAME ${testname} COMMAND ${CMAKE_COMMAND}
    -DTEST_SOURCE_DIR:PATH=${CMAKE_CURRENT_SOURCE_DIR}
    -DTEST_BINARY_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}
    -DTEST_CONFIGURATION:STRING=$<CONFIG>
    ${ARGN}
    -P ${CMAKE_CURRENT_SOURCE_DIR}/${testscript}.cmake)
  if(NOT ${_previous_applauncher_test} STREQUAL "NODEPENDS")
    set_tests_properties(${testname} PROPERTIES DEPENDS ${_previous_applauncher_test})
  endif()
  set(_previous_applauncher_test ${testname} PARENT_SCOPE)
  set_property(TEST ${testname} PROPERTY LABELS ctkAppLauncher)
  set(testname ${testname} PARENT_SCOPE)
endfunction()

set(CTKAppLauncher_DIR ${LAUNCHER_DIR})

if(TEST_TREE_TYPE STREQUAL "InstallTree")
  applauncher_add_test(
    AppWithLauncherLib-Install
    -DLAUNCHER_BUILD_DIR:PATH=${LAUNCHER_BUILD_DIR}
    -DLAUNCHER_INSTALL_DIR:PATH=${LAUNCHER_INSTALL_DIR}
    )
  set_property(TEST ${testname} PROPERTY RESOURCE_LOCK "AppLauncherConfigure")

  set(CTKAppLauncher_DIR ${LAUNCHER_DIR}/${CTK_INSTALL_CONFIG_DIR})
endif()

set(test_args
  -DAPPLIB_SOURCE_DIR:PATH=${APPLIB_SOURCE_DIR}
  -DAPPLIB_BINARY_DIR:PATH=${APPLIB_BINARY_DIR}
  -DCMAKE_CONFIGURATION_TYPES:STRING=${CMAKE_CONFIGURATION_TYPES}
  -DAPPLIB_BUILD_TYPE:STRING=${APPLIB_BUILD_TYPE}
  -DAPPLIB_CMAKE_GENERATOR:STRING=${APPLIB_CMAKE_GENERATOR}
  -DCTKAppLauncher_DIR:PATH=${CTKAppLauncher_DIR}
  -DQT_QMAKE_EXECUTABLE:FILEPATH=${QT_QMAKE_EXECUTABLE}
  )

applauncher_add_test(AppWithLauncherLib-ConfigureStep ${test_args})
applauncher_add_test(AppWithLauncherLib-BuildStep ${test_args})
applauncher_add_test(AppWithLauncherLib-RunStep ${test_args})
