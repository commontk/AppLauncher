###########################################################################
#
#  Library:   CTKAppLauncher
#
#  Copyright (c) 2010  Kitware Inc.
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

cmake_minimum_required(VERSION 2.8.6)

#-----------------------------------------------------------------------------
project(CTKAppLauncher)
#-----------------------------------------------------------------------------

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
# Output directories.
foreach(type LIBRARY RUNTIME ARCHIVE)
  if(NOT CMAKE_${type}_OUTPUT_DIRECTORY)
    set(CMAKE_${type}_OUTPUT_DIRECTORY ${${PROJECT_NAME}_BINARY_DIR}/bin CACHE INTERNAL "Single output directory for building all libraries.")
  endif()
endforeach()

#-----------------------------------------------------------------------------
# CTKAppLauncher version number.
#
set(CTKAppLauncher_MAJOR_VERSION 0)
set(CTKAppLauncher_MINOR_VERSION 1)
set(CTKAppLauncher_BUILD_VERSION 4)
set(CTKAppLauncher_VERSION_IS_RELEASE 0)
#set(CTKAppLauncher_VERSION_RC 1)

if(CTKAppLauncher_VERSION_IS_RELEASE)
  set(CTKAppLauncher_VERSION_SOURCE "")
else()
  include(${CMAKE_SOURCE_DIR}/CMake/ctkVersionSource.cmake)
endif()

# Compute the full version string.
set(CTKAppLauncher_VERSION
    "${CTKAppLauncher_MAJOR_VERSION}.${CTKAppLauncher_MINOR_VERSION}.${CTKAppLauncher_BUILD_VERSION}")
if(CTKAppLauncher_VERSION_RC)
  set(CTKAppLauncher_VERSION ${CTKAppLauncher_VERSION}-rc${CTKAppLauncher_VERSION_RC})
endif()
if(CTKAppLauncher_VERSION_SOURCE)
  set(CTKAppLauncher_VERSION ${CTKAppLauncher_VERSION}-${CTKAppLauncher_VERSION_SOURCE})
endif()
message(STATUS "CTKAppLauncher version: ${CTKAppLauncher_VERSION}")

#-----------------------------------------------------------------------------
# Install directories, used for install rules.
#
set(CTK_INSTALL_BIN_DIR "bin")
set(CTK_INSTALL_LIB_DIR "lib")
set(CTK_INSTALL_INCLUDE_DIR "include")
set(CTK_INSTALL_DOC_DIR "doc")

#-----------------------------------------------------------------------------
# Update CMake module path
#
set(CMAKE_MODULE_PATH
  "${CMAKE_CURRENT_SOURCE_DIR}/CMake"
  ${CMAKE_MODULE_PATH})

#-----------------------------------------------------------------------------
# Clear CTK_BASE_INCLUDE_DIRS and CTK_BASE_LIBRARIES
#
set(CTK_BASE_LIBRARIES CACHE INTERNAL "CTK base libraries" FORCE)
set(CTK_BASE_INCLUDE_DIRS CACHE INTERNAL "CTK includes" FORCE)

#-----------------------------------------------------------------------------
# CMake function(s) and macro(s)
#
include(ctkMacroBuildLib)
include(ctkMacroGenerateMocs)

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
# Set C/CXX Flags
#
set(cflags)
if(CMAKE_COMPILER_IS_GNUCXX)
  set(cflags "-Wall -Wextra -Wpointer-arith -Winvalid-pch -Wcast-align -Wwrite-strings -D_FORTIFY_SOURCE=2")
endif()
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS_INIT} ${cflags} ${COVERAGE_C_FLAGS} ${ADDITIONAL_C_FLAGS}" CACHE STRING "CMake C Flags" FORCE)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS_INIT} ${cflags} ${COVERAGE_CXX_FLAGS} ${ADDITIONAL_CXX_FLAGS}" CACHE STRING "CMake CXX Flags" FORCE)

# This is a cross-platform project so we cannot use the MS _s API.
if(MSVC)
  add_definitions(
    -D_CRT_SECURE_NO_WARNINGS
    )
endif()

#-----------------------------------------------------------------------------
# Qt
#
find_package(Qt4 4.6 REQUIRED)
set(QT_USE_QTTEST ${BUILD_TESTING})
include(${QT_USE_FILE})

#-----------------------------------------------------------------------------
# Update CTK_BASE_LIBRARIES with QT libraries
#
set(CTK_BASE_LIBRARIES ${CTK_BASE_LIBRARIES} ${QT_LIBRARIES} CACHE INTERNAL "CTK base libraries" FORCE)

#-----------------------------------------------------------------------------
# Build ctkAppLauncherBase and associated tests
#
add_subdirectory(Base)

#-----------------------------------------------------------------------------
# Build executable
#
include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_CURRENT_BINARY_DIR}
  ${CTK_BASE_INCLUDE_DIRS}
  )

# Add excutable
add_executable(${PROJECT_NAME}
  Main.cpp
  )

target_link_libraries(${PROJECT_NAME} ${CTK_BASE_LIBRARIES})

if(QT_MAC_USE_COCOA)
  target_link_libraries(${PROJECT_NAME} "-framework cocoa")
endif()

# Set labels associated with the target.
set_target_properties(${PROJECT_NAME} PROPERTIES LABELS ctkAppLauncher)

if(BUILD_TESTING)
  add_subdirectory(Testing)
endif()

# Install rules
install(TARGETS ${PROJECT_NAME}
  RUNTIME DESTINATION ${CTK_INSTALL_BIN_DIR} COMPONENT Runtime
  LIBRARY DESTINATION ${CTK_INSTALL_LIB_DIR} COMPONENT Runtime
  ARCHIVE DESTINATION ${CTK_INSTALL_LIB_DIR} COMPONENT Development)

install(FILES
  CMake/ctkAppLauncher.cmake
  CMake/ctkAppLauncher-configure.cmake
  DESTINATION CMake COMPONENT Development)

install(FILES
  CTKAppLauncherSettings.ini.in
  DESTINATION ${CTK_INSTALL_BIN_DIR} COMPONENT Development)

# Setup CPack
include(CTKAppLauncherCPack.cmake)
