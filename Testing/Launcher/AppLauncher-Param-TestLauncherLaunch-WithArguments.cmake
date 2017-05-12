
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Configure settings file
file(WRITE "${launcher}LauncherSettings.ini" "
[LibraryPaths]
1\\path=${library_path}
size=1
")

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# Pass arguments to the application using the launcher
set(command ${launcher_exe} --launcher-no-splash --launch ${application} --foo myarg --list item1 item2 item3 --verbose)
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

set(expected_msg "Argument count: 8 - Argument passed:--foo myarg --list item1 item2 item3 --verbose")
string(REGEX MATCH ${expected_msg} current_msg ${ov})
if(NOT "${expected_msg}" STREQUAL "${current_msg}")
  message(FATAL_ERROR "Failed to pass parameters from ${launcher_name} "
                      "to ${application_name}.\n"
                      "  expected_msg:${expected_msg}\n"
                      "    output_msg:${ov}")
endif()

