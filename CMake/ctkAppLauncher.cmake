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
#  ctkAppLauncherConfigure
#
#    EXECUTABLE 
#
#    APPLICATION_NAME
#
#    TARGET
#
#    APPLICATION_INSTALL_SUBDIR
#
#    SETTINGS_TEMPLATE
#
#    DESTINATION_DIR
#
#    SPLASHSCREEN_HIDE_DELAY_MS
#
#    SPLASH_IMAGE_PATH
#
#    SPLASH_IMAGE_INSTALL_SUBDIR
#
#    DEFAULT_APPLICATION_ARGUMENT
#
#    EXTRA_APPLICATION_TO_LAUNCH_BUILD
#
#    EXTRA_APPLICATION_TO_LAUNCH_INSTALLED
#
#    LIBRARY_PATHS_BUILD
#
#    LIBRARY_PATHS_INSTALLED
#
#    PATHS_BUILD
#
#    PATHS_INSTALLED
#
#    ENVVARS_BUILD
#
#    ENVVARS_INSTALLED
#
#    HELP_SHORT_ARG
#
#    HELP_LONG_ARG
#
#    NOSPLASH_SHORT_ARG
#
#    NOSPLASH_LONG_ARG
#  

# By requiring version 2.8, we also make sure CMP0007 is set to NEW
CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

#
# Helper macro used internally - See http://www.cmake.org/Wiki/CMakeMacroParseArguments
#
MACRO(ctkAppLauncherMacroParseArguments prefix arg_names option_names)
  SET(DEFAULT_ARGS)
  FOREACH(arg_name ${arg_names})
    SET(${prefix}_${arg_name})
  ENDFOREACH(arg_name)
  FOREACH(option ${option_names})
    SET(${prefix}_${option} FALSE)
  ENDFOREACH(option)

  SET(current_arg_name DEFAULT_ARGS)
  SET(current_arg_list)
  FOREACH(arg ${ARGN})
    SET(larg_names ${arg_names})
    LIST(FIND larg_names "${arg}" is_arg_name)
    IF (is_arg_name GREATER -1)
      SET(${prefix}_${current_arg_name} ${current_arg_list})
      SET(current_arg_name ${arg})
      SET(current_arg_list)
    ELSE (is_arg_name GREATER -1)
      SET(loption_names ${option_names})    
      LIST(FIND loption_names "${arg}" is_option)
      IF (is_option GREATER -1)
        SET(${prefix}_${arg} TRUE)
      ELSE (is_option GREATER -1)
        SET(current_arg_list ${current_arg_list} ${arg})
      ENDIF (is_option GREATER -1)
    ENDIF (is_arg_name GREATER -1)
  ENDFOREACH(arg)
  SET(${prefix}_${current_arg_name} ${current_arg_list})
ENDMACRO()

#
# ctkAppLauncherGenerateQtSettingsArray(ITEMS ITEMNAME OUTPUTVAR)
#
FUNCTION(ctkAppLauncherListToQtSettingsArray ITEMS ITEMNAME OUTPUTVAR)
  SET(idx 1)
  SET(SETTINGS_ARRAY)
  LIST(LENGTH ITEMS item_count)
  FOREACH(item ${ITEMS})
    SET(SETTINGS_ARRAY "${SETTINGS_ARRAY}${idx}\\\\${ITEMNAME}=${item}\n")
    MATH(EXPR idx "${idx} + 1")
  ENDFOREACH()
  SET(SETTINGS_ARRAY "${SETTINGS_ARRAY}size=${item_count}")
  SET(${OUTPUTVAR} ${SETTINGS_ARRAY} PARENT_SCOPE)
ENDFUNCTION()

#
# ctkAppLauncherAppendExtraAppToLaunchToList(
#      LONG_ARG longarg
#      [SHORT_ARG shortarg]
#      [HELP help]
#      PATH path
#      [ARGUMENTS arguments]
#      OUTPUTVAR)
#
FUNCTION(ctkAppLauncherAppendExtraAppToLaunchToList)
  ctkAppLauncherMacroParseArguments(MY
    "LONG_ARG;SHORT_ARG;HELP;PATH;ARGUMENTS;OUTPUTVAR"
    ""
    ${ARGN}
    )
  # Sanity checks - Are mandatory variable defined
  FOREACH(varname LONG_ARG PATH OUTPUTVAR)
    IF(NOT DEFINED MY_${varname})
      MESSAGE(FATAL_ERROR "${varname} is mandatory")
    ENDIF()
  ENDFOREACH()
  SET(output "${MY_LONG_ARG}^^")
  SET(output "${output}${MY_SHORT_ARG}^^")
  SET(output "${output}${MY_HELP}^^")
  SET(output "${output}${MY_PATH}^^")
  SET(output "${output}${MY_ARGUMENTS}")
  SET(output_list ${${MY_OUTPUTVAR}})
  LIST(APPEND output_list ${output})
  SET(${MY_OUTPUTVAR} ${output_list} PARENT_SCOPE)
