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

CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

#-----------------------------------------------------------------------------
# See http://cmake.org/cmake/help/cmake-2-8-docs.html#section_Policies for details
#

SET(project_policies
  CMP0001 # NEW: CMAKE_BACKWARDS_COMPATIBILITY should no longer be used.
  CMP0002 # NEW: Logical target names must be globally unique.
  CMP0003 # NEW: Libraries linked via full path no longer produce linker search paths.
  CMP0004 # NEW: Libraries linked may NOT have leading or trailing whitespace.
  CMP0005 # NEW: Preprocessor definition values are now escaped automatically.
  CMP0006 # NEW: Installing MACOSX_BUNDLE targets requires a BUNDLE DESTINATION.
  CMP0007 # NEW: List command no longer ignores empty elements.
  CMP0008 # NEW: Libraries linked by full-path must have a valid library file name.
  CMP0009 # NEW: FILE GLOB_RECURSE calls should not follow symlinks by default.
  CMP0010 # NEW: Bad variable reference syntax is an error.
  CMP0011 # NEW: Included scripts do automatic cmake_policy PUSH and POP.
  CMP0012 # NEW: if() recognizes numbers and boolean constants.
  CMP0013 # NEW: Duplicate binary directories are not allowed.
  CMP0014 # NEW: Input directories must have CMakeLists.txt
  )
FOREACH(policy ${project_policies})
  IF(POLICY ${policy})
    CMAKE_POLICY(SET ${policy} NEW)
  ENDIF()
ENDFOREACH()

#-----------------------------------------------------------------------------
PROJECT(CTKAppLauncher)
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# Output directories.
#
FOREACH(type LIBRARY RUNTIME ARCHIVE)
  IF(NOT CMAKE_${type}_OUTPUT_DIRECTORY)
    SET(CMAKE_${type}_OUTPUT_DIRECTORY ${${PROJECT_NAME}_BINARY_DIR}/bin CACHE INTERNAL "Single output directory for building all libraries.")
  ENDIF()
ENDFOREACH()

#-----------------------------------------------------------------------------
# CTKAppLauncher version number.  An even minor number corresponds to releases.
#
SET(CTKAppLauncher_MAJOR_VERSION 0)
SET(CTKAppLauncher_MINOR_VERSION 1)
SET(CTKAppLauncher_BUILD_VERSION 3)
SET(CTKAppLauncher_VERSION
    "${CTKAppLauncher_MAJOR_VERSION}.${CTKAppLauncher_MINOR_VERSION}.${CTKAppLauncher_BUILD_VERSION}")

#-----------------------------------------------------------------------------
# Install directories, used for install rules.
#
SET(CTK_INSTALL_BIN_DIR "bin")
SET(CTK_INSTALL_LIB_DIR "lib")
SET(CTK_INSTALL_INCLUDE_DIR "include")
SET(CTK_INSTALL_DOC_DIR "doc")

#-----------------------------------------------------------------------------
# Update CMake module path
#
SET(CMAKE_MODULE_PATH
  "${CMAKE_CURRENT_SOURCE_DIR}/CMake"
  ${CMAKE_MODULE_PATH})
  
#-----------------------------------------------------------------------------
# Clear CTK_BASE_INCLUDE_DIRS and CTK_BASE_LIBRARIES
#
SET(CTK_BASE_LIBRARIES CACHE INTERNAL "CTK base libraries" FORCE)
SET(CTK_BASE_INCLUDE_DIRS CACHE INTERNAL "CTK includes" FORCE)
  
#-----------------------------------------------------------------------------
# CMake Function(s) and Macro(s)
#
INCLUDE(CMake/ctkMacroParseArguments.cmake)
INCLUDE(CMake/ctkMacroBuildLib.cmake)
    
