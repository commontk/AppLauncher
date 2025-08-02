
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Configure settings file
file(WRITE "${launcher}LauncherSettings.ini" "
[General]
AdditionalLauncherHelpLongArgument=--help

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
set(PRINT_COMMAND 1)

# --------------------------------------------------------------------------
# Test1 - Make sure application to launch get no arguments
#         when specified using "--launch".

set(command ${launcher_exe} --launch ${application})
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "[${launcher_exe}] failed to start using '--helloworld' option from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

set(expected_msg "No argument provided")
string(REGEX MATCH ${expected_msg} current_msg ${ov})
if("${current_msg}" STREQUAL "")
  message(FATAL_ERROR "expected_msg:${expected_msg}, "
                      "current_msg:${ov}")
endif()

# --------------------------------------------------------------------------
# Test2 - Make sure application to launch get no arguments
#         when specified using extra application argument
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
  message(FATAL_ERROR "[${launcher_exe}] failed to start using '--helloworld' option from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

set(expected_msg "Hello world !")
string(REGEX MATCH ${expected_msg} current_msg ${ov})
if("${current_msg}" STREQUAL "")
  message(FATAL_ERROR "expected_msg:${expected_msg}, "
                      "current_msg:${ov}")
endif()

# --------------------------------------------------------------------------
# Test3 - Make sure that
#          (1) launcher does NOT display its own help
#          (2) application to launch displays its help

set(command ${launcher_exe} --launcher-no-splash --helloworld --help)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "[${launcher_exe}] failed to start using '--helloworld' and '--help' options from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

set(expected_msg "Hello world !")
string(REGEX MATCH ${expected_msg} current_msg ${ov})
if("${current_msg}" STREQUAL "")
  message(FATAL_ERROR "expected_msg:${expected_msg}, "
                      "current_msg:${ov}")
endif()

set(unexpected_msg ".*CTKAppLauncher \\[options\\].*")
string(REGEX MATCH ${unexpected_msg} current_msg ${ov})
if(NOT "${current_msg}" STREQUAL "")
  message(FATAL_ERROR "unexpected_msg:${unexpected_msg}, "
                      "current_msg:${ov}")
endif()
