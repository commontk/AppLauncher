
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Configure settings file
file(WRITE "${launcher}LauncherSettings.ini" "
[General]

[Application]
path=${application}

[LibraryPaths]
1\\path=${library_path}
size=1

[EnvironmentVariables]
VAR_FROM_SETTINGS=set-from-settings
")

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 1)

set(ENV{APPLAUNCHER_LEVEL} "1")
set(ENV{APPLAUNCHER_0_VAR_FOR_ENV_LOAD_TEST} "set-from-level-0")
set(ENV{VAR_FOR_ENV_LOAD_TEST} "set-from-level-1")
set(ENV{VAR_FROM_SETTINGS} "set-from-env")

# --------------------------------------------------------------------------
set(command ${launcher_exe} --check-environment-load --launcher-load-environment 0)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Problem using [${launcher_exe}] to start application [${application}] from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

# --------------------------------------------------------------------------
set(command ${launcher_exe} --launcher-load-environment 0 --launcher-dump-environment)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "[${launcher_exe}] failed to start from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

#
# Check that the loaded environment is also saved
#
set(unexpected_ov_str "APPLAUNCHER_LEVEL=2")
string(FIND "${ov}" "${unexpected_ov_str}" pos)
if(NOT ${pos} STREQUAL -1)
  message(FATAL_ERROR "Problem with flags '--launcher-load-environment 0 --launcher-dump-environment' - unexpected_ov_str:${unexpected_ov_str} "
                      "found in current_ov:${ov}")
endif()

set(expected_ov_str "APPLAUNCHER_0_VAR_FOR_ENV_LOAD_TEST")
string(FIND "${ov}" "${expected_ov_str}" pos)
if(${pos} STREQUAL -1)
  message(FATAL_ERROR "Problem with flags '--launcher-load-environment 0 --launcher-dump-environment' - expected_ov_str:${expected_ov_str} "
                      "not found in current_ov:${ov}")
endif()

# --------------------------------------------------------------------------
set(command ${launcher_exe} --launcher-load-environment 0 --launcher-show-set-environment-commands)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "[${launcher_exe}] failed to start from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

#
# Check that the loaded environment is also saved
#
set(unexpected_ov_str "APPLAUNCHER_LEVEL=2")
string(FIND "${ov}" "${unexpected_ov_str}" pos)
if(NOT ${pos} STREQUAL -1)
  message(FATAL_ERROR "Problem with flags '--launcher-load-environment 0 --launcher-show-set-environment-commands' - unexpected_ov_str:${unexpected_ov_str} "
                      "found in current_ov:${ov}")
endif()

set(expected_ov_str "APPLAUNCHER_0_VAR_FOR_ENV_LOAD_TEST")
string(FIND "${ov}" "${expected_ov_str}" pos)
if(${pos} STREQUAL -1)
  message(FATAL_ERROR "Problem with flags '--launcher-load-environment 0 --launcher-show-set-environment-commands' - expected_ov_str:${expected_ov_str} "
                      "not found in current_ov:${ov}")
endif()
