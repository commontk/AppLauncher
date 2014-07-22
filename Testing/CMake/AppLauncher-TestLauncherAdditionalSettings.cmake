
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Configure settings file
set(organization_domain "www.commontk.org")
set(organization_name "Common ToolKit")
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
[General]
additionalPathVariables=${regular_pathenv_var_name_1}

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

extract_application_settings_value("AdditionalSettingsDir" user_additional_settings_dir)
set(user_additional_settings_path "${user_additional_settings_dir}/${application_name}-${application_revision}.ini")

# --------------------------------------------------------------------------
# Configure user additional settings file
set(user_sys_env_var_name "CTKAPPLAUNCHER_TEST_USER_ENV_EXPRESSION")
set(user_sys_env_var_value "Powder as in snow")
set(user_additional_env_var_name_1 "USER_ADD_SOMETHING_NICE")
set(user_additional_env_var_value_1 "Chocolate :)")
set(user_additional_env_var_name_2 "USER_ADD_SOMETHING_AWESOME")
set(user_additional_env_var_value_2 "Rock climbing ! :)")
set(user_additional_env_var_name_3 "USER_ADD_SOMETHING_GREAT")
set(user_additional_env_var_value_3 "<env:${user_sys_env_var_name}>")
set(user_additional_pathenv_var_value_1_1 "/farm/donkey")
set(user_additional_pathenv_var_value_1_2 "/farm/chicken")
set(user_additional_pathenv_var_name_2 "USER_SOME_PATH")
set(user_additional_pathenv_var_value_2_1 "/user-farm/cow")
set(user_additional_pathenv_var_value_2_2 "/user-farm/pig")
set(user_additional_library_path "/path/to/user-additional/lib")
set(user_additional_path_1 "/home/user-additional/app1")
set(user_additional_path_2 "/home/user-additional/app2")
set(user_additional_path_3 "/home/user-additional/<env:${user_sys_env_var_name}>")
set(common_env_var_value_2 "Recycle")
set(common_env_var2_value_2 "Energy")

set(ENV{${user_sys_env_var_name}} ${user_sys_env_var_value})

