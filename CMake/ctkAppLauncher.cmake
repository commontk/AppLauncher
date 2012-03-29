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
#    NOSPLASH_ARGS
#

# By requiring version 2.8, we also make sure CMP0007 is set to NEW
cmake_minimum_required(VERSION 2.8)

#
# Helper macro used internally - See http://www.cmake.org/Wiki/CMakeMacroParseArguments
#
macro(ctkAppLauncherMacroParseArguments prefix arg_names option_names)
  set(DEFAULT_ARGS)
  foreach(arg_name ${arg_names})
    set(${prefix}_${arg_name})
  endforeach(arg_name)
  foreach(option ${option_names})
    set(${prefix}_${option} FALSE)
  endforeach(option)

  set(current_arg_name DEFAULT_ARGS)
  set(current_arg_list)
  foreach(arg ${ARGN})
    set(larg_names ${arg_names})
    list(FIND larg_names "${arg}" is_arg_name)
    if(is_arg_name GREATER -1)
      set(${prefix}_${current_arg_name} ${current_arg_list})
      set(current_arg_name ${arg})
      set(current_arg_list)
    else(is_arg_name GREATER -1)
      set(loption_names ${option_names})
      list(FIND loption_names "${arg}" is_option)
      if(is_option GREATER -1)
        set(${prefix}_${arg} TRUE)
      else(is_option GREATER -1)
        set(current_arg_list ${current_arg_list} ${arg})
      endif(is_option GREATER -1)
    endif(is_arg_name GREATER -1)
  endforeach(arg)
  set(${prefix}_${current_arg_name} ${current_arg_list})
endmacro()

#
# ctkAppLauncherGenerateQtSettingsArray(ITEMS ITEMNAME OUTPUTVAR)
#
function(ctkAppLauncherListToQtSettingsArray ITEMS ITEMNAME OUTPUTVAR)
  set(idx 1)
  set(SETTINGS_ARRAY)
  list(LENGTH ITEMS item_count)
  foreach(item ${ITEMS})
    set(SETTINGS_ARRAY "${SETTINGS_ARRAY}${idx}\\\\${ITEMNAME}=${item}\n")
    math(EXPR idx "${idx} + 1")
  endforeach()
  set(SETTINGS_ARRAY "${SETTINGS_ARRAY}size=${item_count}")
  set(${OUTPUTVAR} ${SETTINGS_ARRAY} PARENT_SCOPE)
endfunction()

#
# ctkAppLauncherAppendExtraAppToLaunchTolist(
#      LONG_ARG longarg
#      [SHORT_ARG shortarg]
#      [HELP help]
#      PATH path
#      [ARGUMENTS arguments]
#      OUTPUTVAR)
#
function(ctkAppLauncherAppendExtraAppToLaunchToList)
  ctkAppLauncherMacroParseArguments(MY
    "LONG_ARG;SHORT_ARG;HELP;PATH;ARGUMENTS;OUTPUTVAR"
    ""
    ${ARGN}
    )
  # Sanity checks - Are mandatory variable defined
  foreach(varname LONG_ARG PATH OUTPUTVAR)
    if(NOT DEFINED MY_${varname})
      message(FATAL_ERROR "${varname} is mandatory")
    endif()
  endforeach()
  set(output "${MY_LONG_ARG}^^")
  set(output "${output}${MY_SHORT_ARG}^^")
  set(output "${output}${MY_HELP}^^")
  set(output "${output}${MY_PATH}^^")
  set(output "${output}${MY_ARGUMENTS}")
  set(output_list ${${MY_OUTPUTVAR}})
  list(APPEND output_list ${output})
  set(${MY_OUTPUTVAR} ${output_list} PARENT_SCOPE)
endfunction()

