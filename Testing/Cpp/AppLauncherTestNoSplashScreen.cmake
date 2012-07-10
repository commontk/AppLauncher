#
# AppLauncherTestNoSplashScreen
#

set(ENV{DISPLAY})

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
# Delete settings file if it exists
execute_process(
  COMMAND ${CMAKE_COMMAND} -E remove -f ${launcher}LauncherSettings.ini
  )

# --------------------------------------------------------------------------
# Test1 - Check if flag --launcher-version works as expected
set(command ${launcher_exe} --launcher-no-splash )
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "TestNoSplashScreen - failed to start launcher "
    "with no splash screen if no DISPLAY\n${ev}")
endif()