#-----------------------------------------------------------------------------
# Testing
#
OPTION(BUILD_TESTING "Test the project" ON)
IF(BUILD_TESTING)
  ENABLE_TESTING()
  INCLUDE(CTest)
  SET(CPP_TEST_PATH ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
  MARK_AS_ADVANCED(TCL_TCLSH DART_ROOT)
    
  # Setup file for setting custom ctest vars
  CONFIGURE_FILE(
    CMake/CTestCustom.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/CTestCustom.cmake
    @ONLY
    )

  # Configuration for the CMake-generated test driver
  SET(CMAKE_TESTDRIVER_EXTRA_INCLUDES "#include <stdexcept>")
  SET(CMAKE_TESTDRIVER_BEFORE_TESTMAIN "
    try
      {")
  SET(CMAKE_TESTDRIVER_AFTER_TESTMAIN "    }
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
ENDIF()

#-----------------------------------------------------------------------------
# Additional Linker Flags
#

SET(ADDITIONAL_EXE_LINKER_FLAGS_RELEASE "" 
  CACHE STRING "Additional flags used by the linker during release builds.")
MARK_AS_ADVANCED(ADDITIONAL_EXE_LINKER_FLAGS_RELEASE)

SET(ADDITIONAL_EXE_LINKER_FLAGS_MINSIZEREL "" 
  CACHE STRING "Additional flags used by the linker during release minsize builds.")
MARK_AS_ADVANCED(ADDITIONAL_EXE_LINKER_FLAGS_MINSIZEREL)

SET(ADDITIONAL_EXE_LINKER_FLAGS_RELWITHDEBINFO "" 
  CACHE STRING "Additional flags used by the linker during Release with Debug Info builds.")
MARK_AS_ADVANCED(ADDITIONAL_EXE_LINKER_FLAGS_RELWITHDEBINFO)

SET(ADDITIONAL_EXE_LINKER_FLAGS_DEBUG "" 
  CACHE STRING "Additional flags used by the linker during debug builds.")
MARK_AS_ADVANCED(ADDITIONAL_EXE_LINKER_FLAGS_DEBUG)

#-----------------------------------------------------------------------------
# Specific Linker Flags
#
SET(SPECIFIC_EXE_LINKER_FLAGS_RELEASE)
SET(SPECIFIC_EXE_LINKER_FLAGS_MINSIZEREL)
SET(SPECIFIC_EXE_LINKER_FLAGS_RELWITHDEBINFO)
SET(SPECIFIC_EXE_LINKER_FLAGS_DEBUG)

IF(MSVC90)
  SET(SPECIFIC_EXE_LINKER_FLAGS_DEBUG "/NODEFAULTLIB:msvcrtd.lib")
ENDIF()

#-----------------------------------------------------------------------------
# Set Linker Flags
#
SET(CMAKE_EXE_LINKER_FLAGS_RELEASE 
  "${ADDITIONAL_EXE_LINKER_FLAGS_RELEASE} ${SPECIFIC_EXE_LINKER_FLAGS_RELEASE}" 
  CACHE STRING "Flags used by the linker during release builds." FORCE)
  
SET(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL 
  "${ADDITIONAL_EXE_LINKER_FLAGS_MINSIZEREL} ${SPECIFIC_EXE_LINKER_FLAGS_MINSIZEREL}" 
  CACHE STRING "Flags used by the linker during release minsize builds." FORCE)
  
SET(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO 
  "${ADDITIONAL_EXE_LINKER_FLAGS_RELWITHDEBINFO} ${SPECIFIC_EXE_LINKER_FLAGS_RELWITHDEBINFO}" 
  CACHE STRING "Flags used by the linker during Release with Debug Info builds." FORCE)
  
SET(CMAKE_EXE_LINKER_FLAGS_DEBUG 
  "${ADDITIONAL_EXE_LINKER_FLAGS_DEBUG} ${SPECIFIC_EXE_LINKER_FLAGS_DEBUG}" 
  CACHE STRING "Flags used by the linker during debug builds." FORCE)

#-----------------------------------------------------------------------------
# Coverage
#
OPTION(WITH_COVERAGE "Enable/Disable coverage" OFF)

#-----------------------------------------------------------------------------
# Additional CXX/C Flags
#
SET(ADDITIONAL_C_FLAGS "" CACHE STRING "Additional C Flags")
MARK_AS_ADVANCED(ADDITIONAL_C_FLAGS)
SET(ADDITIONAL_CXX_FLAGS "" CACHE STRING "Additional CXX Flags")
MARK_AS_ADVANCED(ADDITIONAL_CXX_FLAGS)

#-----------------------------------------------------------------------------
# Set coverage Flags
#
IF(WITH_COVERAGE)
  IF(CMAKE_CXX_COMPILER_ID AND ${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
    SET(coverage_flags "-g -fdiagnostics-show-option -fprofile-arcs -ftest-coverage -O3 -DNDEBUG")
    SET(COVERAGE_C_FLAGS ${coverage_flags})
    SET(COVERAGE_CXX_FLAGS ${coverage_flags})
  ENDIF()
ENDIF()

#-----------------------------------------------------------------------------
# Set C/CXX Flags
#
SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS_INIT} ${COVERAGE_C_FLAGS} ${ADDITIONAL_C_FLAGS}" CACHE STRING "CMake C Flags" FORCE)
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS_INIT} ${COVERAGE_CXX_FLAGS} ${ADDITIONAL_CXX_FLAGS}" CACHE STRING "CMake CXX Flags" FORCE)


#-----------------------------------------------------------------------------
# Qt
#
FIND_PACKAGE(Qt4 4.6 REQUIRED)
INCLUDE(${QT_USE_FILE})

#-----------------------------------------------------------------------------
# Update CTK_BASE_LIBRARIES with QT libraries
#
SET(CTK_BASE_LIBRARIES ${CTK_BASE_LIBRARIES} ${QT_LIBRARIES} CACHE INTERNAL "CTK base libraries" FORCE)

#-----------------------------------------------------------------------------
# Build ctkAppLauncherBase and associated tests
#
ADD_SUBDIRECTORY(Base)

#-----------------------------------------------------------------------------
# Build executable
#
INCLUDE_DIRECTORIES(
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_CURRENT_BINARY_DIR}
  ${CTK_BASE_INCLUDE_DIRS}
  )

# Add excutable
ADD_EXECUTABLE(${PROJECT_NAME}
  Main.cpp
  )

TARGET_LINK_LIBRARIES(${PROJECT_NAME} ${CTK_BASE_LIBRARIES})

IF(QT_MAC_USE_COCOA)
  TARGET_LINK_LIBRARIES(${PROJECT_NAME} "-framework cocoa")
ENDIF()

# Set labels associated with the target.
SET_TARGET_PROPERTIES(${PROJECT_NAME} PROPERTIES LABELS ctkAppLauncher)

IF(BUILD_TESTING)
  ADD_SUBDIRECTORY(Testing)
ENDIF()

# Install rules
INSTALL(TARGETS ${PROJECT_NAME}
  RUNTIME DESTINATION ${CTK_INSTALL_BIN_DIR} COMPONENT Runtime
  LIBRARY DESTINATION ${CTK_INSTALL_LIB_DIR} COMPONENT Runtime
  ARCHIVE DESTINATION ${CTK_INSTALL_LIB_DIR} COMPONENT Development)

INSTALL(FILES
  CMake/ctkAppLauncher.cmake
  CMake/ctkAppLauncher-configure.cmake
  DESTINATION CMake COMPONENT Development)

INSTALL(FILES
  CTKAppLauncherSettings.ini.in
  DESTINATION ${CTK_INSTALL_BIN_DIR} COMPONENT Development)

# Setup CPack
INCLUDE(CTKAppLauncherCPack.cmake)