#
# ctkAppLauncherExtraAppToLaunchListToQtSettings()
#
function(ctkAppLauncherExtraAppToLaunchListToQtSettings)
  ctkAppLauncherMacroParseArguments(MY
    "LIST;OUTPUTVAR"
    ""
    ${ARGN}
    )
  # Sanity checks - Are mandatory variable defined
  foreach(varname LIST OUTPUTVAR)
    if(NOT DEFINED MY_${varname})
      message(FATAL_ERROR "${varname} is mandatory")
    endif()
  endforeach()
  set(settings)
  foreach(item ${MY_LIST})
    # Split by "^^"
    string(REPLACE "^^" "\\;" item ${item})
    set(item_list ${item})
    # Extract 'application to launch' properties
    list(GET item_list 0 longArgument)
    list(GET item_list 1 shortArgument)
    list(GET item_list 2 help)
    list(GET item_list 3 path)
    list(GET item_list 4 arguments)
    # Generate settings
    set(settings "${settings}\n")
    set(settings "${settings}${longArgument}/shortArgument=${shortArgument}\n")
    set(settings "${settings}${longArgument}/help=${help}\n")
    set(settings "${settings}${longArgument}/path=${path}\n")
    set(settings "${settings}${longArgument}/arguments=${arguments}\n")
    #message("longArgument:${longArgument}, shortArgument:${shortArgument}, help:${help}, path:${path}, arguments:${arguments}")
  endforeach()
  set(${MY_OUTPUTVAR} ${settings} PARENT_SCOPE)
endfunction()

