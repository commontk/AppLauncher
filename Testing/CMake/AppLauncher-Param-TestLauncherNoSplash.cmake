
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# Disable DISPLAY environment variable to test if the following works when
# no graphical context can be instantiated (e.g. use QCoreApplication instead
# of QApplication)
set(ENV{DISPLAY})

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
# TestNoSplashScreen - Check if launcher can work in no DISPLAY environment
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
  message(FATAL_ERROR "TestNoSplashScreen - Failed to start launcher "
    "using `--launcher-no-splash`. Launcher is expected to run even if DISPLAY "
    "environment variable is unset.\n${ev}")
endif()
