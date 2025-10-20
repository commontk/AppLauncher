
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
# Delete timeout file if it exists
execute_process(
  COMMAND ${CMAKE_COMMAND} -E remove -f ${application}-timeout.txt
  )

# --------------------------------------------------------------------------
# Check if flag --launcher-timeout works as expected
set(command ${launcher_exe} --launcher-no-splash --launcher-timeout 4 --launch ${application} --test-timeout)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  RESULT_VARIABLE rv
  )
print_command_as_string("${command}")

if(NOT "${rv}" STREQUAL "3")
  message(FATAL_ERROR "Failed to run [${launcher_exe}] with parameter --launcher-timeout\n${ev}")
endif()

# Since launcher-timeout > App4Test-timeout, file ${application}-timeout.txt should exists
if(NOT EXISTS ${application}-timeout.txt)
   message(FATAL_ERROR "Problem with flag --launcher-timeout. "
                       "File [${application}-timeout.txt] should exist.")
endif()

# Delete timeout file if it exists
execute_process(
  COMMAND ${CMAKE_COMMAND} -E remove -f ${application}-timeout.txt
  )

# Re-try with launcher-timeout < App4Test-timeout
set(command ${launcher_exe} --launcher-no-splash --launcher-timeout 1 --launch ${application} --test-timeout)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

# Since we force the application to shutdown, we expect the error code to be >0
if(NOT rv)
  message(FATAL_ERROR "Failed to run [${launcher_exe}] with parameter --launcher-timeout\n${ev}")
endif()

# Since launcher-timeout < App4Test-timeout, file ${application}-timeout.txt should NOT exist
# Note: On windows, since our App4Test does NOT support the WM_CLOSE event, let's skip the test.
#       See https://github.com/commontk/AppLauncher/issues/15
set(_exists)
set(_exists_msg " NOT")
if(WIN32)
  set(_exists NOT)
  set(_exists_msg)
endif()
if(${_exists} EXISTS ${application}-timeout.txt)
   message(FATAL_ERROR "Problem with flag --launcher-timeout. "
                       "File [${application}-timeout.txt] should ${_exists_msg}exist.")
endif()
