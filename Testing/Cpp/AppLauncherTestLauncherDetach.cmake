#
# AppLauncherTestLauncherDetach
#

include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Delete settings file if it exists
execute_process(
  COMMAND ${CMAKE_COMMAND} -E remove -f ${launcher}LauncherSettings.ini
  )

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
# TestLauncherDetach - If launcher detach works as expected, the laucnher should return EXIT_SUCCESS
set(command ${launcher_exe} --launcher-no-splash --launcher-detach --exit-failure)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "TestLauncherDetach - Failed to start application and detach launcher.\n${ev}")
endif()
