cmake_minimum_required(VERSION 2.8)

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

include(${CTKAPPLAUNCHER_DIR}/CMake/ctkAppLauncher.cmake)
ctkAppLauncherConfigure(
  TARGET ${PROJECT_NAME}-real
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
  PATHS_BUILD "<APPLAUNCHER_DIR>/dog;<APPLAUNCHER_DIR>/cat"
  PATHS_INSTALLED "<APPLAUNCHER_DIR>/cow;<APPLAUNCHER_DIR>/pig"
  LIBRARY_PATHS_BUILD "<APPLAUNCHER_DIR>/build/lib"
  LIBRARY_PATHS_INSTALLED "<APPLAUNCHER_DIR>/lib"
  ENVVARS_BUILD "BAR=NONE"
  ENVVARS_INSTALLED "BAR=ASSOCIATION"
  )
