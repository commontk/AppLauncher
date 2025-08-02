
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

set(sys_env_var_name "CTKAPPLAUNCHER_TEST_ENV_EXPRESSION")
set(sys_env_var_value "app3")
set(regular_path_1 "/home/john/app1")
set(regular_path_2 "/home/john/app2")
set(regular_path_3 "/home/john/<env:${sys_env_var_name}>")

set(ENV{${sys_env_var_name}} ${sys_env_var_value})

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
1\\path=${regular_path_1}
2\\path=${regular_path_2}
3\\path=${regular_path_3}
size=3
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

set(expected_regular_path_1 "${regular_path_1}")
set(expected_regular_path_2 "${regular_path_2}")
set(expected_regular_path_3 "/home/john/${sys_env_var_value}")

set(pathsep ":")
if(WIN32)
  set(pathsep "\;")
endif()
set(expected_msg "PATH=${expected_regular_path_1}${pathsep}${expected_regular_path_2}${pathsep}${expected_regular_path_3}")
string(REGEX MATCH ${expected_msg} current_msg ${stringified_ov})
if("${current_msg}" STREQUAL "")
  message(FATAL_ERROR "Failed to pass PATH variable from ${launcher_name} "
                      "to ${application_name}.\n"
                      "  expected_msg:${expected_msg}\n"
                      "  current_msg:${ov}")
endif()