file(WRITE ${user_additional_settings_path} "
[General]
additionalPathVariables=${user_additional_pathenv_var_name_2}

[LibraryPaths]
1\\path=${user_additional_library_path}
size=1

[Paths]
1\\path=${user_additional_path_1}
2\\path=${user_additional_path_2}
3\\path=${user_additional_path_3}
size=3

[EnvironmentVariables]
${user_additional_env_var_name_1}=${user_additional_env_var_value_1}
${user_additional_env_var_name_2}=${user_additional_env_var_value_2}
${user_additional_env_var_name_3}=${user_additional_env_var_value_3}
${common_env_var_name}=<env:${common_env_var_name}>:${common_env_var_value_2}
${common_env_var2_name}=${common_env_var2_value_2}:<env:${common_env_var2_name}>

[${regular_pathenv_var_name_1}]
1\\path=${user_additional_pathenv_var_value_1_1}
2\\path=${user_additional_pathenv_var_value_1_2}
size=2

[${user_additional_pathenv_var_name_2}]
1\\path=${user_additional_pathenv_var_value_2_1}
2\\path=${user_additional_pathenv_var_value_2_2}
size=2

")

# --------------------------------------------------------------------------
# Configure additional settings file
set(additional_settings_path "${launcher}AdditionalLauncherSettings.ini")
set(additional_sys_env_var_name "CTKAPPLAUNCHER_TEST_ADDITIONAL_ENV_EXPRESSION")
set(additional_sys_env_var_value "Powder as in snow")
set(additional_env_var_name_1 "ADD_SOMETHING_NICE")
set(additional_env_var_value_1 "Chocolate :)")
set(additional_env_var_name_2 "ADD_SOMETHING_AWESOME")
set(additional_env_var_value_2 "Rock climbing ! :)")
set(additional_env_var_name_3 "ADD_SOMETHING_GREAT")
set(additional_env_var_value_3 "<env:${additional_sys_env_var_name}>")
set(additional_pathenv_var_value_1_1 "/farm/dog")
set(additional_pathenv_var_value_1_2 "/farm/duck")
set(additional_pathenv_var_value_2_1 "/user-farm/dog")
set(additional_pathenv_var_value_2_2 "/user-farm/duck")
set(additional_pathenv_var_name_3 "ADD_SOME_PATH")
set(additional_pathenv_var_value_3_1 "/additional-farm/dog")
set(additional_pathenv_var_value_3_2 "/additional-farm/duck")
set(additional_library_path "/path/to/additional/lib")
set(additional_path_1 "/home/additional/app1")
set(additional_path_2 "/home/additional/app2")
set(additional_path_3 "/home/additional/<env:${additional_sys_env_var_name}>")
set(common_env_var_value_3 "Sun")
set(common_env_var2_value_3 "Trees")

set(ENV{${additional_sys_env_var_name}} ${additional_sys_env_var_value})

file(WRITE ${additional_settings_path} "
[General]
additionalPathVariables=${additional_pathenv_var_name_3}

[LibraryPaths]
1\\path=${additional_library_path}
size=1

[Paths]
1\\path=${additional_path_1}
2\\path=${additional_path_2}
3\\path=${additional_path_3}
size=3

[EnvironmentVariables]
${additional_env_var_name_1}=${additional_env_var_value_1}
${additional_env_var_name_2}=${additional_env_var_value_2}
${additional_env_var_name_3}=${additional_env_var_value_3}
${common_env_var_name}=<env:${common_env_var_name}>:${common_env_var_value_3}
${common_env_var2_name}=${common_env_var2_value_3}:<env:${common_env_var2_name}>

[${regular_pathenv_var_name_1}]
1\\path=${additional_pathenv_var_value_1_1}
2\\path=${additional_pathenv_var_value_1_2}
size=2

[${user_additional_pathenv_var_name_2}]
1\\path=${additional_pathenv_var_value_2_1}
2\\path=${additional_pathenv_var_value_2_2}
size=2

[${additional_pathenv_var_name_3}]
1\\path=${additional_pathenv_var_value_3_1}
2\\path=${additional_pathenv_var_value_3_2}
size=2

")

# --------------------------------------------------------------------------
# Check if launcher works as expected

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
# Check if launcher works as expected
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

set(expected_pathenv_var_value_1
  "${additional_pathenv_var_value_1_1}${pathsep}${additional_pathenv_var_value_1_2}")
set(expected_pathenv_var_value_1
  "${expected_pathenv_var_value_1}${pathsep}${user_additional_pathenv_var_value_1_1}${pathsep}${user_additional_pathenv_var_value_1_2}")
set(expected_pathenv_var_value_1
  "${expected_pathenv_var_value_1}${pathsep}${regular_pathenv_var_value_1_1}${pathsep}${regular_pathenv_var_value_1_2}")

set(expected_pathenv_var_value_2
  "${additional_pathenv_var_value_2_1}${pathsep}${additional_pathenv_var_value_2_2}")
set(expected_pathenv_var_value_2
  "${expected_pathenv_var_value_2}${pathsep}${user_additional_pathenv_var_value_2_1}${pathsep}${user_additional_pathenv_var_value_2_2}")

set(expected_pathenv_var_value_3
  "${additional_pathenv_var_value_3_1}${pathsep}${additional_pathenv_var_value_3_2}")

set(expected_additional_path_3 "/home/additional/${additional_sys_env_var_value}")
set(expected_additional_env_var_value_3 ${additional_sys_env_var_value})
set(expected_user_additional_path_3 "/home/user-additional/${user_sys_env_var_value}")
set(expected_user_additional_env_var_value_3 ${user_sys_env_var_value})

set(expected_ov_lines
  "${user_additional_env_var_name_3}=${expected_user_additional_env_var_value_3}"
  "${user_additional_env_var_name_2}=${user_additional_env_var_value_2}"
  "${user_additional_env_var_name_1}=${user_additional_env_var_value_1}"
  "${additional_env_var_name_3}=${expected_additional_env_var_value_3}"
  "${additional_env_var_name_2}=${additional_env_var_value_2}"
  "${additional_env_var_name_1}=${additional_env_var_value_1}"
  "${library_path_variable_name}=${additional_library_path}${pathsep}${user_additional_library_path}${pathsep}${regular_library_path_1}${pathsep}${regular_library_path_2}"
  "PATH=${additional_path_1}${pathsep}${additional_path_2}${pathsep}${expected_additional_path_3}${pathsep}${user_additional_path_1}${pathsep}${user_additional_path_2}${pathsep}${expected_user_additional_path_3}${pathsep}${regular_path_1}${pathsep}${regular_path_2}"
  "${regular_env_var_name_2}=${regular_env_var_value_2}\n"
  "${regular_env_var_name_1}=${regular_env_var_value_1}\n"
  "${regular_pathenv_var_name_1}=${expected_pathenv_var_value_1}\n"
  "${user_additional_pathenv_var_name_2}=${expected_pathenv_var_value_2}\n"
  "${additional_pathenv_var_name_3}=${expected_pathenv_var_value_3}\n"
  "${common_env_var_name}=${common_env_var_value_1}:${common_env_var_value_2}:${common_env_var_value_3}\n"
  "${common_env_var2_name}=${common_env_var2_value_3}:${common_env_var2_value_2}:${common_env_var2_value_1}\n"
  )
if(WIN32)
  set(expected_ov_lines
    "${user_additional_env_var_name_3}=${expected_user_additional_env_var_value_3}"
    "${user_additional_env_var_name_2}=${user_additional_env_var_value_2}"
    "${user_additional_env_var_name_1}=${user_additional_env_var_value_1}"
    "${additional_env_var_name_3}=${expected_additional_env_var_value_3}"
    "${additional_env_var_name_2}=${additional_env_var_value_2}"
    "${additional_env_var_name_1}=${additional_env_var_value_1}"
    "PATH=${additional_path_1}${pathsep}${additional_path_2}${pathsep}${expected_additional_path_3}${pathsep}${user_additional_path_1}${pathsep}${user_additional_path_2}${pathsep}${expected_user_additional_path_3}${pathsep}${regular_path_1}${pathsep}${regular_path_2}${pathsep}${additional_library_path}${pathsep}${user_additional_library_path}${pathsep}${regular_library_path_1}${pathsep}${regular_library_path_2}"
    "${regular_env_var_name_2}=${regular_env_var_value_2}\n"
    "${regular_env_var_name_1}=${regular_env_var_value_1}\n"
    "${regular_pathenv_var_name_1}=${expected_pathenv_var_value_1}\n"
    "${user_additional_pathenv_var_name_2}=${expected_pathenv_var_value_2}\n"
    "${additional_pathenv_var_name_3}=${expected_pathenv_var_value_3}\n"
    "${common_env_var_name}=${common_env_var_value_1}:${common_env_var_value_2}:${common_env_var_value_3}\n"
    "${common_env_var2_name}=${common_env_var2_value_3}:${common_env_var2_value_2}:${common_env_var2_value_1}\n"
    )
endif()

foreach(expected_ov_line ${expected_ov_lines})
  string(FIND "${ov}" ${expected_ov_line} pos)
  if(${pos} STREQUAL -1)
    message(FATAL_ERROR "Problem with reading additional settings file - expected_ov_line:${expected_ov_line} "
                        "not found in current_ov:${ov}")
  endif()
endforeach()

# Clean
file(REMOVE ${user_additional_settings_path})
