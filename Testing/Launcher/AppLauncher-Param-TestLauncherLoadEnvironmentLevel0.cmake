
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
set(launcher_arg "--launcher-dump-environment")
set(command ${launcher_exe} --launcher-load-environment 0 ${launcher_arg})
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

function(check_env context)
  check_unexpected_string("${ov}" "APPLAUNCHER_LEVEL=1" "${context}")
  check_unexpected_string("${ov}" "APPLAUNCHER_LEVEL=0" "${context}")
  check_unexpected_string("${ov}" "APPLAUNCHER_0_VAR_FOR_ENV_LOAD_TEST" "${context}")
  check_expected_string("${ov}" "VAR_FOR_ENV_LOAD_TEST" "${context}")
endfunction()

check_env("flags '--launcher-load-environment 0 ${launcher_arg}'")

# --------------------------------------------------------------------------
set(launcher_arg "--launcher-show-set-environment-commands")
set(command ${launcher_exe} --launcher-load-environment 0 ${launcher_arg})
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

check_env("flags '--launcher-load-environment 0 ${launcher_arg}'")
