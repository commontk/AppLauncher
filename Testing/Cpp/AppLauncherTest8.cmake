
#
# AppLauncherTest8
#

include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# Delete settings file if it exists
execute_process(
  COMMAND ${CMAKE_COMMAND} -E remove -f ${launcher}LauncherSettings.ini
  )

# --------------------------------------------------------------------------
# Test1 - Check if flag --launcher-version works as expected
set(command ${launcher_exe} --launcher-version --launch ${application})
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Test1 - [${launcher_exe}] failed to start application [${application}] from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

set(expected_msg "CTKAppLauncher launcher version ${launcher_version}
")

if(NOT ${expected_msg} STREQUAL ${ov})
  message(FATAL_ERROR "Test1 - Problem with flag --launcher-version."
                      "\n expected_msg:\n ${expected_msg}"
                      "\n current_msg:\n ${ov}")
endif()
