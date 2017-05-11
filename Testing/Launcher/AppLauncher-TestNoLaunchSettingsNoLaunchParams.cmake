include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# Attempt to start launcher from its directory
# Since there is no setting file and no parameter are given to the launcher,
# we expect it to fail with the following message:
set(expected_error_msg "error: Application does NOT exists []
error: --launch argument has NOT been specified
error: Launcher setting file [${launcher_name}LauncherSettings.ini] does NOT exist in any of these directories:
${launcher_dir}/.
${launcher_dir}/bin
${launcher_dir}/lib
${expected_help_text}")

set(command ${launcher_exe} --launcher-no-splash)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_dir}
  ERROR_VARIABLE ev
  ERROR_STRIP_TRAILING_WHITESPACE
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(NOT ${ev} STREQUAL ${expected_error_msg})
  message(FATAL_ERROR "Since ${launcher_name} was started without any setting file or "
                      " parameter, it should have failed to start printing the expected "
                      " error message.")
endif()

if(NOT ${rv} EQUAL 1)
  message(FATAL_ERROR "Since ${launcher_name} was started without any setting file or "
                      " parameter, it should have failed to start with exit code of 1")
endif()
