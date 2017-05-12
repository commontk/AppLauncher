
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
# Make sure the launcher output an error message if no application is specified
set(command ${launcher_exe} --launcher-no-splash)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  ERROR_STRIP_TRAILING_WHITESPACE
  )

print_command_as_string("${command}")

set(expected_error_msg "error: Application does NOT exists []${expected_help_text}")
if(NOT "${ev}" STREQUAL "${expected_error_msg}")
  message(FATAL_ERROR "No application has been specified"
                      "\n  expected_error_msg:${expected_error_msg}"
                      "\n  current_error_msg:${ev}")
endif()

