
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# Configure settings file
file(WRITE "${launcher}LauncherSettings.ini" "
[General]

[Application]
path=${application}
arguments=--check-path

[LibraryPaths]
1\\path=${library_path}
size=1

[Paths]
1\\path=/home/john/app1
2\\path=/home/john/app2
size=2
")

# --------------------------------------------------------------------------
# Make sure the launcher passes the PATH variable to the application
set(command ${launcher_exe} --launcher-no-splash)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "[${launcher_exe}] failed to start application [${application}] from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

set(stringified_ov)
list_to_string("${ov}" stringified_ov)

set(pathsep ":")
if(WIN32)
  set(pathsep "\;")
endif()
set(expected_msg "PATH=/home/john/app1${pathsep}/home/john/app2")
string(REGEX MATCH ${expected_msg} current_msg ${stringified_ov})
if("${current_msg}" STREQUAL "")
  message(FATAL_ERROR "Failed to pass PATH variable from ${launcher_name} "
                      "to ${application_name}.\n"
                      "  expected_msg:${expected_msg}\n"
                      "  current_msg:${ov}")
endif()

