###########################################################################
#
#  Library:   CTKAppLauncher
#
#  Copyright (c) Kitware Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.commontk.org/LICENSE
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
###########################################################################

cmake_minimum_required(VERSION 3.0)

#-----------------------------------------------------------------------------
project(CTKAppLauncher)

#-----------------------------------------------------------------------------
option(CTKAppLauncher_INSTALL_LauncherLibrary "Install CTKApplauncher launcher library" OFF)

#-----------------------------------------------------------------------------
# Set a default build type if none was specified
#
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to 'Debug' as none was specified.")
  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Choose the type of build." FORCE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release"
    "MinSizeRel" "RelWithDebInfo")
endif()

#-----------------------------------------------------------------------------
# CTKAppLauncher version number.
#
set(CTKAppLauncher_MAJOR_VERSION 0)
set(CTKAppLauncher_MINOR_VERSION 1)
set(CTKAppLauncher_BUILD_VERSION 29)
set(CTKAppLauncher_VERSION_IS_RELEASE 1)

if(CTKAppLauncher_VERSION_IS_RELEASE)
  set(CTKAppLauncher_VERSION_SOURCE "")
else()
  include(${CMAKE_SOURCE_DIR}/CMake/ctkVersionSource.cmake)
endif()

# Compute the full version string.
set(CTKAppLauncher_VERSION
    "${CTKAppLauncher_MAJOR_VERSION}.${CTKAppLauncher_MINOR_VERSION}.${CTKAppLauncher_BUILD_VERSION}")
if(CTKAppLauncher_VERSION_SOURCE)
  set(CTKAppLauncher_VERSION ${CTKAppLauncher_VERSION}-${CTKAppLauncher_VERSION_SOURCE})
endif()
message(STATUS "CTKAppLauncher version: ${CTKAppLauncher_VERSION}")

#-----------------------------------------------------------------------------
# Install directories, used for install rules.
#

macro(_set_if_not_defined varname value)
  if(NOT DEFINED ${varname})
    set(${varname} ${value})
  endif()
endmacro()

_set_if_not_defined(CTK_INSTALL_BIN_DIR "bin")
_set_if_not_defined(CTK_INSTALL_LIB_DIR "lib")
_set_if_not_defined(CTK_INSTALL_INCLUDE_DIR "include")
_set_if_not_defined(CTK_INSTALL_DOC_DIR "doc")
_set_if_not_defined(CTK_INSTALL_CONFIG_DIR ".")
_set_if_not_defined(CTK_INSTALL_CMAKE_DIR "CMake")

#-----------------------------------------------------------------------------
# Output directories.
foreach(type LIBRARY RUNTIME ARCHIVE)
  if(NOT CMAKE_${type}_OUTPUT_DIRECTORY)
    set(CMAKE_${type}_OUTPUT_DIRECTORY ${${PROJECT_NAME}_BINARY_DIR}/${CTK_INSTALL_BIN_DIR} CACHE INTERNAL "Single output directory for building all libraries.")
  endif()
endforeach()

#-----------------------------------------------------------------------------
# Global settings
#
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_INCLUDE_CURRENT_DIR_IN_INTERFACE ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

#-----------------------------------------------------------------------------
# Update CMake module path
#
set(CMAKE_MODULE_PATH
  "${CMAKE_CURRENT_SOURCE_DIR}/CMake"
  ${CMAKE_MODULE_PATH})

#-----------------------------------------------------------------------------
# CMake function(s) and macro(s)
#
include(ctkFunctionCheckCompilerFlags)
include(ctkFunctionGetCompilerVisibilityFlags)
include(ctkMacroBuildLib)

