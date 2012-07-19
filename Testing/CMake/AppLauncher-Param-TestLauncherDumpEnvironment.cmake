
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

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
# Check if flag --launcher-dump-environment works as expected
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
  message(FATAL_ERROR "[${launcher_exe}] failed to start from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

set(expected_ov_lines
  "${library_path_variable_name}=${library_path}${pathsep}${other_library_path}${pathsep}"
  "PATH=${path_1}${pathsep}${path_2}${pathsep}"
  "${env_var_name_2}=${env_var_value_2}\n"
  "${env_var_name_1}=${env_var_value_1}\n"
  )
if(WIN32)
  set(expected_ov_lines
    "PATH=${path_1}${pathsep}${path_2}${pathsep}${library_path}${pathsep}${other_library_path}${pathsep}"
    "${env_var_name_2}=${env_var_value_2}\n"
    "${env_var_name_1}=${env_var_value_1}\n"
    )
endif()

foreach(expected_ov_line ${expected_ov_lines})
  string(FIND "${ov}" ${expected_ov_line} pos)
  if(${pos} STREQUAL -1)
    message(FATAL_ERROR "Problem with flag --launcher-dump-environment - expected_ov_line:${expected_ov_line} "
                        "not found in current_ov:${ov}")
  endif()
endforeach()
