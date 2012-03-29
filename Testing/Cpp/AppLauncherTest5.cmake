
#
# AppLauncherTest5
#

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
# Test1 - Make sure the launcher considers the 'extra application to launch' long argument
set(command ${launcher_exe} --launcher-no-splash --helloworld)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Test1 - [${launcher_exe}] failed to start using '--helloworld' option from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

set(expected_msg "Hello world !")
string(REGEX MATCH ${expected_msg} current_msg ${ov})
if("${current_msg}" STREQUAL "")
  message(FATAL_ERROR "Test1 - expected_msg:${expected_msg}, "
                      "current_msg:${ov}")
endif()

# --------------------------------------------------------------------------
# Test2 - Make sure the launcher considers the 'extra application to launch' short argument
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
  message(FATAL_ERROR "Test2 - [${launcher_exe}] failed to start using '-hw' option from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

set(expected_msg "Hello world !")
string(REGEX MATCH ${expected_msg} current_msg ${ov})
if("${current_msg}" STREQUAL "")
  message(FATAL_ERROR "Test2 - expected_msg:${expected_msg}, "
                      "current_msg:${ov}")
endif()

# --------------------------------------------------------------------------
# Configure settings file
file(WRITE "${launcher}LauncherSettings.ini" "
[LibraryPaths]
1\\path=${library_path}
size=1

[ExtraApplicationToLaunch]
helloworld/help=Start app4test application
helloworld/path=${application}
helloworld/arguments=
")

# --------------------------------------------------------------------------
# Test3 - Make sure the launcher considers the 'extra application to launch' long argument
#         with its argument passed from the command line.
set(command ${launcher_exe} --launcher-no-splash --helloworld --print-hello-world)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Test3 - [${launcher_exe}] failed to start using '--helloworld' and 'print-hello-world' options from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

set(expected_msg "Hello world !")
string(REGEX MATCH ${expected_msg} current_msg ${ov})
if("${current_msg}" STREQUAL "")
  message(FATAL_ERROR "Test3 - expected_msg:${expected_msg}, "
                      "current_msg:${ov}")
endif()
