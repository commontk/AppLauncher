#
# Configure the AppLauncher project using a statically built Qt and an MSVC-based environment.
#
# This script sets up the required Windows build environment (e.g., vcvars, Ninja, MSVC runtime),
# generates an initial CMake cache, and runs `cmake` to configure the project in a given build directory.
#
# Usage (PowerShell):
#
#   $env:APPLAUNCHER_CMAKE_GENERATOR = "Visual Studio 17 2022"  # or "Ninja"
#   $env:APPLAUNCHER_CMAKE_GENERATOR_TOOLSET = "v143"
#   $env:APPLAUNCHER_CMAKE_GENERATOR_PLATFORM = "x64"
#
#   cmake `
#     -DQt5_DIR:PATH=C:\path\to\Qt\lib\cmake\Qt5 `
#     -DCTKAppLauncher_BUILD_DIR:PATH=C:\path\to\build `
#     -DCTKAppLauncher_SOURCE_DIR:PATH=C:\path\to\src `
#     -P C:\path\to\msvc-static-configure.cmake
#
# Required variables:
# - Qt5_DIR: Path to the static Qt installation's CMake config
# - CTKAppLauncher_BUILD_DIR: Destination directory for the CMake build
# - APPLAUNCHER_CMAKE_GENERATOR: One of "Ninja", "Visual Studio 15 2017", etc.
# - APPLAUNCHER_CMAKE_GENERATOR_TOOLSET: Toolset version string (e.g., "v143")
# - APPLAUNCHER_CMAKE_GENERATOR_PLATFORM: "Win32" or "x64"
#
# Optional:
# - CTKAppLauncher_SOURCE_DIR: If not set, defaults to ${CMAKE_CURRENT_SOURCE_DIR}
#
# Prebuilt static Qt archives can be found at:
#   https://github.com/jcfr/qt-static-build

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

if(NOT DEFINED APPLAUNCHER_CMAKE_GENERATOR_TOOLSET)
  message(FATAL_ERROR "APPLAUNCHER_CMAKE_GENERATOR_TOOLSET is not set")
endif()
if(NOT APPLAUNCHER_CMAKE_GENERATOR_TOOLSET MATCHES "^(v[0-9]+)$")
  message(FATAL_ERROR "APPLAUNCHER_CMAKE_GENERATOR_TOOLSET must be specified as v140, v141, ...")
endif()
message(STATUS "Selected CMake Generator Toolset: '${APPLAUNCHER_CMAKE_GENERATOR_TOOLSET}'")

if(NOT DEFINED APPLAUNCHER_CMAKE_GENERATOR_PLATFORM)
  message(FATAL_ERROR "APPLAUNCHER_CMAKE_GENERATOR_PLATFORM is not set")
endif()
message(STATUS "Selected CMake Generator Platform: '${APPLAUNCHER_CMAKE_GENERATOR_PLATFORM}'")


if ("$ENV{APPLAUNCHER_CMAKE_GENERATOR}" STREQUAL "Ninja")
  set(APPLAUNCHER_CMAKE_GENERATOR -G Ninja)
  set(APPLAUNCHER_USE_NINJA ON)
elseif ("$ENV{APPLAUNCHER_CMAKE_GENERATOR}" MATCHES "^Visual Studio (15 2017|16 2019|17 2022)$")
  set(APPLAUNCHER_CMAKE_GENERATOR
    -G "$ENV{APPLAUNCHER_CMAKE_GENERATOR}"
    -T "${APPLAUNCHER_CMAKE_GENERATOR_TOOLSET}"
    -A "${APPLAUNCHER_CMAKE_GENERATOR_PLATFORM}"
    )
  set(APPLAUNCHER_USE_NINJA OFF)
else()
  message(FATAL_ERROR
    "Env. variable APPLAUNCHER_CMAKE_GENERATOR must match one of: "
    "'Ninja', 'Visual Studio 15 2017', 'Visual Studio 16 2019', or 'Visual Studio 17 2022'. "
    "Got: [$ENV{APPLAUNCHER_CMAKE_GENERATOR}]"
  )
endif()
message(STATUS "Selected CMake Generator is '${APPLAUNCHER_CMAKE_GENERATOR}'")