ENDFUNCTION()

#
# ctkAppLauncherExtraAppToLaunchListToQtSettings()
#
FUNCTION(ctkAppLauncherExtraAppToLaunchListToQtSettings)
  ctkAppLauncherMacroParseArguments(MY
    "LIST;OUTPUTVAR"
    ""
    ${ARGN}
    )
  # Sanity checks - Are mandatory variable defined
  FOREACH(varname LIST OUTPUTVAR)
    IF(NOT DEFINED MY_${varname})
      MESSAGE(FATAL_ERROR "${varname} is mandatory")
    ENDIF()
  ENDFOREACH()
  SET(settings)
  FOREACH(item ${MY_LIST})
    # Split by "^^"
    STRING(REPLACE "^^" "\\;" item ${item})
    SET(item_list ${item})
    # Extract 'application to launch' properties
    LIST(GET item_list 0 longArgument)
    LIST(GET item_list 1 shortArgument)
    LIST(GET item_list 2 help)
    LIST(GET item_list 3 path)
    LIST(GET item_list 4 arguments)
    # Generate settings
    SET(settings "${settings}\n")
    SET(settings "${settings}${longArgument}/shortArgument=${shortArgument}\n")
    SET(settings "${settings}${longArgument}/help=${help}\n")
    SET(settings "${settings}${longArgument}/path=${path}\n")
    SET(settings "${settings}${longArgument}/arguments=${arguments}\n")
    #message("longArgument:${longArgument}, shortArgument:${shortArgument}, help:${help}, path:${path}, arguments:${arguments}")
  ENDFOREACH()
  SET(${MY_OUTPUTVAR} ${settings} PARENT_SCOPE)
ENDFUNCTION()

