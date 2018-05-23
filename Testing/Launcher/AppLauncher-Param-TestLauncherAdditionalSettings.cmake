
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Configure settings file
set(regular_library_path_1 ${library_path})
set(regular_library_path_2 "/path/to/regular/libtwo")
set(regular_path_1 "/path/to/regular/stuff")
set(regular_path_2 "/path/to/regular/otherstuff")
set(regular_env_var_name_1 "SOMETHING_NICE")
set(regular_env_var_value_1 "Chocolate")
set(regular_env_var_name_2 "SOMETHING_AWESOME")
set(regular_env_var_value_2 "Rock climbing !")
set(common_env_var_name "SOMETHING_COMMON")
set(common_env_var_value_1 "Snow")
set(common_env_var2_name "ANOTHER_THING_COMMON")
set(common_env_var2_value_1 "Rocks")
file(WRITE "${launcher}LauncherSettings.ini" "
[Application]
path=${application}

[LibraryPaths]
1\\path=${regular_library_path_1}
2\\path=${regular_library_path_2}
size=2

[Paths]
1\\path=${regular_path_1}
2\\path=${regular_path_2}
size=2

[EnvironmentVariables]
${regular_env_var_name_1}=${regular_env_var_value_1}
${regular_env_var_name_2}=${regular_env_var_value_2}
${common_env_var_name}=${common_env_var_value_1}
${common_env_var2_name}=${common_env_var2_value_1}
")

# --------------------------------------------------------------------------
# Configure additional settings file
set(additional_settings_path "${launcher}AdditionalLauncherSettings.ini")
set(additional_library_path "/path/to/additional/lib")
set(additional_path_1 "/home/additional/app1")
set(additional_path_2 "/home/additional/app2")
set(additional_env_var_name_1 "ADD_SOMETHING_NICE")
set(additional_env_var_value_1 "Chocolate :)")
set(additional_env_var_name_2 "ADD_SOMETHING_AWESOME")
set(additional_env_var_value_2 "Rock climbing ! :)")
set(common_env_var_value_2 "Sun")
set(common_env_var2_value_2 "Trees")
file(WRITE ${additional_settings_path} "
[LibraryPaths]
1\\path=${additional_library_path}
size=1

[Paths]
1\\path=${additional_path_1}
2\\path=${additional_path_2}
size=2

[EnvironmentVariables]
${additional_env_var_name_1}=${additional_env_var_value_1}
${additional_env_var_name_2}=${additional_env_var_value_2}
${common_env_var_name}=<env:${common_env_var_name}>:${common_env_var_value_2}
${common_env_var2_name}=${common_env_var2_value_2}:<env:${common_env_var2_name}>

")

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 1)

# --------------------------------------------------------------------------
# Check if flag --launcher-additional-settings works as expected

set(command ${launcher_exe} --launcher-no-splash --launcher-additional-settings ${additional_settings_path})
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

# --------------------------------------------------------------------------
# Check if flag --launcher-additional-settings works as expected
set(command ${launcher_exe} --launcher-no-splash --launcher-dump-environment --launcher-additional-settings ${additional_settings_path})
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
  "${additional_env_var_name_2}=${additional_env_var_value_2}"
  "${additional_env_var_name_1}=${additional_env_var_value_1}"
  "${library_path_variable_name}=${additional_library_path}${pathsep}${regular_library_path_1}${pathsep}${regular_library_path_2}"
  "PATH=${additional_path_1}${pathsep}${additional_path_2}${pathsep}${regular_path_1}${pathsep}${regular_path_2}"
  "${regular_env_var_name_2}=${regular_env_var_value_2}\n"
  "${regular_env_var_name_1}=${regular_env_var_value_1}\n"
  "${common_env_var_name}=${common_env_var_value_1}:${common_env_var_value_2}\n"
  "${common_env_var2_name}=${common_env_var2_value_2}:${common_env_var2_value_1}\n"
  )
if(WIN32)
  set(expected_ov_lines
    "${additional_env_var_name_2}=${additional_env_var_value_2}"
    "${additional_env_var_name_1}=${additional_env_var_value_1}"
    "Path=${additional_path_1}${pathsep}${additional_path_2}${pathsep}${regular_path_1}${pathsep}${regular_path_2}${pathsep}${additional_library_path}${pathsep}${regular_library_path_1}${pathsep}${regular_library_path_2}"
    "${regular_env_var_name_2}=${regular_env_var_value_2}\n"
    "${regular_env_var_name_1}=${regular_env_var_value_1}\n"
    "${common_env_var_name}=${common_env_var_value_1}:${common_env_var_value_2}\n"
    "${common_env_var2_name}=${common_env_var2_value_2}:${common_env_var2_value_1}\n"
    )
endif()

foreach(expected_ov_line ${expected_ov_lines})
  check_expected_string("${ov}" "${expected_ov_line}" "reading additional settings file")
endforeach()

