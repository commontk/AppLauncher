
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Configure settings file
set(organization_domain "www.commontk-${TEST_TREE_TYPE}.org")
set(organization_name "Common ToolKit ${TEST_TREE_TYPE}")
set(application_name "AppLauncher")
set(application_revision "4810")
set(regular_library_path_1 ${library_path})
set(regular_library_path_2 "/path/to/regular/libtwo")
set(regular_path_1 "/path/to/regular/stuff")
set(regular_path_2 "/path/to/regular/otherstuff")
set(regular_env_var_name_1 "SOMETHING_NICE")
set(regular_env_var_value_1 "Chocolate")
set(regular_env_var_name_2 "SOMETHING_AWESOME")
set(regular_env_var_value_2 "Rock climbing !")
set(regular_pathenv_var_name_1 "SOME_PATH")
set(regular_pathenv_var_value_1_1 "/farm/cow")
set(regular_pathenv_var_value_1_2 "/farm/pig")
set(common_env_var_name "SOMETHING_COMMON")
set(common_env_var_value_1 "Snow")
set(common_env_var2_name "ANOTHER_THING_COMMON")
set(common_env_var2_value_1 "Rocks")

file(WRITE "${launcher}LauncherSettings.ini" "
[Application]
path=${application}
organizationDomain=${organization_domain}
organizationName=${organization_name}
name=${application_name}
revision=${application_revision}

[LibraryPaths]
1\\path=${regular_library_path_1}
2\\path=${regular_library_path_2}
size=2

[Paths]
1\\path=${regular_path_1}
2\\path=${regular_path_2}
size=2

[Environment]
additionalPathVariables=${regular_pathenv_var_name_1}

[EnvironmentVariables]
${regular_env_var_name_1}=${regular_env_var_value_1}
${regular_env_var_name_2}=${regular_env_var_value_2}
${common_env_var_name}=${common_env_var_value_1}
${common_env_var2_name}=${common_env_var2_value_1}

[${regular_pathenv_var_name_1}]
1\\path=${regular_pathenv_var_value_1_1}
2\\path=${regular_pathenv_var_value_1_2}
size=2
")

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# Extract application settings directory

extract_application_settings_value("UserAdditionalSettingsDir" user_additional_settings_dir)
set(user_additional_settings_path "${user_additional_settings_dir}/${application_name}-${application_revision}.ini")

# --------------------------------------------------------------------------
# Configure user additional settings file
set(additional_library_path_1 "/path/to/user-additional/lib")
set(additional_library_path_2 "relative-path/to/user-additional/lib")
set(additional_path_1 "/home/user-additional/app1")
set(additional_path_2 "/home/user-additional/app2")
set(additional_path_3 "relative-user-additional/app3")
set(additional_env_var_name_1 "USER_ADD_SOMETHING_NICE")
set(additional_env_var_value_1 "Chocolate :)")
set(additional_env_var_name_2 "USER_ADD_SOMETHING_AWESOME")
set(additional_env_var_value_2 "Rock climbing ! :)")
set(additional_pathenv_var_value_1_1 "/farm/donkey")
set(additional_pathenv_var_value_1_2 "/farm/chicken")
set(additional_pathenv_var_name_2 "USER_ADD_SOME_PATH")
set(additional_pathenv_var_value_2_1 "/user-additional-farm/cow")
set(additional_pathenv_var_value_2_2 "/user-additional-farm/pig")
set(common_env_var_value_2 "Sun")
set(common_env_var2_value_2 "Trees")

file(WRITE ${user_additional_settings_path} "
[LibraryPaths]
1\\path=${additional_library_path_1}
2\\path=${additional_library_path_2}
size=2

[Paths]
1\\path=${additional_path_1}
2\\path=${additional_path_2}
3\\path=${additional_path_3}
size=3

[Environment]
additionalPathVariables=${additional_pathenv_var_name_2}

[EnvironmentVariables]
${additional_env_var_name_1}=${additional_env_var_value_1}
${additional_env_var_name_2}=${additional_env_var_value_2}
${common_env_var_name}=<env:${common_env_var_name}>:${common_env_var_value_2}
${common_env_var2_name}=${common_env_var2_value_2}:<env:${common_env_var2_name}>

[${regular_pathenv_var_name_1}]
1\\path=${additional_pathenv_var_value_1_1}
2\\path=${additional_pathenv_var_value_1_2}
size=2

[${additional_pathenv_var_name_2}]
1\\path=${additional_pathenv_var_value_2_1}
2\\path=${additional_pathenv_var_value_2_2}
size=2

")

# --------------------------------------------------------------------------
# Check if launcher works as expected

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
  message(FATAL_ERROR "[${launcher_exe}] failed to start from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

# --------------------------------------------------------------------------
# Check if launcher works as expected
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

set(expected_pathenv_var_value_1
  "${additional_pathenv_var_value_1_1}${pathsep}${additional_pathenv_var_value_1_2}")
set(expected_pathenv_var_value_1
  "${expected_pathenv_var_value_1}${pathsep}${regular_pathenv_var_value_1_1}${pathsep}${regular_pathenv_var_value_1_2}")

set(expected_pathenv_var_value_2
  "${additional_pathenv_var_value_2_1}${pathsep}${additional_pathenv_var_value_2_2}")

set(expected_additional_library_path_2 "${launcher_dir}/${additional_library_path_2}")
set(expected_additional_path_3 "${launcher_dir}/${additional_path_3}")

set(expected_ov_lines
  "${additional_env_var_name_2}=${additional_env_var_value_2}"
  "${additional_env_var_name_1}=${additional_env_var_value_1}"
  "${library_path_variable_name}=${additional_library_path_1}${pathsep}${expected_additional_library_path_2}${pathsep}${regular_library_path_1}${pathsep}${regular_library_path_2}"
  "PATH=${additional_path_1}${pathsep}${additional_path_2}${pathsep}${expected_additional_path_3}${pathsep}${regular_path_1}${pathsep}${regular_path_2}"
  "${regular_env_var_name_2}=${regular_env_var_value_2}\n"
  "${regular_env_var_name_1}=${regular_env_var_value_1}\n"
  "${regular_pathenv_var_name_1}=${expected_pathenv_var_value_1}\n"
  "${additional_pathenv_var_name_2}=${expected_pathenv_var_value_2}\n"
  "${common_env_var_name}=${common_env_var_value_1}:${common_env_var_value_2}\n"
  "${common_env_var2_name}=${common_env_var2_value_2}:${common_env_var2_value_1}\n"
  )
if(WIN32)
  set(expected_ov_lines
    "${additional_env_var_name_2}=${additional_env_var_value_2}"
    "${additional_env_var_name_1}=${additional_env_var_value_1}"
    "Path=${additional_path_1}${pathsep}${additional_path_2}${pathsep}${expected_additional_path_3}${pathsep}${regular_path_1}${pathsep}${regular_path_2}${pathsep}${additional_library_path_1}${pathsep}${expected_additional_library_path_2}${pathsep}${regular_library_path_1}${pathsep}${regular_library_path_2}"
    "${regular_env_var_name_2}=${regular_env_var_value_2}\n"
    "${regular_env_var_name_1}=${regular_env_var_value_1}\n"
    "${regular_pathenv_var_name_1}=${expected_pathenv_var_value_1}\n"
    "${additional_pathenv_var_name_2}=${expected_pathenv_var_value_2}\n"
    "${common_env_var_name}=${common_env_var_value_1}:${common_env_var_value_2}\n"
    "${common_env_var2_name}=${common_env_var2_value_2}:${common_env_var2_value_1}\n"
    )
endif()

foreach(expected_ov_line ${expected_ov_lines})
  check_expected_string("${ov}" "${expected_ov_line}" "reading additional settings file")
endforeach()

# Clean
file(REMOVE ${user_additional_settings_path})