#
# ctkAppLauncherConfigure
#
macro(ctkAppLauncherConfigure)
  ctkAppLauncherMacroParseArguments(CTKAPPLAUNCHER
    "EXECUTABLE;APPLICATION_NAME;TARGET;APPLICATION_INSTALL_SUBDIR;SETTINGS_TEMPLATE;DESTINATION_DIR;SPLASHSCREEN_HIDE_DELAY_MS;SPLASH_IMAGE_PATH;SPLASH_IMAGE_INSTALL_SUBDIR;DEFAULT_APPLICATION_ARGUMENT;EXTRA_APPLICATION_TO_LAUNCH_BUILD;EXTRA_APPLICATION_TO_LAUNCH_INSTALLED;LIBRARY_PATHS_BUILD;LIBRARY_PATHS_INSTALLED;PATHS_BUILD;PATHS_INSTALLED;ENVVARS_BUILD;ENVVARS_INSTALLED;HELP_SHORT_ARG;HELP_LONG_ARG;NOSPLASH_ARGS"
    "VERBOSE_CONFIG"
    ${ARGN}
    )

  # If CTKAPPLAUNCHER_DIR is set, try to autodiscover the location of launcher executable and settings template file
  if(EXISTS "${CTKAPPLAUNCHER_DIR}")
    unset(CTKAPPLAUNCHER_EXECUTABLE CACHE)
    find_program(CTKAPPLAUNCHER_EXECUTABLE CTKAppLauncher PATHS ${CTKAPPLAUNCHER_DIR}/bin NO_DEFAULT_PATH)
    unset(CTKAPPLAUNCHER_SETTINGS_TEMPLATE CACHE)
    find_file(CTKAPPLAUNCHER_SETTINGS_TEMPLATE CTKAppLauncherSettings.ini.in PATHS ${CTKAPPLAUNCHER_DIR}/bin NO_DEFAULT_PATH)
  endif()

  # Sanity checks - Are mandatory variable defined
  foreach(varname EXECUTABLE APPLICATION_NAME TARGET SETTINGS_TEMPLATE DESTINATION_DIR)
    if(NOT DEFINED CTKAPPLAUNCHER_${varname})
      message(FATAL_ERROR "${varname} is mandatory")
    endif()
  endforeach()

  # Sanity checks - Make sure TARGET is valid
  if(NOT TARGET ${CTKAPPLAUNCHER_TARGET})
    message(FATAL_ERROR "TARGET specified doesn't seem to be correct !")
  endif()

  # Sanity checks - Do files/directories exist ?
  foreach(varname EXECUTABLE SETTINGS_TEMPLATE DESTINATION_DIR)
    if(NOT EXISTS ${CTKAPPLAUNCHER_${varname}})
      message(FATAL_ERROR "${varname} [${CTKAPPLAUNCHER_${varname}}] doesn't seem to exist !")
    endif()
  endforeach()

  # Set splash image name
  set(CTKAPPLAUNCHER_SPLASH_IMAGE_NAME)
  if(DEFINED CTKAPPLAUNCHER_SPLASH_IMAGE_PATH)
    if(NOT EXISTS ${CTKAPPLAUNCHER_SPLASH_IMAGE_PATH})
      message(FATAL_ERROR "SPLASH_IMAGE_PATH [${CTKAPPLAUNCHER_SPLASH_IMAGE_PATH}] doesn't seem to exist !")
    endif()
    get_filename_component(CTKAPPLAUNCHER_SPLASH_IMAGE_NAME ${CTKAPPLAUNCHER_SPLASH_IMAGE_PATH} NAME)
    get_filename_component(CTKAPPLAUNCHER_SPLASH_IMAGE_PATH ${CTKAPPLAUNCHER_SPLASH_IMAGE_PATH} PATH)
  endif()

  # Set splashscreen hide delay in ms
  if(DEFINED CTKAPPLAUNCHER_SPLASHSCREEN_HIDE_DELAY_MS)
    if(CTKAPPLAUNCHER_SPLASHSCREEN_HIDE_DELAY_MS LESS 0)
      message(FATAL_ERROR "SPLASHSCREEN_HIDE_DELAY_MS [${CTKAPPLAUNCHER_SPLASHSCREEN_HIDE_DELAY_MS}] should be >= 0 !")
    endif()
  else()
    set(SPLASHSCREEN_HIDE_DELAY_MS 0)
  endif()

  #-----------------------------------------------------------------------------
  # Settings shared between the build tree and install tree.

  set(COMMON_SETTING_VARS
    CTKAPPLAUNCHER_EXECUTABLE
    CTKAPPLAUNCHER_SETTINGS_TEMPLATE
    CTKAPPLAUNCHER_APPLICATION_NAME
    CTKAPPLAUNCHER_DESTINATION_DIR
    CTKAPPLAUNCHER_SPLASHSCREEN_HIDE_DELAY_MS
    CTKAPPLAUNCHER_HELP_SHORT_ARG
    CTKAPPLAUNCHER_HELP_LONG_ARG
    CTKAPPLAUNCHER_NOSPLASH_ARGS
    CTKAPPLAUNCHER_APPLICATION_DEFAULT_ARGUMENTS
    CTKAPPLAUNCHER_SPLASH_IMAGE_NAME
    )
  set(COMMON_SETTINGS)
  foreach(v ${COMMON_SETTING_VARS})
    set(COMMON_SETTINGS "${COMMON_SETTINGS}
set(${v} \"${${v}}\")")
  endforeach()

  # Retrieve the output name of the target application
  get_target_property(CTKAPPLAUNCHER_TARGET_OUTPUT_NAME
    ${CTKAPPLAUNCHER_TARGET} OUTPUT_NAME)

  # Default to target name if OUTPUT_NAME is not set
  if(NOT CTKAPPLAUNCHER_TARGET_OUTPUT_NAME)
    set(CTKAPPLAUNCHER_TARGET_OUTPUT_NAME ${CTKAPPLAUNCHER_TARGET})
  endif()

  # Let's dump settings common to build and install config into a file.
  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/CTKAppLauncher-${CTKAPPLAUNCHER_TARGET_OUTPUT_NAME}-common-settings.cmake
"${COMMON_SETTINGS}")

  #-----------------------------------------------------------------------------
  # Settings specific to the build tree.

  set(CTKAPPLAUNCHER_SPLASH_IMAGE_SUBDIR)
  if(DEFINED CTKAPPLAUNCHER_SPLASH_IMAGE_PATH AND NOT ${CTKAPPLAUNCHER_SPLASH_IMAGE_PATH} STREQUAL "")
    set(CTKAPPLAUNCHER_SPLASH_IMAGE_SUBDIR "${CTKAPPLAUNCHER_SPLASH_IMAGE_PATH}/")
  endif()

  # Retrieve location of the target application
  get_target_property(CTKAPPLAUNCHER_TARGET_DIR
    ${CTKAPPLAUNCHER_TARGET} RUNTIME_OUTPUT_DIRECTORY)

  file(RELATIVE_PATH CTKAPPLAUNCHER_APPLICATION_RELPATH ${CTKAPPLAUNCHER_DESTINATION_DIR} ${CTKAPPLAUNCHER_TARGET_DIR})
  set(CTKAPPLAUNCHER_APPLICATION_SUBDIR)
  if(NOT "${CTKAPPLAUNCHER_APPLICATION_RELPATH}" STREQUAL "")
    set(CTKAPPLAUNCHER_APPLICATION_SUBDIR "${CTKAPPLAUNCHER_APPLICATION_RELPATH}/")
  endif()
  set(CTKAPPLAUNCHER_APPLICATION_SUBDIR "<APPLAUNCHER_DIR>/${CTKAPPLAUNCHER_APPLICATION_SUBDIR}")

  if(APPLE)
    # Is the target an app bundle?
    get_target_property(CTK_APPLAUNCHER_TARGET_BUNDLE ${CTKAPPLAUNCHER_TARGET} MACOSX_BUNDLE)

    if(CTK_APPLAUNCHER_TARGET_BUNDLE)
      set(CTKAPPLAUNCHER_APPLICATION_SUBDIR "${CTKAPPLAUNCHER_APPLICATION_SUBDIR}${CTKAPPLAUNCHER_APPLICATION_NAME}.app/Contents/MacOS/")
    endif()
  endif()

  set(CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH)
  if(DEFINED CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH_BUILD)
    ctkAppLauncherExtraAppToLaunchListToQtSettings(
      LIST ${CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH_BUILD}
      OUTPUTVAR CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH)
  endif()

  set(CTKAPPLAUNCHER_LIBRARY_PATHS)
  ctkAppLauncherListToQtSettingsArray("${CTKAPPLAUNCHER_LIBRARY_PATHS_BUILD}" "path" CTKAPPLAUNCHER_LIBRARY_PATHS)

  set(CTKAPPLAUNCHER_PATHS)
  ctkAppLauncherListToQtSettingsArray("${CTKAPPLAUNCHER_PATHS_BUILD}" "path" CTKAPPLAUNCHER_PATHS)

  set(CTKAPPLAUNCHER_ENVVARS)
  foreach(envvar ${CTKAPPLAUNCHER_ENVVARS_BUILD})
    set(CTKAPPLAUNCHER_ENVVARS "${CTKAPPLAUNCHER_ENVVARS}${envvar}\n")
  endforeach()

  # Let's dump settings specific to build config into a file.
  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/CTKAppLauncher-${CTKAPPLAUNCHER_TARGET_OUTPUT_NAME}-buildtree-settings.cmake
