###########################################################################
#
#  Library:   CTK
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

#
# Depends on:
#  <SOURCE>/CMake/ctkMacroParseArguments.cmake
#

#
# See http://github.com/pieper/CTK/blob/master/CMake/ctkMacroBuildLib.cmake
#

#
# If you want to re-use this macro outside of CTK, the line referring to the following items
# may need to be updated to match your project:
#    - CTK_BASE_INCLUDE_DIRS
#    - ${CTK_SOURCE_DIR}/Libs/CTKExport.h.in
#    - CTK_LIBRARY_PROPERTIES
#    - CTK_INSTALL_BIN_DIR
#    - CTK_INSTALL_LIB_DIR
#    - CTK_BASE_LIBRARIES
#    - CTK_LIBRARIES
#

MACRO(ctkMacroBuildLib)
  SET(prefix ${PROJECT_NAME})
  IF(prefix STREQUAL "")
    MESSAGE(SEND_ERROR "prefix should NOT be empty !")
  ENDIF()
  ctkMacroParseArguments(${prefix}
    "NAME;EXPORT_DIRECTIVE;SRCS;MOC_SRCS;UI_FORMS;INCLUDE_DIRECTORIES;TARGET_LIBRARIES;RESOURCES;LIBRARY_TYPE;LABEL"
    ""
    ${ARGN}
    )

  # Sanity checks
  IF(NOT DEFINED ${prefix}_NAME)
    MESSAGE(SEND_ERROR "NAME is mandatory")
  ENDIF()
  IF(NOT DEFINED ${prefix}_LIBRARY_TYPE)
    SET(${prefix}_LIBRARY_TYPE "SHARED")
  ENDIF()
  IF(NOT DEFINED ${prefix}_LABEL)
    SET(${prefix}_LABEL ${${prefix}_NAME})
  ENDIF()
  IF(NOT DEFINED ${prefix}_EXPORT_DIRECTIVE)
    IF (${prefix}_LIBRARY_TYPE STREQUAL "SHARED")
      MESSAGE(SEND_ERROR "EXPORT_DIRECTIVE is mandatory")
    ENDIF()
  ENDIF()

  # Define library name
  SET(lib_name ${${prefix}_NAME})

  # --------------------------------------------------------------------------
  # Include dirs
  SET(my_includes
    ${CTK_BASE_INCLUDE_DIRS}
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    # with CMake >2.9, use QT4_MAKE_OUTPUT_FILE instead ?
    ${CMAKE_CURRENT_BINARY_DIR}/Resources/UI
    ${${prefix}_INCLUDE_DIRECTORIES}
    )  
  SET(CTK_BASE_INCLUDE_DIRS ${my_includes} CACHE INTERNAL "CTK includes" FORCE)
  INCLUDE_DIRECTORIES(${CTK_BASE_INCLUDE_DIRS})

  IF(${prefix}_LIBRARY_TYPE STREQUAL "SHARED")
    SET(MY_LIBRARY_EXPORT_DIRECTIVE ${${prefix}_EXPORT_DIRECTIVE})
    SET(MY_EXPORT_HEADER_PREFIX ${${prefix}_NAME})
    SET(MY_LIBNAME ${lib_name})
    
    CONFIGURE_FILE(
      ${CTK_SOURCE_DIR}/Libs/CTKExport.h.in
      ${CMAKE_CURRENT_BINARY_DIR}/${MY_EXPORT_HEADER_PREFIX}Export.h
      )
    SET(dynamicHeaders
      "${dynamicHeaders};${CMAKE_CURRENT_BINARY_DIR}/${MY_EXPORT_HEADER_PREFIX}Export.h")
  ENDIF()

  # Make sure variable are cleared
  SET(${prefix}_MOC_CXX)
  SET(${prefix}_UI_CXX)
  SET(${prefix}_QRC_SRCS)

  # Wrap
  QT4_WRAP_CPP(${prefix}_MOC_CXX ${${prefix}_MOC_SRCS})
  QT4_WRAP_UI(${prefix}_UI_CXX ${${prefix}_UI_FORMS})
  IF(DEFINED ${prefix}_RESOURCES)
    QT4_ADD_RESOURCES(${prefix}_QRC_SRCS ${${prefix}_RESOURCES})
  ENDIF()

  SOURCE_GROUP("Resources" FILES
    ${${prefix}_RESOURCES}
    ${${prefix}_UI_FORMS}
    )

  SOURCE_GROUP("Generated" FILES
    ${${prefix}_QRC_SRCS}
    ${${prefix}_MOC_CXX}
    ${${prefix}_UI_CXX}
    )
  
  ADD_LIBRARY(${lib_name} ${${prefix}_LIBRARY_TYPE}
    ${${prefix}_SRCS}
    ${${prefix}_MOC_CXX}
    ${${prefix}_UI_CXX}
    ${${prefix}_QRC_SRCS}
    )

  # Set labels associated with the target.
  SET_TARGET_PROPERTIES(${lib_name} PROPERTIES LABELS ${${prefix}_LABEL})

  # Apply user-defined properties to the library target.
  IF(CTK_LIBRARY_PROPERTIES AND ${prefix}_LIBRARY_TYPE STREQUAL "SHARED")
    SET_TARGET_PROPERTIES(${lib_name} PROPERTIES ${CTK_LIBRARY_PROPERTIES})
  ENDIF()

  # Install rules
  IF(CTK_BUILD_SHARED_LIBS)
    INSTALL(TARGETS ${lib_name}
      RUNTIME DESTINATION ${CTK_INSTALL_BIN_DIR} COMPONENT Runtime
      LIBRARY DESTINATION ${CTK_INSTALL_LIB_DIR} COMPONENT Runtime
      ARCHIVE DESTINATION ${CTK_INSTALL_LIB_DIR} COMPONENT Development)
  ENDIF()
  
  SET(my_libs
    ${${prefix}_TARGET_LIBRARIES}
    )
  TARGET_LINK_LIBRARIES(${lib_name} ${my_libs})

  # Update CTK_BASE_LIBRARIES
  IF (DEFINED CTK_LIBRARIES)
    SET(CTK_LIBRARIES ${CTK_LIBRARIES} ${lib_name} CACHE INTERNAL "CTK libraries" FORCE)
  ENDIF()
  SET(CTK_BASE_LIBRARIES ${my_libs} ${lib_name} CACHE INTERNAL "CTK base libraries" FORCE)
  
  # Install headers
  #FILE(GLOB headers "${CMAKE_CURRENT_SOURCE_DIR}/*.h")
  #INSTALL(FILES
  #  ${headers}
  #  ${dynamicHeaders}
  #  DESTINATION ${CTK_INSTALL_INCLUDE_DIR} COMPONENT Development
  #  )

ENDMACRO()
