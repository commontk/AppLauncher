
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# Configure settings file
file(WRITE "${launcher}LauncherSettings.ini" "
[General]

[Application]
path=${application}
arguments=--foo myarg --list item1 item2 item3 --verbose

[LibraryPaths]
1\\path=${library_path}
size=1
")

# --------------------------------------------------------------------------
# Make sure the launcher works as expected if the application
# to launch and the associated arguments are properly set in the settings file
set(command ${launcher_exe} --launcher-no-splash)
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

set(expected_msg "Argument passed:--foo myarg --list item1 item2 item3 --verbose")
string(REGEX MATCH ${expected_msg} current_msg ${ov})
if(NOT "${expected_msg}" STREQUAL "${current_msg}")
  message(FATAL_ERROR "Failed to pass parameters from ${launcher_name} "
                      "to ${application_name}.")
endif()

