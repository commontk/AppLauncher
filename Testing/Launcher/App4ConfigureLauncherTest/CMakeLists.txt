cmake_minimum_required(VERSION 3.0)

project(App4ConfigureLauncherTest)

# Disable warning C4996: [...] This function or variable may be unsafe. [...]
# To disable deprecation, use _CRT_SECURE_NO_WARNINGS. See online help for details
if(MSVC90)
  add_definitions(-D_CRT_SECURE_NO_WARNINGS)
endif()

# Add excutable
add_executable(${PROJECT_NAME}-real Main.cpp)

set_target_properties(${PROJECT_NAME}-real PROPERTIES
  SKIP_BUILD_RPATH ON
  RUNTIME_OUTPUT_DIRECTORY ${${PROJECT_NAME}_BINARY_DIR}/bin
  )

set(TEST_PYTHONPATH_BUILD "<APPLAUNCHER_DIR>/build/lib/python/site-packages")

set(TEST_PYTHONPATH_INSTALLED "<APPLAUNCHER_DIR>/lib/python/site-packages")
set(TEST_QT_PLUGIN_PATH_BUILD "<APPLAUNCHER_DIR>/build/libexec/qt")
set(TEST_QT_PLUGIN_PATH_INSTALLED "<APPLAUNCHER_DIR>/libexec/qt")

if(NOT DEFINED WITH_CONFIG_FILE)
  message(FATAL_ERROR "Configuring with WITH_CONFIG_FILE is mandatory.")
endif()

if(NOT DEFINED TEST_FUNCTION)
  message(FATAL_ERROR "Configuring with TEST_FUNCTION is mandatory.")
endif()

set(arguments
  LAUNCHER_LOAD_ENVIRONMENT 0
  APPLICATION_DEFAULT_ARGUMENTS "--foo bar"
  APPLICATION_INSTALL_SUBDIR bin
  APPLICATION_NAME ${PROJECT_NAME}
  APPLICATION_REVISION 0.1
  ORGANIZATION_DOMAIN com.kitware
  ORGANIZATION_NAME Kitware
  DESTINATION_DIR ${${PROJECT_NAME}_BINARY_DIR}
  DEFAULT_APPLICATION_ARGUMENT "--foo"
  HELP_SHORT_ARG "-h"
  HELP_LONG_ARG "--help"
  NOSPLASH_ARGS "--no-splash"
  PATHS_BUILD "<APPLAUNCHER_DIR>/dog;<APPLAUNCHER_DIR>/cat;<APPLAUNCHER_SETTINGS_DIR>/frog"
  PATHS_INSTALLED "<APPLAUNCHER_DIR>/cow;<APPLAUNCHER_DIR>/pig;<APPLAUNCHER_SETTINGS_DIR>/donkey;"
  LIBRARY_PATHS_BUILD "<APPLAUNCHER_DIR>/build/lib"
  LIBRARY_PATHS_INSTALLED "<APPLAUNCHER_DIR>/lib"
  ENVVARS_BUILD "BAR=NONE" "PLACEHOLDER=build-<APPLAUNCHER_DIR>-<APPLAUNCHER_NAME>"
  ENVVARS_INSTALLED "BAR=ASSOCIATION" "PLACEHOLDER=install-<APPLAUNCHER_DIR>-<APPLAUNCHER_NAME>"
  ADDITIONAL_PATH_ENVVARS_BUILD "PYTHONPATH;QT_PLUGIN_PATH"
  ADDITIONAL_PATH_ENVVARS_INSTALLED "PYTHONPATH;QT_PLUGIN_PATH"
  ADDITIONAL_PATH_ENVVARS_PREFIX TEST_
  )

if(WITH_CONFIG_FILE)
  find_package(CTKAppLauncher REQUIRED)

  if(TEST_FUNCTION STREQUAL "ForTarget")
    ctkAppLauncherConfigureForTarget(
      TARGET ${PROJECT_NAME}-real
      ${arguments}
      )
  elseif(TEST_FUNCTION STREQUAL "ForExecutable")
    ctkAppLauncherConfigureForExecutable(
      APPLICATION_NAME ${PROJECT_NAME}
      APPLICATION_EXECUTABLE ${${PROJECT_NAME}_BINARY_DIR}/bin/${PROJECT_NAME}-real${CMAKE_EXECUTABLE_SUFFIX}
      ${arguments}
      )
  elseif(TEST_FUNCTION STREQUAL "Deprecated")
    ctkAppLauncherConfigure(
      TARGET ${PROJECT_NAME}-real
      ${arguments}
      )
  else()
    message(FATAL_ERROR "Problem with TEST_FUNCTION parameter. Unknown value [${TEST_FUNCTION}]")
  endif()

else()
  include(${CTKAPPLAUNCHER_DIR}/CMake/ctkAppLauncher.cmake)

  if(TEST_FUNCTION STREQUAL "Deprecated")
    ctkAppLauncherConfigure(
      TARGET ${PROJECT_NAME}-real
      ${arguments}
      )
  else()
    message(FATAL_ERROR "Problem with TEST_FUNCTION parameter. Unknown value [${TEST_FUNCTION}]")
  endif()
endif()

if(SCRIPT_MODE STREQUAL "Configure")

  set(expected_target "${PROJECT_NAME}ConfigureLauncher")
  if(NOT TARGET "${expected_target}")
    message(FATAL_ERROR "Missing expected target: ${expected_target}")
  endif()

elseif(SCRIPT_MODE STREQUAL "Script")

  # NA

else()
  message(FATAL_ERROR "Unknown SCRIPT_MODE value [${SCRIPT_MODE}]")
endif()
