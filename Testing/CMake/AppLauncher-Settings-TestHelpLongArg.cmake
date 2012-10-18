
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Configure settings file
file(WRITE "${launcher}LauncherSettings.ini" "
[General]
additionalLauncherHelpLongArgument=--long-help

[Application]
path=${application}

[LibraryPaths]
1\\path=${library_path}
size=1
")

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# Check if flag --launcher-help works as expected
set(command ${launcher_exe} --long-help)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "[${launcher_exe}] failed to start application [${application}] from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

set(expected_msg "This is the long help
Usage
  CTKAppLauncher [options]

Options
  --launcher-help                  Display help
  --launcher-version               Show launcher version information
  --launcher-verbose               Verbose mode
  --launch                         Specify the application to launch
  --launcher-detach                Launcher will NOT wait for the application to finish
  --launcher-no-splash             Hide launcher splash
  --launcher-timeout               Specify the time in second before the launcher kills the application. -1 means no timeout (default: -1)
  --launcher-dump-environment      Launcher will print environment variables to be set, then exit
  --launcher-additional-settings   Additional settings file to consider
  --launcher-generate-template     Generate an example of setting file
")

if(NOT ${expected_msg} STREQUAL ${ov})
  message(FATAL_ERROR "Problem with flag --launcher-help."
                      "\n expected_msg:\n ${expected_msg}"
                      "\n current_msg:\n ${ov}")
endif()

