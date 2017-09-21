
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
