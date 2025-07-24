
#
# This script was designed to be executed from the build directory:
#
#  cd build
#  $env:APPLAUNCHER_CMAKE_GENERATOR="Visual Studio 15 2017" # or "Ninja"
#  cmake -DQt5_DIR:PATH=$Qt5_DIR -DCTKAppLauncher_SOURCE_DIR:PATH=$pwd.Path + "\.." -P ..\msvc-static-configure.cmake
#
# Static build of Qt5 may be download from
#
#  https://github.com/jcfr/qt-static-build/releases/tag/applauncher-5.11.2-vs2017
#

if(NOT EXISTS "${Qt5_DIR}")
  message(FATAL_ERROR "Qt5_DIR is set to a non-existent directory [${Qt5_DIR}]")
endif()
if(NOT EXISTS "${CTKAppLauncher_SOURCE_DIR}")
  message(FATAL_ERROR "CTKAppLauncher_SOURCE_DIR is set to a non-existent directory [${CTKAppLauncher_SOURCE_DIR}]")
endif()
if ("$ENV{APPLAUNCHER_CMAKE_GENERATOR}" STREQUAL "Ninja")
  # For dashboard build with Visual Studio 2017 and old CMake
  set(APPLAUNCHER_CMAKE_GENERATOR -G Ninja)
  set(APPLAUNCHER_USE_NINJA ON)
elseif ("$ENV{APPLAUNCHER_CMAKE_GENERATOR}" STREQUAL "Visual Studio 15 2017")
  # For dashboard build with Visual Studio 2017 and old CMake
  set(APPLAUNCHER_CMAKE_GENERATOR -G "Visual Studio 15 2017")
  set(APPLAUNCHER_USE_NINJA OFF)
elseif ("$ENV{APPLAUNCHER_CMAKE_GENERATOR}" STREQUAL "Visual Studio 16 2019")
  # For local build with Visual Studio 2019 with modern CMake
  set(APPLAUNCHER_CMAKE_GENERATOR -G "Visual Studio 16 2019" -T v141 -A Win32)
  set(APPLAUNCHER_USE_NINJA OFF)
elseif ("$ENV{APPLAUNCHER_CMAKE_GENERATOR}" STREQUAL "Visual Studio 17 2022")
  # For local build with Visual Studio 2019 with modern CMake
  set(APPLAUNCHER_CMAKE_GENERATOR -G "Visual Studio 17 2022" -T v143 -A Win32)
  set(APPLAUNCHER_USE_NINJA OFF)
else()
  message(FATAL_ERROR "Env. variable APPLAUNCHER_CMAKE_GENERATOR is expected to match 'Ninja' or 'Visual Studio 15 2017' or 'Visual Studio 16 2019' [$ENV{APPLAUNCHER_CMAKE_GENERATOR}]")
endif()
message(STATUS "Selected CMake Generator is '${APPLAUNCHER_CMAKE_GENERATOR}'")

if(APPLAUNCHER_USE_NINJA)

  # Download FindVcvars.cmake
  set(dest_file "${CMAKE_CURRENT_BINARY_DIR}/FindVcvars.cmake")
  set(expected_hash "0fd1104a5e0f91f89b64dd700ce57ab9f7d7356fcabe9c895e62aca32386008e")
  set(url "https://raw.githubusercontent.com/scikit-build/cmake-FindVcvars/v1.6/FindVcvars.cmake")
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
  set(Vcvars_MSVC_ARCH 32)
  set(Vcvars_MSVC_VERSION 1915)
  find_package(Vcvars REQUIRED)

  # Download ninja archive
  set(archive_basename "ninja-1.8.2.g81279.kitware.dyndep-1.jobserver-1_i686-pc-windows-msvc")
  set(dest_file "${CMAKE_CURRENT_BINARY_DIR}/${archive_basename}.zip")
  set(expected_hash "eaa2a0f1b0d273a19a0a00365208e9ec8e3f6181771c7fb0adae93aaf24c32c6")
  set(url "https://github.com/Kitware/ninja/releases/download/v1.8.2.g81279.kitware.dyndep-1.jobserver-1/${archive_basename}.zip")
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
set(CMAKE_CXX_FLAGS_RELEASE "/MT /O2 /Ob2 /DNDEBUG")
set(INITIAL_CACHE "
ADDITIONAL_EXE_LINKER_FLAGS_RELEASE:STRING=/nodefaultlib
BUILD_TESTING:BOOL=1
CMAKE_CXX_FLAGS_RELEASE:STRING=${CMAKE_CXX_FLAGS_RELEASE}
CTKAppLauncher_QT_STATIC_LIBRARIES:STRING=${qt_static_libraries}
Qt5_DIR:PATH=${Qt5_DIR}"
)
if(APPLAUNCHER_USE_NINJA)
  set(INITIAL_CACHE "${INITIAL_CACHE}
CMAKE_BUILD_TYPE:STRING=Release"
)
endif()
file(WRITE CMakeCache.txt "${INITIAL_CACHE}")

set(ENV{LDFLAGS} "/INCREMENTAL:NO /LTCG")

execute_process(COMMAND ${Vcvars_LAUNCHER} ${CMAKE_COMMAND} ${APPLAUNCHER_CMAKE_GENERATOR} ${CTKAppLauncher_SOURCE_DIR})