if(APPLAUNCHER_USE_NINJA)

  # Download FindVcvars.cmake
  set(dest_file "${CMAKE_CURRENT_BINARY_DIR}/FindVcvars.cmake")
  set(expected_hash "56cbf16b279d9c8481a01e5ff115b9d2429f384377640c1265c2fecf19bcbe92")
  set(url "https://raw.githubusercontent.com/scikit-build/cmake-FindVcvars/v1.12/FindVcvars.cmake")
  if(NOT EXISTS ${dest_file})
    file(DOWNLOAD ${url} ${dest_file} EXPECTED_HASH SHA256=${expected_hash})
  else()
    file(SHA256 ${dest_file} current_hash)
    if(NOT ${current_hash} STREQUAL ${expected_hash})
      file(DOWNLOAD ${url} ${dest_file} EXPECTED_HASH SHA256=${expected_hash})
    endif()
  endif()

  list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_CURRENT_BINARY_DIR}")

  # Lookup vcvars script
  if(APPLAUNCHER_CMAKE_GENERATOR_PLATFORM STREQUAL "Win32")
    set(Vcvars_MSVC_ARCH 32)
  elseif(APPLAUNCHER_CMAKE_GENERATOR_PLATFORM STREQUAL "x64")
    set(Vcvars_MSVC_ARCH 64)
  else()
    message(FATAL_ERROR "Unsupported platform '${APPLAUNCHER_CMAKE_GENERATOR_PLATFORM}' for Ninja generator")
  endif()

  # Extract toolset version number (e.g., 143 from v143)
  string(REGEX REPLACE "^v([0-9]+)$" "\\1" toolset_number "${APPLAUNCHER_CMAKE_GENERATOR_TOOLSET}")
  message(STATUS "Extracted toolset number is '${toolset_number}'")

  # Convert numeric form (e.g., 143) to dotted form (e.g., 14.3)
  if(toolset_number MATCHES "^([0-9][0-9])([0-9])$")
    set(Vcvars_PLATFORM_TOOLSET_VERSION "${CMAKE_MATCH_1}.${CMAKE_MATCH_2}")
  else()
    message(FATAL_ERROR "Unexpected toolset format '${toolset_number}'; expected a 3-digit number like '143'")
  endif()
  message(STATUS "Setting Vcvars_PLATFORM_TOOLSET_VERSION to '${Vcvars_PLATFORM_TOOLSET_VERSION}'")
  message(STATUS "")

  # Find Vcvars with toolset version
  set(Vcvars_FIND_VCVARSALL ON)
  find_package(Vcvars REQUIRED)

  # Download ninja archive
  set(archive_basename "ninja-1.11.1.g95dee.kitware.jobserver-1_x86_64-pc-windows-msvc")
  set(dest_file "${CMAKE_CURRENT_BINARY_DIR}/${archive_basename}.zip")
  set(expected_hash "b4bfde704f7ca90891cad0bddacdb8289eb9775cec29704705b7ec7311901003")
  set(url "https://github.com/Kitware/ninja/releases/download/v1.11.1.g95dee.kitware.jobserver-1/${archive_basename}.zip")
  if(NOT EXISTS ${dest_file})
    file(DOWNLOAD ${url} ${dest_file} EXPECTED_HASH SHA256=${expected_hash})
  else()
    file(SHA256 ${dest_file} current_hash)
    if(NOT ${current_hash} STREQUAL ${expected_hash})
      file(DOWNLOAD ${url} ${dest_file} EXPECTED_HASH SHA256=${expected_hash})
    endif()
  endif()
  # Then, extract archive
  execute_process(COMMAND ${CMAKE_COMMAND} -E tar x ${dest_file})

  # Finally, update PATH
  set(ENV{PATH} "${CMAKE_CURRENT_BINARY_DIR}/${archive_basename};$ENV{PATH}")
endif()

# Set QT_PREFIX_DIR assuming standard static Qt layout
set(QT_PREFIX_DIR "${Qt5_DIR}/../../../")
get_filename_component(QT_PREFIX_DIR ${QT_PREFIX_DIR} ABSOLUTE)
message(STATUS "Setting QT_PREFIX_DIR: ${QT_PREFIX_DIR}")

# Dependencies of QPA plugin needed for running GUI based application
# and avoid runtime error: qt.qpa.plugin: Could not find the Qt platform plugin "windows" in ""
set(qt_qpa_plugin_static_libraries
  ${QT_PREFIX_DIR}/lib/Qt5EventDispatcherSupport.lib
  ${QT_PREFIX_DIR}/lib/Qt5FontDatabaseSupport.lib
  ${QT_PREFIX_DIR}/lib/Qt5ThemeSupport.lib
  ${QT_PREFIX_DIR}/lib/Qt5WindowsUIAutomationSupport.lib
  Dwmapi.lib
  Imm32.lib
  )
set(qt_static_libraries
  # Qt
  ${QT_PREFIX_DIR}/lib/qtharfbuzz.lib
  ${QT_PREFIX_DIR}/lib/qtlibpng.lib
  ${QT_PREFIX_DIR}/lib/qtpcre2.lib
  ${QT_PREFIX_DIR}/plugins/platforms/qwindows.lib
  ${qt_qpa_plugin_static_libraries}
  # Windows API
  Netapi32.lib
  OLDNAMES.LIB
  Userenv.lib
  version.lib
  Winmm.lib
  Ws2_32.lib
  # C runtime - https://msdn.microsoft.com/en-us/library/abx4dbyh.aspx#Anchor_0
  libcmt.lib
  libvcruntime.lib
  libucrt.lib
  # C++ runtime - See https://msdn.microsoft.com/en-us/library/abx4dbyh.aspx#Anchor_1
  LIBCPMT.lib
  )
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded")
set(INITIAL_CACHE "
ADDITIONAL_EXE_LINKER_FLAGS_RELEASE:STRING=/nodefaultlib
BUILD_TESTING:BOOL=1
CMAKE_MSVC_RUNTIME_LIBRARY:STRING=${CMAKE_MSVC_RUNTIME_LIBRARY}
CTKAppLauncher_QT_STATIC_LIBRARIES:STRING=${qt_static_libraries}
Qt5_DIR:PATH=${Qt5_DIR}"
)
if(APPLAUNCHER_USE_NINJA)
  set(INITIAL_CACHE "${INITIAL_CACHE}
CMAKE_BUILD_TYPE:STRING=Release"
)
endif()
file(WRITE ${CTKAppLauncher_BUILD_DIR}/CMakeCache.txt "${INITIAL_CACHE}")

set(ENV{LDFLAGS} "/INCREMENTAL:NO /LTCG")

execute_process(COMMAND
  ${Vcvars_LAUNCHER}
    ${CMAKE_COMMAND}
      ${APPLAUNCHER_CMAKE_GENERATOR}
      -S ${CTKAppLauncher_SOURCE_DIR}
      -B ${CTKAppLauncher_BUILD_DIR}
  )
