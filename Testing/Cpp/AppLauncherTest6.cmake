
#
# AppLauncherTest6
#

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
# Test1 - Make sure the launcher consider the exit code of the launched program
set(command ${launcher_exe} --launcher-no-splash --exit-failure)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

set(exit_failure 1)
if(NOT rv EQUAL ${exit_failure})
  message(FATAL_ERROR "Test1 - [${launcher_exe}] should exit with an error code when started '--exit-failure' option from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

set(expected_msg "Exit failure !")
string(REGEX MATCH ${expected_msg} current_msg ${ov})
if("${current_msg}" STREQUAL "")
  message(FATAL_ERROR "Test1 - expected_msg:${expected_msg}, "
                      "current_msg:${ov}")
endif()

# --------------------------------------------------------------------------
# Test2 - Make sure the launcher do not consider Qt reserved argument
set(command ${launcher_exe} -widgetcount --launcher-no-splash)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Test2 - [${launcher_exe}] failed to start from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

if("${ev}" MATCHES "Widgets left.*")
  message(FATAL_ERROR "Test2 - error_variable [${ev}] shouldn't contain 'Widgets left'")
endif()

# --------------------------------------------------------------------------
# Configure settings file
set(other_library_path "/path/to/other/lib")
set(path_1 "/home/john/app1")
set(path_2 "/home/john/app2")
set(env_var_name_1 "SOMETHING_NICE")
set(env_var_value_1 "Chocolate")
set(env_var_name_2 "SOMETHING_AWESOME")
set(env_var_value_2 "Rock climbing !")
file(WRITE "${launcher}LauncherSettings.ini" "
[Application]
path=${application}

[LibraryPaths]
1\\path=${library_path}
2\\path=${other_library_path}
size=2

[Paths]
1\\path=${path_1}
2\\path=${path_2}
size=2

[EnvironmentVariables]
${env_var_name_1}=${env_var_value_1}
${env_var_name_2}=${env_var_value_2}

")

# --------------------------------------------------------------------------
# Test3 - Check if flag --launcher-dump-environment works as expected
set(command ${launcher_exe} --launcher-no-splash --launcher-dump-environment)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Test3 - [${launcher_exe}] failed to start from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

if(WIN32)
  set(pathsep ";")
  set(library_path_variable_name "PATH")
elseif(APPLE)
  set(pathsep ":")
  set(library_path_variable_name "DYLD_LIBRARY_PATH")
elseif(UNIX)
  set(pathsep ":")
  set(library_path_variable_name "LD_LIBRARY_PATH")
endif()

set(expected_ov "${library_path_variable_name}=${other_library_path}${pathsep}${library_path}${pathsep}
PATH=${path_1}${pathsep}${path_2}${pathsep}
${env_var_name_2}=${env_var_value_2}
${env_var_name_1}=${env_var_value_1}\n")

if(NOT "${ov}" STREQUAL "${expected_ov}")
  message(FATAL_ERROR "Test3 - Problem with flag --launcher-dump-environment - expected_ov:${expected_ov} "
                      "current_ov:${ov}")
endif()
