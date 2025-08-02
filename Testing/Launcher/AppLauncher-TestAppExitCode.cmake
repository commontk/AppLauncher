
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Configure settings file
file(WRITE "${launcher}LauncherSettings.ini" "
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
# Make sure the launcher consider the exit code of the launched program
set(command ${launcher_exe} --launcher-no-splash --exit-failure)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

set(exit_failure 1)
if(NOT rv EQUAL ${exit_failure})
  message(FATAL_ERROR "[${launcher_exe}] should exit with an error code when started '--exit-failure' option from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

set(expected_msg "Exit failure !")
string(REGEX MATCH ${expected_msg} current_msg ${ov})
if("${current_msg}" STREQUAL "")
  message(FATAL_ERROR "expected_msg:${expected_msg}, "
                      "current_msg:${ov}")
endif()
