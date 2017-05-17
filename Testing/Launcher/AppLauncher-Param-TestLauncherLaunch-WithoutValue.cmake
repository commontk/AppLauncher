include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# Configure settings file
file(WRITE "${launcher}LauncherSettings.ini" "
[LibraryPaths]
1\\path=${library_path}
size=1
")

# --------------------------------------------------------------------------
# Attempt to start launcher from its directory
# Since no application to launch has been specified - An error message is expected ...
set(command ${launcher_exe} --launcher-no-splash --launch)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_dir}
  ERROR_VARIABLE ev
  OUTPUT_QUIET
  ERROR_STRIP_TRAILING_WHITESPACE
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

set(expected_error_msg "Error\n  Argument --launch has 0 value(s) associated whereas exacly 1 are expected.\n${expected_help_text}")
if(NOT ${ev} STREQUAL ${expected_error_msg})
  message(FATAL_ERROR "expected_error_msg[${expected_error_msg}]\ncurrent[${ev}]")
endif()
