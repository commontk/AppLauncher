
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
# Make sure that (1) the launcher do not consider Qt reserved argument
# and (2) the launched application consider Qt reserved argument
set(command ${launcher_exe} --check-reserved-argument -widgetcount)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "[${launcher_exe}] failed to start from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

if("${ev}" MATCHES "Widgets left.*")
  message(FATAL_ERROR "error_variable [${ev}] shouldn't contain 'Widgets left'")
endif()

if(NOT "${ov}" MATCHES "-widgetcount argument passed")
  message(FATAL_ERROR "output_variable [${ov}] should contain '-widgetcount argument passed'")
endif()