#
# ctkAppLauncherConfigure
#
MACRO(ctkAppLauncherConfigure)
  ctkAppLauncherMacroParseArguments(CTKAPPLAUNCHER
    "EXECUTABLE;APPLICATION_NAME;TARGET;APPLICATION_INSTALL_SUBDIR;SETTINGS_TEMPLATE;DESTINATION_DIR;SPLASHSCREEN_HIDE_DELAY_MS;SPLASH_IMAGE_PATH;SPLASH_IMAGE_INSTALL_SUBDIR;DEFAULT_APPLICATION_ARGUMENT;EXTRA_APPLICATION_TO_LAUNCH_BUILD;EXTRA_APPLICATION_TO_LAUNCH_INSTALLED;LIBRARY_PATHS_BUILD;LIBRARY_PATHS_INSTALLED;PATHS_BUILD;PATHS_INSTALLED;ENVVARS_BUILD;ENVVARS_INSTALLED;HELP_SHORT_ARG;HELP_LONG_ARG;NOSPLASH_SHORT_ARG;NOSPLASH_LONG_ARG"
    "VERBOSE_CONFIG"
    ${ARGN}
    )
  
  # If CTKAPPLAUNCHER_DIR is set, try to autodiscover the location of launcher executable and settings template file
  IF(EXISTS "${CTKAPPLAUNCHER_DIR}")
    UNSET(CTKAPPLAUNCHER_EXECUTABLE CACHE)
    FIND_PROGRAM(CTKAPPLAUNCHER_EXECUTABLE CTKAppLauncher PATHS ${CTKAPPLAUNCHER_DIR}/bin NO_DEFAULT_PATH)
    UNSET(CTKAPPLAUNCHER_SETTINGS_TEMPLATE CACHE)
    FIND_FILE(CTKAPPLAUNCHER_SETTINGS_TEMPLATE CTKAppLauncherSettings.ini.in PATHS ${CTKAPPLAUNCHER_DIR}/bin NO_DEFAULT_PATH)
  ENDIF()
    
  # Sanity checks - Are mandatory variable defined
  FOREACH(varname EXECUTABLE APPLICATION_NAME TARGET SETTINGS_TEMPLATE DESTINATION_DIR)
    IF(NOT DEFINED CTKAPPLAUNCHER_${varname})
      MESSAGE(FATAL_ERROR "${varname} is mandatory")
    ENDIF()
  ENDFOREACH()
  
  # Sanity checks - Make sure TARGET is valid
  IF(NOT TARGET ${CTKAPPLAUNCHER_TARGET})
    MESSAGE(FATAL_ERROR "TARGET specified doesn't seem to be correct !")
  ENDIF()
  
  # Sanity checks - Do files/directories exist ?
  FOREACH(varname EXECUTABLE SETTINGS_TEMPLATE DESTINATION_DIR)
    IF(NOT EXISTS ${CTKAPPLAUNCHER_${varname}})
      MESSAGE(FATAL_ERROR "${varname} [${CTKAPPLAUNCHER_${varname}}] doesn't seem to exist !")
    ENDIF()
  ENDFOREACH()
  
  # Set splash image name
  SET(CTKAPPLAUNCHER_SPLASH_IMAGE_NAME)
  IF(DEFINED CTKAPPLAUNCHER_SPLASH_IMAGE_PATH)
    IF(NOT EXISTS ${CTKAPPLAUNCHER_SPLASH_IMAGE_PATH})
      MESSAGE(FATAL_ERROR "SPLASH_IMAGE_PATH [${CTKAPPLAUNCHER_SPLASH_IMAGE_PATH}] doesn't seem to exist !")
    ENDIF()
    get_filename_component(CTKAPPLAUNCHER_SPLASH_IMAGE_NAME ${CTKAPPLAUNCHER_SPLASH_IMAGE_PATH} NAME)
    get_filename_component(CTKAPPLAUNCHER_SPLASH_IMAGE_PATH ${CTKAPPLAUNCHER_SPLASH_IMAGE_PATH} PATH)
  ENDIF()
  
  # Set splashscreen hide delay in ms
  IF(DEFINED CTKAPPLAUNCHER_SPLASHSCREEN_HIDE_DELAY_MS)
    IF(CTKAPPLAUNCHER_SPLASHSCREEN_HIDE_DELAY_MS LESS 0)
      MESSAGE(FATAL_ERROR "SPLASHSCREEN_HIDE_DELAY_MS [${CTKAPPLAUNCHER_SPLASHSCREEN_HIDE_DELAY_MS}] should be >= 0 !")
    ENDIF()
  ELSE()
    SET(SPLASHSCREEN_HIDE_DELAY_MS 0)
  ENDIF()
  
  #-----------------------------------------------------------------------------
  # Settings shared between the build tree and install tree.
  
  SET(COMMON_SETTING_VARS
    CTKAPPLAUNCHER_EXECUTABLE
    CTKAPPLAUNCHER_SETTINGS_TEMPLATE 
    CTKAPPLAUNCHER_APPLICATION_NAME
    CTKAPPLAUNCHER_DESTINATION_DIR
    CTKAPPLAUNCHER_SPLASHSCREEN_HIDE_DELAY_MS
    CTKAPPLAUNCHER_HELP_SHORT_ARG
    CTKAPPLAUNCHER_HELP_LONG_ARG
    CTKAPPLAUNCHER_NOSPLASH_SHORT_ARG
    CTKAPPLAUNCHER_NOSPLASH_LONG_ARG
    CTKAPPLAUNCHER_APPLICATION_DEFAULT_ARGUMENTS
    CTKAPPLAUNCHER_SPLASH_IMAGE_NAME
    )
  SET(COMMON_SETTINGS)
  FOREACH(v ${COMMON_SETTING_VARS})
    SET(COMMON_SETTINGS "${COMMON_SETTINGS}
SET(${v} \"${${v}}\")")
  ENDFOREACH()
  
  # Retrieve the output name of the target application
  GET_TARGET_PROPERTY(CTKAPPLAUNCHER_TARGET_OUTPUT_NAME
    ${CTKAPPLAUNCHER_TARGET} OUTPUT_NAME)
  
  # Default to target name if OUTPUT_NAME is not set
  IF(NOT CTKAPPLAUNCHER_TARGET_OUTPUT_NAME)
    SET(CTKAPPLAUNCHER_TARGET_OUTPUT_NAME ${CTKAPPLAUNCHER_TARGET})
  ENDIF()
  
  # Let's dump settings common to build and install config into a file.
  FILE(WRITE ${CMAKE_CURRENT_BINARY_DIR}/CTKAppLauncher-${CTKAPPLAUNCHER_TARGET_OUTPUT_NAME}-common-settings.cmake
"${COMMON_SETTINGS}")

  #-----------------------------------------------------------------------------
  # Settings specific to the build tree.
  
  SET(CTKAPPLAUNCHER_SPLASH_IMAGE_SUBDIR)
  IF (DEFINED CTKAPPLAUNCHER_SPLASH_IMAGE_PATH AND NOT ${CTKAPPLAUNCHER_SPLASH_IMAGE_PATH} STREQUAL "")
    SET(CTKAPPLAUNCHER_SPLASH_IMAGE_SUBDIR "${CTKAPPLAUNCHER_SPLASH_IMAGE_PATH}/")
  ENDIF()
  
  # Retrieve location of the target application
  GET_TARGET_PROPERTY(CTKAPPLAUNCHER_TARGET_DIR 
    ${CTKAPPLAUNCHER_TARGET} RUNTIME_OUTPUT_DIRECTORY)

  FILE(RELATIVE_PATH CTKAPPLAUNCHER_APPLICATION_RELPATH ${CTKAPPLAUNCHER_DESTINATION_DIR} ${CTKAPPLAUNCHER_TARGET_DIR})
  SET(CTKAPPLAUNCHER_APPLICATION_SUBDIR)
  IF(NOT "${CTKAPPLAUNCHER_APPLICATION_RELPATH}" STREQUAL "")
    SET(CTKAPPLAUNCHER_APPLICATION_SUBDIR "${CTKAPPLAUNCHER_APPLICATION_RELPATH}/")
  ENDIF()
  SET(CTKAPPLAUNCHER_APPLICATION_SUBDIR "<APPLAUNCHER_DIR>/${CTKAPPLAUNCHER_APPLICATION_SUBDIR}")
  
  IF(APPLE)
    # Is the target an app bundle?
    GET_TARGET_PROPERTY(CTK_APPLAUNCHER_TARGET_BUNDLE ${CTKAPPLAUNCHER_TARGET} MACOSX_BUNDLE)

    IF(CTK_APPLAUNCHER_TARGET_BUNDLE)
      SET(CTKAPPLAUNCHER_APPLICATION_SUBDIR "${CTKAPPLAUNCHER_APPLICATION_SUBDIR}${CTKAPPLAUNCHER_APPLICATION_NAME}.app/Contents/MacOS/")
    ENDIF()
  ENDIF()

  SET(CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH)
  IF(DEFINED CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH_BUILD)
    ctkAppLauncherExtraAppToLaunchListToQtSettings(
      LIST ${CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH_BUILD}
      OUTPUTVAR CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH)
  ENDIF()
  
  SET(CTKAPPLAUNCHER_LIBRARY_PATHS)
  ctkAppLauncherListToQtSettingsArray("${CTKAPPLAUNCHER_LIBRARY_PATHS_BUILD}" "path" CTKAPPLAUNCHER_LIBRARY_PATHS)
  
  SET(CTKAPPLAUNCHER_PATHS)
  ctkAppLauncherListToQtSettingsArray("${CTKAPPLAUNCHER_PATHS_BUILD}" "path" CTKAPPLAUNCHER_PATHS)
  
  SET(CTKAPPLAUNCHER_ENVVARS)
  FOREACH(envvar ${CTKAPPLAUNCHER_ENVVARS_BUILD})
    SET(CTKAPPLAUNCHER_ENVVARS "${CTKAPPLAUNCHER_ENVVARS}${envvar}\n")
  ENDFOREACH()
  
  # Let's dump settings specific to build config into a file.
  FILE(WRITE ${CMAKE_CURRENT_BINARY_DIR}/CTKAppLauncher-${CTKAPPLAUNCHER_TARGET_OUTPUT_NAME}-buildtree-settings.cmake 
"SET(CTKAPPLAUNCHER_APPLICATION_SUBDIR \"${CTKAPPLAUNCHER_APPLICATION_SUBDIR}\")
SET(CTKAPPLAUNCHER_SPLASH_IMAGE_SUBDIR \"${CTKAPPLAUNCHER_SPLASH_IMAGE_SUBDIR}\")
SET(CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH \"${CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH}\")
SET(CTKAPPLAUNCHER_LIBRARY_PATHS \"${CTKAPPLAUNCHER_LIBRARY_PATHS}\")
SET(CTKAPPLAUNCHER_PATHS \"${CTKAPPLAUNCHER_PATHS}\")
SET(CTKAPPLAUNCHER_ENVVARS \"${CTKAPPLAUNCHER_ENVVARS}\")
")
  
  #-----------------------------------------------------------------------------
  # Settings specific to the install tree.
  
  SET(CTKAPPLAUNCHER_SPLASH_IMAGE_SUBDIR)
  IF (DEFINED CTKAPPLAUNCHER_SPLASH_IMAGE_INSTALL_SUBDIR AND NOT ${CTKAPPLAUNCHER_SPLASH_IMAGE_INSTALL_SUBDIR} STREQUAL "")
    SET(CTKAPPLAUNCHER_SPLASH_IMAGE_SUBDIR "<APPLAUNCHER_DIR>/${CTKAPPLAUNCHER_SPLASH_IMAGE_INSTALL_SUBDIR}/")
  ENDIF()
  
  SET(CTKAPPLAUNCHER_APPLICATION_SUBDIR)
  IF(NOT "${CTKAPPLAUNCHER_APPLICATION_INSTALL_SUBDIR}" STREQUAL "")
    SET(CTKAPPLAUNCHER_APPLICATION_SUBDIR "${CTKAPPLAUNCHER_APPLICATION_INSTALL_SUBDIR}/")
  ENDIF()
  SET(CTKAPPLAUNCHER_APPLICATION_SUBDIR "<APPLAUNCHER_DIR>/${CTKAPPLAUNCHER_APPLICATION_SUBDIR}")
  
  SET(CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH)
  IF(DEFINED CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH_INSTALLED)
    ctkAppLauncherExtraAppToLaunchListToQtSettings(
      LIST ${CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH_INSTALLED}
      OUTPUTVAR CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH)
  ENDIF()

  SET(CTKAPPLAUNCHER_LIBRARY_PATHS)
  ctkAppLauncherListToQtSettingsArray("${CTKAPPLAUNCHER_LIBRARY_PATHS_INSTALLED}" "path" CTKAPPLAUNCHER_LIBRARY_PATHS)
  
  SET(CTKAPPLAUNCHER_PATHS)
  ctkAppLauncherListToQtSettingsArray("${CTKAPPLAUNCHER_PATHS_INSTALLED}" "path" CTKAPPLAUNCHER_PATHS)
  
  SET(CTKAPPLAUNCHER_ENVVARS)
  FOREACH(envvar ${CTKAPPLAUNCHER_ENVVARS_INSTALLED})
    SET(CTKAPPLAUNCHER_ENVVARS "${CTKAPPLAUNCHER_ENVVARS}${envvar}\n")
  ENDFOREACH()
  
  # Let's dump settings specific to install config into a file.
  FILE(WRITE ${CMAKE_CURRENT_BINARY_DIR}/CTKAppLauncher-${CTKAPPLAUNCHER_TARGET_OUTPUT_NAME}-installtree-settings.cmake
"SET(CTKAPPLAUNCHER_APPLICATION_SUBDIR \"${CTKAPPLAUNCHER_APPLICATION_SUBDIR}\")
SET(CTKAPPLAUNCHER_SPLASH_IMAGE_SUBDIR \"${CTKAPPLAUNCHER_SPLASH_IMAGE_SUBDIR}\")
SET(CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH \"${CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH}\")
SET(CTKAPPLAUNCHER_LIBRARY_PATHS \"${CTKAPPLAUNCHER_LIBRARY_PATHS}\")
SET(CTKAPPLAUNCHER_PATHS \"${CTKAPPLAUNCHER_PATHS}\")
SET(CTKAPPLAUNCHER_ENVVARS \"${CTKAPPLAUNCHER_ENVVARS}\")
")
  
  # Generate informational message ... 
  SET(extra_message)
  IF(NOT ${CTKAPPLAUNCHER_SPLASH_IMAGE_NAME} STREQUAL "")
    SET(extra_message " [${CTKAPPLAUNCHER_SPLASH_IMAGE_NAME}]")
  ENDIF()
  SET(comment "Configuring application launcher: ${CTKAPPLAUNCHER_APPLICATION_NAME}${extra_message}")
  
  ADD_CUSTOM_COMMAND(
    DEPENDS
      ${CMAKE_CURRENT_LIST_FILE}
    OUTPUT
      ${CTKAPPLAUNCHER_DESTINATION_DIR}/${CTKAPPLAUNCHER_APPLICATION_NAME}LauncherSettings.ini
      ${CTKAPPLAUNCHER_DESTINATION_DIR}/${CTKAPPLAUNCHER_APPLICATION_NAME}LauncherSettingsToInstall.ini
    COMMAND ${CMAKE_COMMAND}
      -DTARGET_NAME:STRING=${CTKAPPLAUNCHER_TARGET_OUTPUT_NAME}
      -DTARGET_SUBDIR:STRING=${CMAKE_CFG_INTDIR}
      -DCMAKE_EXECUTABLE_SUFFIX:STRING=${CMAKE_EXECUTABLE_SUFFIX}
      -P ${CTKAPPLAUNCHER_DIR}/CMake/ctkAppLauncher-configure.cmake
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT ${comment}
    )
    
  ADD_CUSTOM_TARGET(${CTKAPPLAUNCHER_APPLICATION_NAME}ConfigureLauncher ALL
    DEPENDS
      ${CTKAPPLAUNCHER_DESTINATION_DIR}/${CTKAPPLAUNCHER_APPLICATION_NAME}LauncherSettings.ini
      ${CTKAPPLAUNCHER_DESTINATION_DIR}/${CTKAPPLAUNCHER_APPLICATION_NAME}LauncherSettingsToInstall.ini
    )
  ADD_DEPENDENCIES(${CTKAPPLAUNCHER_APPLICATION_NAME}ConfigureLauncher ${CTKAPPLAUNCHER_TARGET})
  
ENDMACRO()

#
# Testing - cmake -D<TESTNAME>:BOOL=ON -P ctkAppLauncher.cmake
#
IF(TEST_ctkAppLauncherListToQtSettingsArrayTest)
  FUNCTION(ctkAppLauncherListToQtSettingsArrayTest)
    SET(input "/path/to/app1" "/path/to/app2" "/path/to/app3")
    SET(itemname "path")
    SET(output)
    ctkAppLauncherListToQtSettingsArray("${input}" ${itemname} output)
    SET(expected_output "1\\\\path=/path/to/app1\n")
    SET(expected_output "${expected_output}2\\\\path=/path/to/app2\n")
    SET(expected_output "${expected_output}3\\\\path=/path/to/app3\n")
    SET(expected_output "${expected_output}size=3")
    IF(NOT "${output}" STREQUAL "${expected_output}")
      MESSAGE(FATAL_ERROR "Problem with ctkAppLauncherListToQtSettingsArray()\n"
                          "output:${output}\n"
                          "expected_output:${expected_output}")
    ENDIF()
    MESSAGE("SUCCESS")
  ENDFUNCTION()
  ctkAppLauncherListToQtSettingsArrayTest()
ENDIF()

IF(TEST_ctkAppLauncherAppendExtraAppToLaunchToListTest)
  FUNCTION(ctkAppLauncherAppendExtraAppToLaunchToListTest)
    SET(properties)
    ctkAppLauncherAppendExtraAppToLaunchToList(
      LONG_ARG helloworld
      HELP "Print hello world"
      PATH "/path/to/app"
      OUTPUTVAR properties
      )
    ctkAppLauncherAppendExtraAppToLaunchToList(
      LONG_ARG hellouniverse SHORT_ARG u
      HELP "Print hello universe"
      PATH "/path/to/app"
      ARGUMENTS "--universe"
      OUTPUTVAR properties
      )
    SET(expected_properties
      "helloworld^^^^Print hello world^^/path/to/app^^"
      "hellouniverse^^u^^Print hello universe^^/path/to/app^^--universe")
    IF(NOT "${properties}" STREQUAL "${expected_properties}")
      MESSAGE(FATAL_ERROR "Problem with ctkAppLauncherAppendExtraAppToLaunchToList()\n"
                          "properties:${properties}\n"
                          "expected_properties:${expected_properties}")
    ENDIF()
    MESSAGE("SUCCESS")
  ENDFUNCTION()
  ctkAppLauncherAppendExtraAppToLaunchToListTest()
ENDIF()
