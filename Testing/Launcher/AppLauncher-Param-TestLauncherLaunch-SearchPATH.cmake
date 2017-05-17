
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Configure settings file
file(WRITE "${launcher}LauncherSettings.ini" "

[Paths]
1\\path=${application_dir}
size=1

[LibraryPaths]
1\\path=${library_path}
size=1
")

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# TestLaunchExecutableInPath - If launcher search considers PATH as expected, the launcher should
#                              execute App4Test if specified as command line parameter.
set(command ${launcher_exe} --launcher-no-splash --launch ${application_name} --print-hello-world)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

set(expected_msg "Hello world !")
string(REGEX MATCH ${expected_msg} current_msg "${ov}")
if("${current_msg}" STREQUAL "")
  message(FATAL_ERROR "TestLaunchExecutableInPath\n"
                      "  expected_msg:${expected_msg}\n"
                      "  current_msg:${ov}")
endif()