#-----------------------------------------------------------------------------
# Testing
#
option(BUILD_TESTING "Test the project" ON)
if(BUILD_TESTING)
  include(CTest)
  set(CPP_TEST_PATH ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})

  # Setup file for setting custom ctest vars
  configure_file(
    CMake/CTestCustom.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/CTestCustom.cmake
    @ONLY
    )

  # Configuration for the CMake-generated test driver
  set(CMAKE_TESTDRIVER_EXTRA_INCLUDES "#include <stdexcept>")
  set(CMAKE_TESTDRIVER_BEFORE_TESTMAIN "
    try
      {")
  set(CMAKE_TESTDRIVER_AFTER_TESTMAIN "    }
      catch( std::exception & excp )
        {
        fprintf(stderr,\"%s\\n\",excp.what());
        return EXIT_FAILURE;
        }
      catch( ... )
        {
        printf(\"Exception caught in the test driver\\n\");
        return EXIT_FAILURE;
        }
      ")
endif()

#-----------------------------------------------------------------------------
# Additional Linker Flags
#

set(ADDITIONAL_EXE_LINKER_FLAGS_RELEASE ""
  CACHE STRING "Additional flags used by the linker during release builds.")
mark_as_advanced(ADDITIONAL_EXE_LINKER_FLAGS_RELEASE)

set(ADDITIONAL_EXE_LINKER_FLAGS_MINSIZEREL ""
  CACHE STRING "Additional flags used by the linker during release minsize builds.")
mark_as_advanced(ADDITIONAL_EXE_LINKER_FLAGS_MINSIZEREL)

set(ADDITIONAL_EXE_LINKER_FLAGS_RELWITHDEBINFO ""
  CACHE STRING "Additional flags used by the linker during Release with Debug Info builds.")
mark_as_advanced(ADDITIONAL_EXE_LINKER_FLAGS_RELWITHDEBINFO)

set(ADDITIONAL_EXE_LINKER_FLAGS_DEBUG ""
  CACHE STRING "Additional flags used by the linker during debug builds.")
mark_as_advanced(ADDITIONAL_EXE_LINKER_FLAGS_DEBUG)

#-----------------------------------------------------------------------------
# Specific Linker Flags
#
set(SPECIFIC_EXE_LINKER_FLAGS_RELEASE)
set(SPECIFIC_EXE_LINKER_FLAGS_MINSIZEREL)
set(SPECIFIC_EXE_LINKER_FLAGS_RELWITHDEBINFO)
set(SPECIFIC_EXE_LINKER_FLAGS_DEBUG)

if(MSVC90)
  set(SPECIFIC_EXE_LINKER_FLAGS_DEBUG "/NODEFAULTLIB:msvcrtd.lib")
endif()

#-----------------------------------------------------------------------------
# Set Linker Flags
#
set(CMAKE_EXE_LINKER_FLAGS_RELEASE
  "${ADDITIONAL_EXE_LINKER_FLAGS_RELEASE} ${SPECIFIC_EXE_LINKER_FLAGS_RELEASE}"
  CACHE STRING "Flags used by the linker during release builds." FORCE)

set(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL
  "${ADDITIONAL_EXE_LINKER_FLAGS_MINSIZEREL} ${SPECIFIC_EXE_LINKER_FLAGS_MINSIZEREL}"
  CACHE STRING "Flags used by the linker during release minsize builds." FORCE)

set(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO
  "${ADDITIONAL_EXE_LINKER_FLAGS_RELWITHDEBINFO} ${SPECIFIC_EXE_LINKER_FLAGS_RELWITHDEBINFO}"
  CACHE STRING "Flags used by the linker during Release with Debug Info builds." FORCE)

set(CMAKE_EXE_LINKER_FLAGS_DEBUG
  "${ADDITIONAL_EXE_LINKER_FLAGS_DEBUG} ${SPECIFIC_EXE_LINKER_FLAGS_DEBUG}"
  CACHE STRING "Flags used by the linker during debug builds." FORCE)

#-----------------------------------------------------------------------------
# Coverage
#
option(WITH_COVERAGE "Enable/Disable coverage" OFF)

#-----------------------------------------------------------------------------
# Additional CXX/C Flags
#
set(ADDITIONAL_C_FLAGS "" CACHE STRING "Additional C Flags")
mark_as_advanced(ADDITIONAL_C_FLAGS)
set(ADDITIONAL_CXX_FLAGS "" CACHE STRING "Additional CXX Flags")
mark_as_advanced(ADDITIONAL_CXX_FLAGS)

#-----------------------------------------------------------------------------
# Set coverage Flags
#
if(WITH_COVERAGE)
  if(CMAKE_CXX_COMPILER_ID AND ${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
    set(coverage_flags "-g -fdiagnostics-show-option -fprofile-arcs -ftest-coverage -O3 -DNDEBUG")
    set(COVERAGE_C_FLAGS ${coverage_flags})
    set(COVERAGE_CXX_FLAGS ${coverage_flags})
  endif()
endif()

#-----------------------------------------------------------------------------
# Set symbol visibility Flags
#

option(CTKAppLauncher_VISIBILITY_HIDDEN "Whether to add compile flags to hide symbols of functions including inlines ones" ON)
set(VISIBILITY_CXX_FLAGS)
if(CTKAppLauncher_VISIBILITY_HIDDEN)
  ctkFunctionGetCompilerVisibilityFlags(VISIBILITY_CXX_FLAGS)
endif()

#-----------------------------------------------------------------------------
# Set C/CXX Flags
#
set(cflags)
if(CMAKE_COMPILER_IS_GNUCXX)
  set(cflags "-Wall -Wextra -Wpointer-arith -Winvalid-pch -Wcast-align -Wwrite-strings -D_FORTIFY_SOURCE=2")
endif()
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS_INIT} ${cflags} ${COVERAGE_C_FLAGS} ${ADDITIONAL_C_FLAGS}" CACHE STRING "CMake C Flags" FORCE)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS_INIT} ${cflags} ${COVERAGE_CXX_FLAGS} ${VISIBILITY_CXX_FLAGS} ${ADDITIONAL_CXX_FLAGS}" CACHE STRING "CMake CXX Flags" FORCE)

# This is a cross-platform project so we cannot use the MS _s API.
if(MSVC)
  add_definitions(
    -D_CRT_SECURE_NO_WARNINGS
    )
endif()

#-----------------------------------------------------------------------------
# Qt
#

set(default_qt_version "4")
if(DEFINED Qt5_DIR)
  set(default_qt_version "5")
endif()

set(CTKAppLauncher_QT_VERSION "${default_qt_version}" CACHE STRING "Expected Qt version")
mark_as_advanced(CTKAppLauncher_QT_VERSION)

set_property(CACHE CTKAppLauncher_QT_VERSION PROPERTY STRINGS 4 5)

if(NOT (CTKAppLauncher_QT_VERSION VERSION_EQUAL "4" OR CTKAppLauncher_QT_VERSION VERSION_EQUAL "5"))
  message(FATAL_ERROR "Expected value for CTKAppLauncher_QT_VERSION is either '4' or '5'")
endif()

if(CTKAppLauncher_QT_VERSION VERSION_GREATER "4")
  set(CTKAppLauncher_QT5_COMPONENTS Core Widgets)
  if(BUILD_TESTING)
    list(APPEND CTKAppLauncher_QT5_COMPONENTS Test)
  endif()
  find_package(Qt5 COMPONENTS ${CTKAppLauncher_QT5_COMPONENTS} REQUIRED)
  set(QT_LIBRARIES Qt5::Widgets ${CTKAppLauncher_QT_STATIC_LIBRARIES})

else()
  set(QT_USE_IMPORTED_TARGETS 1)
  find_package(Qt4 4.6 REQUIRED)
  set(QT_USE_QTTEST ${BUILD_TESTING})
  include(${QT_USE_FILE})
endif()

#-----------------------------------------------------------------------------
# Build ctkAppLauncherBase and associated tests
#
add_subdirectory(Base)

#-----------------------------------------------------------------------------
# Build executable
#

#
# Launcher *WITH* console IO support
#
add_executable(${PROJECT_NAME} Main.cpp)
target_link_libraries(${PROJECT_NAME} PUBLIC CTKAppLauncherBase)
if(QT_MAC_USE_COCOA)
  target_link_libraries(${PROJECT_NAME} PRIVATE "-framework cocoa")
endif()
set_target_properties(${PROJECT_NAME} PROPERTIES LABELS ctkAppLauncher)

list(APPEND targets_to_install ${PROJECT_NAME})

if(WIN32)
  #
  # Launcher *WITHOUT* console IO support
  #
  add_executable(${PROJECT_NAME}W WIN32 Main.cpp)
  target_link_libraries(${PROJECT_NAME}W PUBLIC CTKAppLauncherBase)
  set_target_properties(${PROJECT_NAME}W PROPERTIES
    LABELS ctkAppLauncher
    COMPILE_DEFINITIONS CTKAPPLAUNCHER_WITHOUT_CONSOLE_IO_SUPPORT
    )

  list(APPEND targets_to_install ${PROJECT_NAME}W)
endif()

if(BUILD_TESTING)
  add_subdirectory(Testing)
endif()

# Documentation - Automatically generate documentation at build time
set(all_arg)
if(DOCUMENTATION_TARGET_IN_ALL)
  set(all_arg "ALL")
endif()
add_custom_target(doc ${all_arg})
add_custom_target(doc-tarballs ${all_arg})
add_subdirectory(Docs)

# Copy CMake scripts to build directory
set(srcDistributables)
macro(ctkCopyDistributable FILE DESTINATION)
  get_filename_component(_filename ${FILE} NAME)
  add_custom_command(
    OUTPUT ${DESTINATION}/${_filename}
    DEPENDS ${${PROJECT_NAME}_SOURCE_DIR}/${FILE}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${DESTINATION}
    COMMAND ${CMAKE_COMMAND} -E copy
      ${${PROJECT_NAME}_SOURCE_DIR}/${FILE}
      ${DESTINATION}/${_filename}
    WORKING_DIRECTORY
      ${${PROJECT_NAME}_SOURCE_DIR}
    COMMENT "Copying ${_filename} to build directory"
    )
  list(APPEND srcDistributables ${DESTINATION}/${_filename})
endmacro()

ctkCopyDistributable(CMake/ctkAppLauncher.cmake ${${PROJECT_NAME}_BINARY_DIR}/${CTK_INSTALL_CMAKE_DIR})
ctkCopyDistributable(CMake/ctkAppLauncher-configure.cmake ${${PROJECT_NAME}_BINARY_DIR}/${CTK_INSTALL_CMAKE_DIR})
ctkCopyDistributable(CTKAppLauncherSettings.ini.in ${${PROJECT_NAME}_BINARY_DIR}/${CTK_INSTALL_BIN_DIR})
add_custom_target(copyDistributables ALL DEPENDS ${srcDistributables})

# Install rules
install(TARGETS ${targets_to_install}
  RUNTIME DESTINATION ${CTK_INSTALL_BIN_DIR} COMPONENT Runtime
  LIBRARY DESTINATION ${CTK_INSTALL_LIB_DIR} COMPONENT Runtime
  ARCHIVE DESTINATION ${CTK_INSTALL_LIB_DIR} COMPONENT Development)

install(FILES
  CMake/ctkAppLauncher.cmake
  CMake/ctkAppLauncher-configure.cmake
  DESTINATION ${CTK_INSTALL_CMAKE_DIR} COMPONENT Development)

install(FILES
  CTKAppLauncherSettings.ini.in
  DESTINATION ${CTK_INSTALL_BIN_DIR} COMPONENT Development)

#-----------------------------------------------------------------------------
# Configure CTKAppLauncherLibConfig
#

# Retrieve CTKAppLauncherLib used to configure 'CTKAppLauncherLibConfig.cmake' and
# 'CTKAppLauncherLibTargets.cmake'.
get_property(CTKAppLauncherLib_TARGETS GLOBAL PROPERTY CTKAppLauncherLib_TARGETS)

# Common properties
set(CTKAppLauncherLib_QT_VERSION_CONFIG "${CTKAppLauncher_QT_VERSION}")

# Configure 'CTKAppLauncherLibConfig.cmake' for a build tree
include(CMakePackageConfigHelpers)
set(CMAKE_DIR_CONFIG ${PROJECT_BINARY_DIR}/${CTK_INSTALL_CMAKE_DIR})
set(CONFIG_DIR_CONFIG ${PROJECT_BINARY_DIR})
set(CTKAppLauncher_CONFIG_CODE "####### Expanded from \@CTKAppLauncher_CONFIG_CODE\@ #######\n")
set(CTKAppLauncher_CONFIG_CODE "${CTKAppLauncher_CONFIG_CODE}set(CTKAppLauncher_QT_STATIC_LIBRARIES \"${CTKAppLauncher_QT_STATIC_LIBRARIES}\")\n")
set(CTKAppLauncher_CONFIG_CODE "${CTKAppLauncher_CONFIG_CODE}##################################################")
set(launcherlib_config ${PROJECT_BINARY_DIR}/CTKAppLauncherLibConfig.cmake)
configure_package_config_file(
    CMake/CTKAppLauncherLibConfig.cmake.in
    ${launcherlib_config}
    INSTALL_DESTINATION ${PROJECT_BINARY_DIR}
    PATH_VARS CMAKE_DIR_CONFIG CONFIG_DIR_CONFIG
    NO_CHECK_REQUIRED_COMPONENTS_MACRO
)

# Configure 'CTKAppLauncherLibConfig.cmake' for a install tree
set(CMAKE_DIR_CONFIG ${CTK_INSTALL_CMAKE_DIR})
set(CONFIG_DIR_CONFIG ${CTK_INSTALL_CONFIG_DIR})
set(CTKAppLauncher_CONFIG_CODE "")
set(launcherlib_install_config ${PROJECT_BINARY_DIR}/CMakeFiles/CTKAppLauncherLibConfig.cmake)
configure_package_config_file(
    CMake/CTKAppLauncherLibConfig.cmake.in
    ${launcherlib_install_config}
    INSTALL_DESTINATION ${CMAKE_INSTALL_PREFIX}/${CONFIG_DIR_CONFIG}
    PATH_VARS CMAKE_DIR_CONFIG CONFIG_DIR_CONFIG
    NO_CHECK_REQUIRED_COMPONENTS_MACRO
    )

# Configure 'CTKAppLauncherLibTargets.cmake'
export(TARGETS ${CTKAppLauncherLib_TARGETS} FILE ${PROJECT_BINARY_DIR}/${CTK_INSTALL_CMAKE_DIR}/CTKAppLauncherLibTargets.cmake)

if(CTKAppLauncher_INSTALL_LauncherLibrary)
  # Install 'CTKAppLauncherLibConfig.cmake'
  install(
    FILES ${launcherlib_install_config}
    DESTINATION ${CTK_INSTALL_CONFIG_DIR} COMPONENT Development
    )

  # Install 'CTKAppLauncherLibTargets.cmake'
  install(EXPORT CTKAppLauncherLibTargets
    FILE CTKAppLauncherLibTargets.cmake
    DESTINATION ${CTK_INSTALL_CMAKE_DIR}
    COMPONENT Development
  )
endif()

#-----------------------------------------------------------------------------
# Configure CTKAppLauncherConfig
#

# Configure 'CTKAppLauncherConfig.cmake' for a build tree
set(BIN_DIR_CONFIG ${PROJECT_BINARY_DIR}/${CTK_INSTALL_BIN_DIR})
set(CMAKE_DIR_CONFIG ${PROJECT_BINARY_DIR}/${CTK_INSTALL_CMAKE_DIR})
set(CONFIG_DIR_CONFIG ${PROJECT_BINARY_DIR})
set(SETTINGS_TEMPLATE_CONFIG "${PROJECT_BINARY_DIR}/${CTK_INSTALL_BIN_DIR}/CTKAppLauncherSettings.ini.in")
set(_additional_paths)
if(DEFINED CMAKE_CONFIGURATION_TYPES)
  foreach(type IN LISTS CMAKE_CONFIGURATION_TYPES)
    list(APPEND _additional_paths ${BIN_DIR_CONFIG}/${type})
  endforeach()
endif()
set(CTKAppLauncher_CONFIG_CODE "####### Expanded from \@CTKAppLauncher_CONFIG_CODE\@ #######\n")
set(CTKAppLauncher_CONFIG_CODE "${CTKAppLauncher_CONFIG_CODE}set(CTKAppLauncher_BIN_ADDITIONAL_PATHS \"${_additional_paths}\")\n")
set(CTKAppLauncher_CONFIG_CODE "${CTKAppLauncher_CONFIG_CODE}##################################################")
set(launcher_config ${PROJECT_BINARY_DIR}/CTKAppLauncherConfig.cmake)
configure_package_config_file(
    CMake/CTKAppLauncherConfig.cmake.in
    ${launcher_config}
    INSTALL_DESTINATION ${PROJECT_BINARY_DIR}
    PATH_VARS BIN_DIR_CONFIG CMAKE_DIR_CONFIG CONFIG_DIR_CONFIG SETTINGS_TEMPLATE_CONFIG
    NO_CHECK_REQUIRED_COMPONENTS_MACRO
)

# Configure 'CTKAppLauncherConfig.cmake' for an install tree
set(BIN_DIR_CONFIG ${CTK_INSTALL_BIN_DIR})
set(CMAKE_DIR_CONFIG ${CTK_INSTALL_CMAKE_DIR})
set(CONFIG_DIR_CONFIG ${CTK_INSTALL_CONFIG_DIR})
set(SETTINGS_TEMPLATE_CONFIG "${CTK_INSTALL_BIN_DIR}/CTKAppLauncherSettings.ini.in")
set(CTKAppLauncher_CONFIG_CODE "####### Expanded from \@CTKAppLauncher_CONFIG_CODE\@ #######\n")
set(CTKAppLauncher_CONFIG_CODE "${CTKAppLauncher_CONFIG_CODE}set(CTKAppLauncher_BIN_ADDITIONAL_PATHS \"\")\n")
set(CTKAppLauncher_CONFIG_CODE "${CTKAppLauncher_CONFIG_CODE}##################################################")
set(launcher_install_config ${PROJECT_BINARY_DIR}/CMakeFiles/CTKAppLauncherConfig.cmake)
configure_package_config_file(
    CMake/CTKAppLauncherConfig.cmake.in
    ${launcher_install_config}
    INSTALL_DESTINATION ${CMAKE_INSTALL_PREFIX}/${CONFIG_DIR_CONFIG}
    PATH_VARS BIN_DIR_CONFIG CMAKE_DIR_CONFIG CONFIG_DIR_CONFIG SETTINGS_TEMPLATE_CONFIG
    NO_CHECK_REQUIRED_COMPONENTS_MACRO
    )

# Install 'CTKAppLauncherConfig.cmake'
install(
  FILES ${launcher_install_config}
  DESTINATION ${CTK_INSTALL_CONFIG_DIR} COMPONENT Development
  )

#-----------------------------------------------------------------------------
# Setup CPack
#
include(CTKAppLauncherCPack.cmake)
