
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Configure settings file
file(WRITE "${launcher}LauncherSettings.ini" "
[LibraryPaths]
1\\path=${library_path}
size=1

[ExtraApplicationToLaunch]
helloworld/shortArgument=hw
helloworld/help=Start app4test application with --print-hello-world
helloworld/path=${application}
helloworld/arguments=--print-hello-world
")

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# Make sure the launcher considers the 'extra application to launch' short argument
set(command ${launcher_exe} --launcher-no-splash -hw)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "[${launcher_exe}] failed to start using '-hw' option from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

set(expected_msg "Hello world !")
string(REGEX MATCH ${expected_msg} current_msg ${ov})
if("${current_msg}" STREQUAL "")
  message(FATAL_ERROR "expected_msg:${expected_msg}, "
                      "current_msg:${ov}")
endif()

