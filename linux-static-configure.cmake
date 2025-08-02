#
# Configure the AppLauncher project using a statically built Qt and a Linux-based environment.
#
# This script sets up the Linux build environment, generates an initial CMake cache,
# and runs `cmake` to configure the project in a given build directory.
#
# Usage:
#
#   cmake \
#     -DQt5_DIR:PATH=/path/to/qt/lib/cmake/Qt5 \
#     -DCTKAppLauncher_BUILD_DIR:PATH=/path/to/build \
#     -DCTKAppLauncher_SOURCE_DIR:PATH=/path/to/src \
#     -P /path/to/linux-static-configure.cmake
#
# Required variables:
# - Qt5_DIR: Path to the static Qt installation's CMake config
# - CTKAppLauncher_BUILD_DIR: Destination directory for the CMake build
#
# Optional:
# - CTKAppLauncher_SOURCE_DIR: If not set, defaults to ${CMAKE_CURRENT_SOURCE_DIR}
#
# Prebuilt static Qt archives can be found at:
#   https://github.com/jcfr/qt-static-build
#

if(NOT EXISTS "${Qt5_DIR}")
  message(FATAL_ERROR "Qt5_DIR is set to a non-existent directory [${Qt5_DIR}]")
endif()

if(NOT DEFINED CTKAppLauncher_SOURCE_DIR)
  set(CTKAppLauncher_SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}")
endif()
if(NOT EXISTS "${CTKAppLauncher_SOURCE_DIR}")
  message(FATAL_ERROR "CTKAppLauncher_SOURCE_DIR is set to a non-existent directory [${CTKAppLauncher_SOURCE_DIR}]")
endif()
message(STATUS "Setting CTKAppLauncher_SOURCE_DIR: ${CTKAppLauncher_SOURCE_DIR}")

if(NOT DEFINED CTKAppLauncher_BUILD_DIR)
  message(FATAL_ERROR "CTKAppLauncher_BUILD_DIR is not set")
endif()
if(NOT EXISTS "${CTKAppLauncher_BUILD_DIR}")
  message(FATAL_ERROR "CTKAppLauncher_BUILD_DIR is set to a non-existent directory [${CTKAppLauncher_BUILD_DIR}]")
endif()
message(STATUS "Setting CTKAppLauncher_BUILD_DIR: ${CTKAppLauncher_BUILD_DIR}")

# Set QT_PREFIX_DIR assuming standard static Qt layout
set(QT_PREFIX_DIR "${Qt5_DIR}/../../../")
get_filename_component(QT_PREFIX_DIR ${QT_PREFIX_DIR} ABSOLUTE)
message(STATUS "Setting QT_PREFIX_DIR: ${QT_PREFIX_DIR}")


# Dependencies of QPA plugin needed for running GUI based application
# and avoid runtime error: qt.qpa.plugin: Could not find the Qt platform plugin "xcb" in ""
set(qt_qpa_plugin_static_libraries
  ${QT_PREFIX_DIR}/plugins/platforms/libqxcb.a
)
set(qt_static_libraries
  ${qt_qpa_plugin_static_libraries}
)

set(INITIAL_CACHE "
CMAKE_BUILD_TYPE:STRING=Release
BUILD_TESTING:BOOL=1
CTKAppLauncher_QT_STATIC_LIBRARIES:STRING=${qt_static_libraries}
Qt5_DIR:PATH=${Qt5_DIR}"
)

file(WRITE ${CTKAppLauncher_BUILD_DIR}/CMakeCache.txt "${INITIAL_CACHE}")

execute_process(COMMAND
  ${CMAKE_COMMAND}
    -G Ninja
    -S ${CTKAppLauncher_SOURCE_DIR}
    -B ${CTKAppLauncher_BUILD_DIR}
)
