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

cmake_minimum_required(VERSION 3.0)
include(CMakeParseArguments)

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
  set(options
    )
  set(oneValueArgs
    LONG_ARG
    SHORT_ARG
    HELP
    PATH
    OUTPUTVAR
    )
  set(multiValueArgs
    ARGUMENTS
    )
  cmake_parse_arguments(MY
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
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
  set(options)
  set(oneValueArgs
    OUTPUTVAR
    )
  set(multiValueArgs
    LIST
    )
  cmake_parse_arguments(MY
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
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
# Generate CMake file containing all variable required to configure a launcher settings file
#
#   VARIABLE_SUFFIX .....: BUILD or INSTALLED
#
#   SETTINGS_TYPE .......: build or install
#
#   SETTING_FILEPATH_VAR .: Variable set to the name of the generate file
#
function(_generate_settings_configuration VARIABLE_SUFFIX SETTINGS_TYPE SETTING_FILEPATH_VAR)

  # Common settings
  set(COMMON_SETTING_VARS
    CTKAPPLAUNCHER_SETTINGS_TEMPLATE
    CTKAPPLAUNCHER_APPLICATION_EXECUTABLE_NAME
    CTKAPPLAUNCHER_APPLICATION_NAME
    CTKAPPLAUNCHER_APPLICATION_REVISION
    CTKAPPLAUNCHER_ORGANIZATION_DOMAIN
    CTKAPPLAUNCHER_ORGANIZATION_NAME
    CTKAPPLAUNCHER_DESTINATION_DIR
    CTKAPPLAUNCHER_SPLASHSCREEN_DISABLED
    CTKAPPLAUNCHER_SPLASHSCREEN_HIDE_DELAY_MS
    CTKAPPLAUNCHER_HELP_SHORT_ARG
    CTKAPPLAUNCHER_HELP_LONG_ARG
    CTKAPPLAUNCHER_NOSPLASH_ARGS
    CTKAPPLAUNCHER_APPLICATION_DEFAULT_ARGUMENTS
    CTKAPPLAUNCHER_SPLASH_IMAGE_NAME
    CTKAPPLAUNCHER_USER_ADDITIONAL_SETTINGS_FILEBASENAME_SET
    )
  set(CMAKE_CONFIGURABLE_FILE_CONTENT "# Common settings")
  foreach(v ${COMMON_SETTING_VARS})
    set(CMAKE_CONFIGURABLE_FILE_CONTENT "${CMAKE_CONFIGURABLE_FILE_CONTENT}
set(${v} \"${${v}}\")")
  endforeach()

  # Tree specific settings
  set(CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH)
  if(DEFINED CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH_${VARIABLE_SUFFIX})
    ctkAppLauncherExtraAppToLaunchListToQtSettings(
      LIST ${CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH_${VARIABLE_SUFFIX}}
      OUTPUTVAR CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH)
  endif()

  set(CTKAPPLAUNCHER_LIBRARY_PATHS)
  ctkAppLauncherListToQtSettingsArray("${CTKAPPLAUNCHER_LIBRARY_PATHS_${VARIABLE_SUFFIX}}" "path" CTKAPPLAUNCHER_LIBRARY_PATHS)

  set(CTKAPPLAUNCHER_PATHS)
  ctkAppLauncherListToQtSettingsArray("${CTKAPPLAUNCHER_PATHS_${VARIABLE_SUFFIX}}" "path" CTKAPPLAUNCHER_PATHS)

  set(CTKAPPLAUNCHER_ENVVARS)
  foreach(envvar ${CTKAPPLAUNCHER_ENVVARS_${VARIABLE_SUFFIX}})
    set(CTKAPPLAUNCHER_ENVVARS "${CTKAPPLAUNCHER_ENVVARS}${envvar}\n")
  endforeach()

  string(REPLACE ";" "," CTKAPPLAUNCHER_ADDITIONAL_PATH_ENVVARS
    "${CTKAPPLAUNCHER_ADDITIONAL_PATH_ENVVARS_${VARIABLE_SUFFIX}}")
  set(CMAKE_CONFIGURABLE_FILE_CONTENT
"${CMAKE_CONFIGURABLE_FILE_CONTENT}
# Specific settings
set(CTKAPPLAUNCHER_APPLICATION_SUBDIR \"${CTKAPPLAUNCHER_APPLICATION_SUBDIR}\")
set(CTKAPPLAUNCHER_SPLASH_IMAGE_SUBDIR \"${CTKAPPLAUNCHER_SPLASH_IMAGE_SUBDIR}\")
set(CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH \"${CTKAPPLAUNCHER_EXTRA_APPLICATION_TO_LAUNCH}\")
set(CTKAPPLAUNCHER_LIBRARY_PATHS \"${CTKAPPLAUNCHER_LIBRARY_PATHS}\")
set(CTKAPPLAUNCHER_PATHS \"${CTKAPPLAUNCHER_PATHS}\")
set(CTKAPPLAUNCHER_ENVVARS \"${CTKAPPLAUNCHER_ENVVARS}\")
set(CTKAPPLAUNCHER_ADDITIONAL_PATH_ENVVARS \"${CTKAPPLAUNCHER_ADDITIONAL_PATH_ENVVARS}\")")

  set(CTKAPPLAUNCHER_ADDITIONAL_PATHS)
  foreach(envvar ${CTKAPPLAUNCHER_ADDITIONAL_PATH_ENVVARS_${VARIABLE_SUFFIX}})
    set(cmake_varname ${CTKAPPLAUNCHER_ADDITIONAL_PATH_ENVVARS_PREFIX}${envvar}_${VARIABLE_SUFFIX})
    ctkAppLauncherListToQtSettingsArray("${${cmake_varname}}" "path" CTKAPPLAUNCHER_ADDITIONAL_PATHS_${envvar})
    set(CTKAPPLAUNCHER_ADDITIONAL_PATHS "${CTKAPPLAUNCHER_ADDITIONAL_PATHS}

[${envvar}]
${CTKAPPLAUNCHER_ADDITIONAL_PATHS_${envvar}}")
  endforeach()

    set(CMAKE_CONFIGURABLE_FILE_CONTENT "${CMAKE_CONFIGURABLE_FILE_CONTENT}
set(CTKAPPLAUNCHER_ADDITIONAL_PATHS \"${CTKAPPLAUNCHER_ADDITIONAL_PATHS}\")")

  set(setting_file "${CMAKE_CURRENT_BINARY_DIR}/CTKAppLauncher-${CTKAPPLAUNCHER_TARGET_OUTPUT_NAME}-${SETTINGS_TYPE}-settings.cmake")

  # Let's dump settings specific to this config into a file.
  configure_file(
    "${CMAKE_ROOT}/Modules/CMakeConfigurableFile.in"
    "${setting_file}"
    )

  set(${SETTING_FILEPATH_VAR} ${setting_file} PARENT_SCOPE)
endfunction()

function(ctkAppLauncherConfigure)

  # Set default values for backward compatibility
  if(NOT CTKAppLauncher_FOUND)
    set(CTK_INSTALL_BIN_DIR "bin")
    set(CTK_INSTALL_CMAKE_DIR "CMake")
    if(NOT DEFINED CTKAppLauncher_DIR AND DEFINED CTKAPPLAUNCHER_DIR)
      set(CTKAppLauncher_DIR ${CTKAPPLAUNCHER_DIR})
    endif()

    # If CTKAppLauncher_DIR is set, try to autodiscover the location of launcher executable and settings template file
    if(EXISTS "${CTKAppLauncher_DIR}")
      set(CTKAPPLAUNCHER_SEARCH_PATHS ${CTKAppLauncher_DIR}/${CTK_INSTALL_BIN_DIR})
      foreach(type ${CTKAPPLAUNCHER_BUILD_CONFIGURATIONS})
        list(APPEND CTKAPPLAUNCHER_SEARCH_PATHS ${CTKAppLauncher_DIR}/${CTK_INSTALL_BIN_DIR}/${type})
      endforeach()
      unset(CTKAppLauncher_EXECUTABLE CACHE)
      find_program(CTKAppLauncher_EXECUTABLE CTKAppLauncher PATHS ${CTKAPPLAUNCHER_SEARCH_PATHS} NO_DEFAULT_PATH)
      unset(CTKAppLauncher_SETTINGS_TEMPLATE CACHE)
      find_file(CTKAppLauncher_SETTINGS_TEMPLATE CTKAppLauncherSettings.ini.in PATHS ${CTKAppLauncher_DIR}/${CTK_INSTALL_BIN_DIR} NO_DEFAULT_PATH)
    endif()
  endif()

  ctkAppLauncherConfigureForTarget(${ARGN})
endfunction()

function(_check_variables_defined)
  foreach(varname IN LISTS ARGN)
    if(NOT DEFINED CTKAPPLAUNCHER_${varname})
      message(FATAL_ERROR "${varname} is mandatory")
    endif()
  endforeach()
endfunction()

function(_check_variables_exists)
  foreach(varname IN LISTS ARGN)
    if(NOT EXISTS ${CTKAPPLAUNCHER_${varname}})
      message(FATAL_ERROR "${varname} [${CTKAPPLAUNCHER_${varname}}] doesn't seem to exist !")
    endif()
  endforeach()
endfunction()

function(ctkAppLauncherConfigureForTarget)
  set(options)
  set(oneValueArgs
    APPLICATION_NAME
    # Executable target associated with the launcher
    TARGET
    # Location of the launcher settings in the build tree
    DESTINATION_DIR
    )
  set(multiValueArgs)
  cmake_parse_arguments(CTKAPPLAUNCHER
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
    )

  _check_variables_defined(APPLICATION_NAME DESTINATION_DIR TARGET)
  _check_variables_exists(DESTINATION_DIR)

  # Sanity checks - Make sure TARGET is valid
  if(NOT TARGET ${CTKAPPLAUNCHER_TARGET})
    message(FATAL_ERROR "TARGET specified doesn't seem to be correct !")
  endif()

  # Retrieve the output name of the target application
  get_target_property(CTKAPPLAUNCHER_TARGET_OUTPUT_NAME
    ${CTKAPPLAUNCHER_TARGET} OUTPUT_NAME)

  # Default to target name if OUTPUT_NAME is not set
  if(NOT CTKAPPLAUNCHER_TARGET_OUTPUT_NAME)
    set(CTKAPPLAUNCHER_TARGET_OUTPUT_NAME ${CTKAPPLAUNCHER_TARGET})
  endif()

  set(CTKAPPLAUNCHER_APPLICATION_EXECUTABLE_NAME ${CTKAPPLAUNCHER_TARGET_OUTPUT_NAME}${CMAKE_EXECUTABLE_SUFFIX})

  # Settings specific to the build tree.

  # Retrieve location of the target application
  get_target_property(CTKAPPLAUNCHER_TARGET_DIR
    ${CTKAPPLAUNCHER_TARGET} RUNTIME_OUTPUT_DIRECTORY)

  file(RELATIVE_PATH CTKAPPLAUNCHER_APPLICATION_BUILD_SUBDIR ${CTKAPPLAUNCHER_DESTINATION_DIR} ${CTKAPPLAUNCHER_TARGET_DIR})

  if(APPLE)
    # Is the target an app bundle?
    get_target_property(CTK_APPLAUNCHER_TARGET_BUNDLE ${CTKAPPLAUNCHER_TARGET} MACOSX_BUNDLE)

    if(CTK_APPLAUNCHER_TARGET_BUNDLE)
      if(NOT "${CTKAPPLAUNCHER_APPLICATION_BUILD_SUBDIR}" STREQUAL "")
        set(CTKAPPLAUNCHER_APPLICATION_BUILD_SUBDIR "${CTKAPPLAUNCHER_APPLICATION_BUILD_SUBDIR}/")
      endif()
      set(CTKAPPLAUNCHER_APPLICATION_BUILD_SUBDIR "${CTKAPPLAUNCHER_APPLICATION_BUILD_SUBDIR}${CTKAPPLAUNCHER_APPLICATION_NAME}.app/Contents/MacOS")
    endif()
  endif()

  ctk_applauncher_configure(
    APPLICATION_NAME ${CTKAPPLAUNCHER_APPLICATION_NAME}
    APPLICATION_EXECUTABLE_NAME ${CTKAPPLAUNCHER_APPLICATION_EXECUTABLE_NAME}
    APPLICATION_BUILD_SUBDIR ${CTKAPPLAUNCHER_APPLICATION_BUILD_SUBDIR}
    DESTINATION_DIR ${CTKAPPLAUNCHER_DESTINATION_DIR}
    ${CTKAPPLAUNCHER_UNPARSED_ARGUMENTS}
    )

  add_dependencies(${CTKAPPLAUNCHER_APPLICATION_NAME}ConfigureLauncher ${CTKAPPLAUNCHER_TARGET})

endfunction()

function(ctkAppLauncherConfigureForExecutable)
  set(options)
  set(oneValueArgs
    APPLICATION_EXECUTABLE
    APPLICATION_NAME
    APPLICATION_INSTALL_EXECUTABLE_NAME
    DESTINATION_DIR
    )
  set(multiValueArgs)
  cmake_parse_arguments(CTKAPPLAUNCHER
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
    )

  _check_variables_defined(APPLICATION_EXECUTABLE APPLICATION_NAME)

  get_filename_component(
    CTKAPPLAUNCHER_APPLICATION_EXECUTABLE_NAME
    ${CTKAPPLAUNCHER_APPLICATION_EXECUTABLE}
    NAME_WE
    )

  if(NOT DEFINED CTKAPPLAUNCHER_APPLICATION_INSTALL_EXECUTABLE_NAME)
    set(CTKAPPLAUNCHER_APPLICATION_INSTALL_EXECUTABLE_NAME ${CTKAPPLAUNCHER_APPLICATION_EXECUTABLE_NAME})
  endif()

  get_filename_component(
    CTKAPPLAUNCHER_APPLICATION_EXECUTABLE_DIRECTORY
    ${CTKAPPLAUNCHER_APPLICATION_EXECUTABLE}
    DIRECTORY
    )

  file(RELATIVE_PATH CTKAPPLAUNCHER_APPLICATION_BUILD_SUBDIR
    ${CTKAPPLAUNCHER_DESTINATION_DIR}
    ${CTKAPPLAUNCHER_APPLICATION_EXECUTABLE_DIRECTORY}
    )

  ctk_applauncher_configure(
    APPLICATION_NAME ${CTKAPPLAUNCHER_APPLICATION_NAME}
    APPLICATION_EXECUTABLE_NAME ${CTKAPPLAUNCHER_APPLICATION_EXECUTABLE_NAME}
    APPLICATION_INSTALL_EXECUTABLE_NAME ${CTKAPPLAUNCHER_APPLICATION_INSTALL_EXECUTABLE_NAME}
    APPLICATION_BUILD_SUBDIR ${CTKAPPLAUNCHER_APPLICATION_BUILD_SUBDIR}
    DESTINATION_DIR ${CTKAPPLAUNCHER_DESTINATION_DIR}
    ${CTKAPPLAUNCHER_UNPARSED_ARGUMENTS}
    )
endfunction()

function(ctk_applauncher_configure)
  set(options
    VERBOSE_CONFIG
    SPLASHSCREEN_DISABLED
    )
  set(oneValueArgs
    APPLICATION_EXECUTABLE_NAME
    APPLICATION_INSTALL_EXECUTABLE_NAME

    # Location of the launcher settings in the build tree
    DESTINATION_DIR
    APPLICATION_BUILD_SUBDIR

    # Location of the launcher settings in the install tree
    APPLICATION_INSTALL_SUBDIR

    # Info allowing to retrieve the revision specific settings
    APPLICATION_NAME
    APPLICATION_REVISION
    ORGANIZATION_DOMAIN
    ORGANIZATION_NAME
    USER_ADDITIONAL_SETTINGS_FILEBASENAME

    SETTINGS_TEMPLATE

    # Splash screen
    SPLASHSCREEN_HIDE_DELAY_MS
    SPLASH_IMAGE_PATH
    SPLASH_IMAGE_INSTALL_SUBDIR

    # Comma seperated list of arguments that should NOT be associated with the spash screen
    NOSPLASH_ARGS

    DEFAULT_APPLICATION_ARGUMENT
    ADDITIONAL_PATH_ENVVARS_PREFIX

    # Arguments triggering display of launcher help
    HELP_SHORT_ARG
    HELP_LONG_ARG
    )
  set(multiValueArgs
    # Extra application associated with the launcher
    EXTRA_APPLICATION_TO_LAUNCH_BUILD
    EXTRA_APPLICATION_TO_LAUNCH_INSTALLED

    # Launcher settings specific to build tree
    LIBRARY_PATHS_BUILD
    PATHS_BUILD
    ENVVARS_BUILD

    # Launcher settings specific to install tree
    LIBRARY_PATHS_INSTALLED
    PATHS_INSTALLED
    ENVVARS_INSTALLED

    # The ADDITIONAL_PATH_ENVVARS_(BUILD_INSTALLED) variables contains names of
    # environment variables expected to be associated with a list of paths.
    # Examples of such variables are PYTHONPATH, QT_PLUGIN_PATH, ...
    # For each "ADDITIONAL_PATH_ENVVARS", the "ctkAppLauncherConfigure" macro
    # will look for variables named <ADDITIONAL_PATH_ENVVARS_PREFIX>_<ADDITIONAL_PATH_ENVVAR>_(BUILD|INSTALLED)
    # listing paths.
    # For example: SLICER_PYTHONPATH_BUILD, SLICER_PYTHONPATH_INSTALLED
    ADDITIONAL_PATH_ENVVARS_BUILD
    ADDITIONAL_PATH_ENVVARS_INSTALLED
    )
  cmake_parse_arguments(CTKAPPLAUNCHER
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
    )

  set(CTKAPPLAUNCHER_SETTINGS_TEMPLATE ${CTKAppLauncher_SETTINGS_TEMPLATE})

  _check_variables_defined(APPLICATION_EXECUTABLE_NAME APPLICATION_NAME SETTINGS_TEMPLATE DESTINATION_DIR)
  _check_variables_exists(SETTINGS_TEMPLATE DESTINATION_DIR)

  if(NOT DEFINED CTKAPPLAUNCHER_APPLICATION_INSTALL_EXECUTABLE_NAME)
    set(CTKAPPLAUNCHER_APPLICATION_INSTALL_EXECUTABLE_NAME ${CTKAPPLAUNCHER_APPLICATION_EXECUTABLE_NAME})
  endif()

  # Set splash image name
  set(CTKAPPLAUNCHER_SPLASH_IMAGE_NAME)
  if(DEFINED CTKAPPLAUNCHER_SPLASH_IMAGE_PATH)
    if(NOT EXISTS ${CTKAPPLAUNCHER_SPLASH_IMAGE_PATH})
      message(FATAL_ERROR "SPLASH_IMAGE_PATH [${CTKAPPLAUNCHER_SPLASH_IMAGE_PATH}] doesn't seem to exist !")
    endif()
    get_filename_component(CTKAPPLAUNCHER_SPLASH_IMAGE_NAME ${CTKAPPLAUNCHER_SPLASH_IMAGE_PATH} NAME)
    get_filename_component(CTKAPPLAUNCHER_SPLASH_IMAGE_PATH ${CTKAPPLAUNCHER_SPLASH_IMAGE_PATH} PATH)
  endif()

  # Set spashscreen disabled option
  if(CTKAPPLAUNCHER_SPLASHSCREEN_DISABLED)
    set(CTKAPPLAUNCHER_SPLASHSCREEN_DISABLED "true")
  else()
    set(CTKAPPLAUNCHER_SPLASHSCREEN_DISABLED "false")
  endif()

  # Set splashscreen hide delay in ms
  if(DEFINED CTKAPPLAUNCHER_SPLASHSCREEN_HIDE_DELAY_MS)
    if(CTKAPPLAUNCHER_SPLASHSCREEN_HIDE_DELAY_MS LESS 0)
      message(FATAL_ERROR "SPLASHSCREEN_HIDE_DELAY_MS [${CTKAPPLAUNCHER_SPLASHSCREEN_HIDE_DELAY_MS}] should be >= 0 !")
    endif()
  else()
    set(SPLASHSCREEN_HIDE_DELAY_MS 0)
  endif()

  if(NOT "${CTKAPPLAUNCHER_USER_ADDITIONAL_SETTINGS_FILEBASENAME}" STREQUAL "")
    set(CTKAPPLAUNCHER_USER_ADDITIONAL_SETTINGS_FILEBASENAME_SET
      "userAdditionalSettingsFileBaseName=${CTKAPPLAUNCHER_USER_ADDITIONAL_SETTINGS_FILEBASENAME}")
  endif()

  # Settings specific to the build tree.
  set(CTKAPPLAUNCHER_SPLASH_IMAGE_SUBDIR)
  if(DEFINED CTKAPPLAUNCHER_SPLASH_IMAGE_PATH AND NOT ${CTKAPPLAUNCHER_SPLASH_IMAGE_PATH} STREQUAL "")
    set(CTKAPPLAUNCHER_SPLASH_IMAGE_SUBDIR "${CTKAPPLAUNCHER_SPLASH_IMAGE_PATH}/")
  endif()

  set(CTKAPPLAUNCHER_APPLICATION_SUBDIR)
  if(NOT "${CTKAPPLAUNCHER_APPLICATION_BUILD_SUBDIR}" STREQUAL "")
    set(CTKAPPLAUNCHER_APPLICATION_SUBDIR "${CTKAPPLAUNCHER_APPLICATION_BUILD_SUBDIR}/")
  endif()
  set(CTKAPPLAUNCHER_APPLICATION_SUBDIR "<APPLAUNCHER_DIR>/${CTKAPPLAUNCHER_APPLICATION_SUBDIR}")

  _generate_settings_configuration("BUILD" "build" "BUILD_SETTINGS_CONFIGURATION_FILEPATH")

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

  set(CTKAPPLAUNCHER_APPLICATION_EXECUTABLE_NAME ${CTKAPPLAUNCHER_APPLICATION_INSTALL_EXECUTABLE_NAME})

  _generate_settings_configuration("INSTALLED" "install" "INSTALL_SETTINGS_CONFIGURATION_FILEPATH")

  # Generate informational message ...
  set(extra_message)
  if(NOT ${CTKAPPLAUNCHER_SPLASH_IMAGE_NAME} STREQUAL "")
    set(extra_message " [${CTKAPPLAUNCHER_SPLASH_IMAGE_NAME}]")
  endif()
  set(comment "Creating application launcher: ${CTKAPPLAUNCHER_APPLICATION_NAME}${extra_message}")

  set(configured_launcher_executable
    ${CTKAPPLAUNCHER_DESTINATION_DIR}/${CTKAPPLAUNCHER_APPLICATION_NAME}${CMAKE_EXECUTABLE_SUFFIX}
    )

  # Create command to copy launcher executable into the build tree
  add_custom_command(
    DEPENDS
      ${CTKAppLauncher_EXECUTABLE}
    OUTPUT
      ${configured_launcher_executable}
    COMMAND ${CMAKE_COMMAND} -E copy
      ${CTKAppLauncher_EXECUTABLE}
      ${configured_launcher_executable}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT ${comment}
    )

  # Generate informational message ...
  set(extra_message)
  if(NOT ${CTKAPPLAUNCHER_SPLASH_IMAGE_NAME} STREQUAL "")
    set(extra_message " [${CTKAPPLAUNCHER_SPLASH_IMAGE_NAME}]")
  endif()
  set(comment "Configuring application launcher: ${CTKAPPLAUNCHER_APPLICATION_NAME}${extra_message}")

  # Launcher settings filepaths
  set(configured_launcher_settings
    ${CTKAPPLAUNCHER_DESTINATION_DIR}/${CTKAPPLAUNCHER_APPLICATION_NAME}LauncherSettings.ini
    )
  set(configured_launcher_settings_to_install
    ${CTKAPPLAUNCHER_DESTINATION_DIR}/${CTKAPPLAUNCHER_APPLICATION_NAME}LauncherSettingsToInstall.ini
    )

  # Create command to generate the launcher configuration files
  add_custom_command(
    DEPENDS
      ${CTKAppLauncher_DIR}/${CTK_INSTALL_CMAKE_DIR}/ctkAppLauncher-configure.cmake
      ${BUILD_SETTINGS_CONFIGURATION_FILEPATH}
      ${INSTALL_SETTINGS_CONFIGURATION_FILEPATH}
    OUTPUT
      ${configured_launcher_settings}
      ${configured_launcher_settings_to_install}
    COMMAND ${CMAKE_COMMAND}
      -DBUILD_SETTINGS_CONFIGURATION_FILEPATH:FILEPATH=${BUILD_SETTINGS_CONFIGURATION_FILEPATH}
      -DBUILD_SETTINGS_FILEPATH:FILEPATH=${configured_launcher_settings}
      -DINSTALL_SETTINGS_CONFIGURATION_FILEPATH:FILEPATH=${INSTALL_SETTINGS_CONFIGURATION_FILEPATH}
      -DINSTALL_SETTINGS_FILEPATH:FILEPATH=${configured_launcher_settings_to_install}
      -DTARGET_SUBDIR:STRING=${CMAKE_CFG_INTDIR}
      -P ${CTKAppLauncher_DIR}/${CTK_INSTALL_CMAKE_DIR}/ctkAppLauncher-configure.cmake
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT ${comment}
    )

  # Create target for launcher
  add_custom_target(${CTKAPPLAUNCHER_APPLICATION_NAME}ConfigureLauncher ALL
    DEPENDS
      ${configured_launcher_executable}
      ${configured_launcher_settings}
      ${configured_launcher_settings_to_install}
    )
endfunction()

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
