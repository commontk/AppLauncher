
# Add 'CMake script' Tests
function(applauncher_add_cmakescript_test testname script)
  add_test(cmake_${testname} ${CMAKE_COMMAND}
    -DTEST_${testname}:BOOL=ON
    -P ${CTKAppLauncher_SOURCE_DIR}/CMake/${script}.cmake)
  set_tests_properties(cmake_${testname} PROPERTIES
    LABELS ctkAppLauncher
    PASS_REGULAR_EXPRESSION "SUCCESS")
endfunction()
applauncher_add_cmakescript_test(ctkAppLauncherListToQtSettingsArrayTest ctkAppLauncher)
applauncher_add_cmakescript_test(ctkAppLauncherAppendExtraAppToLaunchToListTest ctkAppLauncher)
applauncher_add_cmakescript_test(ctkAppLauncherExtraAppToLaunchListToQtSettingsTest ctkAppLauncher)

# Get Qt library directory
if(CTKAppLauncher_QT_VERSION VERSION_GREATER "4")
  get_target_property(_imported_location "Qt5::Core" IMPORTED_LOCATION_RELEASE)
  get_filename_component(QT_LIBRARY_DIR ${_imported_location} DIRECTORY)
  if(WIN32)
    set(QT_LIBRARY_DIR "${QT_LIBRARY_DIR}/../bin")
  endif()
else()
  # QT_LIBRARY_DIR is already set by FindQt4.cmake
endif()

# Run tests against a build tree of CTKAppLauncher
set(TEST_TREE_TYPE "BuildTree")
set(LAUNCHER_BUILD_DIR ${CTKAppLauncher_BINARY_DIR})
set(LAUNCHER_DIR ${LAUNCHER_BUILD_DIR})
add_subdirectory(Launcher Launcher-${TEST_TREE_TYPE})
add_subdirectory(LauncherLib LauncherLib-${TEST_TREE_TYPE})

# Run tests against an install tree of CTKAppLauncher
set(TEST_TREE_TYPE "InstallTree")
# Launcher
set(LAUNCHER_INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/install)
set(LAUNCHER_DIR ${LAUNCHER_INSTALL_DIR})
file(MAKE_DIRECTORY ${LAUNCHER_INSTALL_DIR})
add_subdirectory(Launcher Launcher-${TEST_TREE_TYPE})
# LauncherLib
set(LAUNCHER_INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/install-lib)
set(LAUNCHER_DIR ${LAUNCHER_INSTALL_DIR})
file(MAKE_DIRECTORY ${LAUNCHER_INSTALL_DIR})
add_subdirectory(LauncherLib LauncherLib-${TEST_TREE_TYPE})
