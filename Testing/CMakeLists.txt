
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