"set(CTKAPPLAUNCHER_APPLICATION_SUBDIR \"${CTKAPPLAUNCHER_APPLICATION_SUBDIR}\")
set(CTKAPPLAUNCHER_SPLASH_IMAGE_SUBDIR \"${CTKAPPLAUNCHER_SPLASH_IMAGE_SUBDIR}\")
set(CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH \"${CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH}\")
set(CTKAPPLAUNCHER_LIBRARY_PATHS \"${CTKAPPLAUNCHER_LIBRARY_PATHS}\")
set(CTKAPPLAUNCHER_PATHS \"${CTKAPPLAUNCHER_PATHS}\")
set(CTKAPPLAUNCHER_ENVVARS \"${CTKAPPLAUNCHER_ENVVARS}\")
")

  #-----------------------------------------------------------------------------
  # Settings specific to the install tree.

  set(CTKAPPLAUNCHER_SPLASH_IMAGE_SUBDIR)
  if(DEFINED CTKAPPLAUNCHER_SPLASH_IMAGE_INSTALL_SUBDIR AND NOT ${CTKAPPLAUNCHER_SPLASH_IMAGE_INSTALL_SUBDIR} STREQUAL "")
    set(CTKAPPLAUNCHER_SPLASH_IMAGE_SUBDIR "<APPLAUNCHER_DIR>/${CTKAPPLAUNCHER_SPLASH_IMAGE_INSTALL_SUBDIR}/")
  endif()

  set(CTKAPPLAUNCHER_APPLICATION_SUBDIR)
  if(NOT "${CTKAPPLAUNCHER_APPLICATION_INSTALL_SUBDIR}" STREQUAL "")
    set(CTKAPPLAUNCHER_APPLICATION_SUBDIR "${CTKAPPLAUNCHER_APPLICATION_INSTALL_SUBDIR}/")
  endif()
  set(CTKAPPLAUNCHER_APPLICATION_SUBDIR "<APPLAUNCHER_DIR>/${CTKAPPLAUNCHER_APPLICATION_SUBDIR}")

  set(CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH)
  if(DEFINED CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH_INSTALLED)
    ctkAppLauncherExtraAppToLaunchListToQtSettings(
      LIST ${CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH_INSTALLED}
      OUTPUTVAR CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH)
  endif()

  set(CTKAPPLAUNCHER_LIBRARY_PATHS)
  ctkAppLauncherListToQtSettingsArray("${CTKAPPLAUNCHER_LIBRARY_PATHS_INSTALLED}" "path" CTKAPPLAUNCHER_LIBRARY_PATHS)

  set(CTKAPPLAUNCHER_PATHS)
  ctkAppLauncherListToQtSettingsArray("${CTKAPPLAUNCHER_PATHS_INSTALLED}" "path" CTKAPPLAUNCHER_PATHS)

  set(CTKAPPLAUNCHER_ENVVARS)
  foreach(envvar ${CTKAPPLAUNCHER_ENVVARS_INSTALLED})
    set(CTKAPPLAUNCHER_ENVVARS "${CTKAPPLAUNCHER_ENVVARS}${envvar}\n")
  endforeach()

  # Let's dump settings specific to install config into a file.
  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/CTKAppLauncher-${CTKAPPLAUNCHER_TARGET_OUTPUT_NAME}-installtree-settings.cmake
"set(CTKAPPLAUNCHER_APPLICATION_SUBDIR \"${CTKAPPLAUNCHER_APPLICATION_SUBDIR}\")
set(CTKAPPLAUNCHER_SPLASH_IMAGE_SUBDIR \"${CTKAPPLAUNCHER_SPLASH_IMAGE_SUBDIR}\")
set(CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH \"${CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH}\")
set(CTKAPPLAUNCHER_LIBRARY_PATHS \"${CTKAPPLAUNCHER_LIBRARY_PATHS}\")
set(CTKAPPLAUNCHER_PATHS \"${CTKAPPLAUNCHER_PATHS}\")
set(CTKAPPLAUNCHER_ENVVARS \"${CTKAPPLAUNCHER_ENVVARS}\")
")

  # Generate informational message ...
  set(extra_message)
  if(NOT ${CTKAPPLAUNCHER_SPLASH_IMAGE_NAME} STREQUAL "")
    set(extra_message " [${CTKAPPLAUNCHER_SPLASH_IMAGE_NAME}]")
  endif()
  set(comment "Configuring application launcher: ${CTKAPPLAUNCHER_APPLICATION_NAME}${extra_message}")

  add_custom_command(
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

  add_custom_target(${CTKAPPLAUNCHER_APPLICATION_NAME}ConfigureLauncher ALL
    DEPENDS
      ${CTKAPPLAUNCHER_DESTINATION_DIR}/${CTKAPPLAUNCHER_APPLICATION_NAME}LauncherSettings.ini
      ${CTKAPPLAUNCHER_DESTINATION_DIR}/${CTKAPPLAUNCHER_APPLICATION_NAME}LauncherSettingsToInstall.ini
    )
  add_dependencies(${CTKAPPLAUNCHER_APPLICATION_NAME}ConfigureLauncher ${CTKAPPLAUNCHER_TARGET})

endmacro()

#
# Testing - cmake -D<TESTNAME>:BOOL=ON -P ctkAppLauncher.cmake
#
if(TEST_ctkAppLauncherListToQtSettingsArrayTest)
  function(ctkAppLauncherListToQtSettingsArrayTest)
    set(input "/path/to/app1" "/path/to/app2" "/path/to/app3")
    set(itemname "path")
    set(output)
    ctkAppLauncherListToQtSettingsArray("${input}" ${itemname} output)
    set(expected_output "1\\\\path=/path/to/app1\n")
    set(expected_output "${expected_output}2\\\\path=/path/to/app2\n")
    set(expected_output "${expected_output}3\\\\path=/path/to/app3\n")
    set(expected_output "${expected_output}size=3")
    if(NOT "${output}" STREQUAL "${expected_output}")
      message(FATAL_ERROR "Problem with ctkAppLauncherListToQtSettingsArray()\n"
                          "output:${output}\n"
                          "expected_output:${expected_output}")
    endif()
    message("SUCCESS")
  endfunction()
  ctkAppLauncherListToQtSettingsArrayTest()
endif()

if(TEST_ctkAppLauncherAppendExtraAppToLaunchToListTest)
  function(ctkAppLauncherAppendExtraAppToLaunchToListTest)
    set(properties)
    ctkAppLauncherAppendExtraAppToLaunchTolist(
      LONG_ARG helloworld
      HELP "Print hello world"
      PATH "/path/to/app"
      OUTPUTVAR properties
      )
    ctkAppLauncherAppendExtraAppToLaunchTolist(
      LONG_ARG hellouniverse SHORT_ARG u
      HELP "Print hello universe"
      PATH "/path/to/app"
      ARGUMENTS "--universe"
      OUTPUTVAR properties
      )
    set(expected_properties
      "helloworld^^^^Print hello world^^/path/to/app^^"
      "hellouniverse^^u^^Print hello universe^^/path/to/app^^--universe")
    if(NOT "${properties}" STREQUAL "${expected_properties}")
      message(FATAL_ERROR "Problem with ctkAppLauncherAppendExtraAppToLaunchTolist()\n"
                          "properties:${properties}\n"
                          "expected_properties:${expected_properties}")
    endif()
    message("SUCCESS")
  endfunction()
  ctkAppLauncherAppendExtraAppToLaunchToListTest()
endif()

if(TEST_ctkAppLauncherExtraAppToLaunchListToQtSettingsTest)
  function(ctkAppLauncherExtraAppToLaunchListToQtSettingsTest)
    set(properties)
    ctkAppLauncherAppendExtraAppToLaunchTolist(
      LONG_ARG helloworld
      HELP "Print hello world"
      PATH "/path/to/app"
      OUTPUTVAR properties
      )
    ctkAppLauncherAppendExtraAppToLaunchTolist(
      LONG_ARG hellouniverse SHORT_ARG u
      HELP "Print hello universe"
      PATH "/path/to/app"
      ARGUMENTS "--universe"
      OUTPUTVAR properties
      )
    set(output)
    ctkAppLauncherExtraAppToLaunchListToQtSettings(LIST ${properties} OUTPUTVAR output)
    set(expected_output "${expected_output}\n")
    set(expected_output "${expected_output}helloworld/shortArgument=\n")
    set(expected_output "${expected_output}helloworld/help=Print hello world\n")
    set(expected_output "${expected_output}helloworld/path=/path/to/app\n")
    set(expected_output "${expected_output}helloworld/arguments=\n")
    set(expected_output "${expected_output}\n")
    set(expected_output "${expected_output}hellouniverse/shortArgument=u\n")
    set(expected_output "${expected_output}hellouniverse/help=Print hello universe\n")
    set(expected_output "${expected_output}hellouniverse/path=/path/to/app\n")
    set(expected_output "${expected_output}hellouniverse/arguments=--universe\n")
    if(NOT "${output}" STREQUAL "${expected_output}")
      message(FATAL_ERROR "Problem with ctkAppLauncherExtraAppToLaunchListToQtSettings()\n"
                          "output:${output}\n"
                          "expected_output:${expected_output}")
    endif()
    message("SUCCESS")
  endfunction()
  ctkAppLauncherExtraAppToLaunchListToQtSettingsTest()
endif()
