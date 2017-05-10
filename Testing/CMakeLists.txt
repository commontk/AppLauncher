
# Run tests against a build tree of CTKAppLauncher
set(LAUNCHER_BUILD_DIR ${CTKAppLauncher_BINARY_DIR})
set(LAUNCHER_DIR ${LAUNCHER_BUILD_DIR})
set(TEST_TREE_TYPE "BuildTree")
add_subdirectory(CMake CMake-${TEST_TREE_TYPE})

# Run tests against an install tree of CTKAppLauncher
set(LAUNCHER_INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/install)
set(LAUNCHER_DIR ${LAUNCHER_INSTALL_DIR})
set(TEST_TREE_TYPE "InstallTree")
file(MAKE_DIRECTORY ${LAUNCHER_INSTALL_DIR})
add_subdirectory(CMake CMake-${TEST_TREE_TYPE})
