include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Configure additional settings file used with "additionalSettingsFilePath" settings key
set(settingskey_additional_settings_path "${launcher}AdditionalLauncherSettingsForSettingsKey.ini")
set(settingskey_additional_env_var_name_1 "SETTINGSKEY_ADD_SOMETHING_NICE")
set(settingskey_additional_env_var_value_1 "Smoked Salmon")
set(settingskey_additional_env_var_name_2 "SETTINGSKEY_ENV_OVERWRITTEN_BY_CMDARG")
set(settingskey_additional_env_var_value_2 "SettingsKeyValue")

file(WRITE ${settingskey_additional_settings_path} "
[EnvironmentVariables]
${settingskey_additional_env_var_name_1}=${settingskey_additional_env_var_value_1}
${settingskey_additional_env_var_name_2}=${settingskey_additional_env_var_value_2}
")

# --------------------------------------------------------------------------
# Configure settings file
set(organization_domain "www.commontk-${TEST_TREE_TYPE}.org")
set(organization_name "Common ToolKit ${TEST_TREE_TYPE}")
set(application_name "AppLauncher")
set(application_revision "4810")
set(regular_library_path_1 ${library_path})
set(regular_library_path_2 "/path/to/regular/libtwo")
set(regular_library_path_3 "relative-path/to/regular/libthree")
set(regular_path_1 "/path/to/regular/stuff")
set(regular_path_2 "/path/to/regular/otherstuff")
set(regular_path_3 "relative-path/to/regular/otherstuff")
set(regular_env_var_name_1 "SOMETHING_NICE")
set(regular_env_var_value_1 "Chocolate")
set(regular_env_var_name_2 "SOMETHING_AWESOME")
set(regular_env_var_value_2 "Rock climbing !")
set(regular_pathenv_var_name_1 "SOME_PATH")
set(regular_pathenv_var_value_1_1 "/farm/cow")
set(regular_pathenv_var_value_1_2 "/farm/pig")
set(regular_pathenv_var_value_1_3 "relative-farm/pig")
set(common_env_var_name "SOMETHING_COMMON")
set(common_env_var_value_1 "Snow")
set(common_env_var2_name "ANOTHER_THING_COMMON")
set(common_env_var2_value_1 "Rocks")

file(WRITE "${launcher}LauncherSettings.ini" "
[General]
additionalSettingsFilePath=<APPLAUNCHER_SETTINGS_DIR>/${launcher_name}AdditionalLauncherSettingsForSettingsKey.ini

[Application]
path=${application}
organizationDomain=${organization_domain}
organizationName=${organization_name}
name=${application_name}
revision=${application_revision}

[LibraryPaths]
1\\path=${regular_library_path_1}
2\\path=${regular_library_path_2}
3\\path=${regular_library_path_3}
size=3

[Paths]
1\\path=${regular_path_1}
2\\path=${regular_path_2}
3\\path=${regular_path_3}
size=3

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
3\\path=${regular_pathenv_var_value_1_3}
size=3

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
set(user_additional_library_path_1 "/path/to/user-additional/lib")
set(user_additional_library_path_2 "relative-path/to/user-additional/lib")
set(user_additional_path_1 "/home/user-additional/app1")
set(user_additional_path_2 "/home/user-additional/app2")
set(user_additional_path_3 "/home/user-additional/<env:${user_sys_env_var_name}>")
set(user_additional_path_4 "relative-user-additional/app4")
set(user_common_env_var_value_2 "Recycle")
set(user_common_env_var2_value_2 "Energy")

set(ENV{${user_sys_env_var_name}} ${user_sys_env_var_value})

file(WRITE ${user_additional_settings_path} "
[LibraryPaths]
1\\path=${user_additional_library_path_1}
2\\path=${user_additional_library_path_2}
size=2

[Paths]
1\\path=${user_additional_path_1}
2\\path=${user_additional_path_2}
3\\path=${user_additional_path_3}
4\\path=${user_additional_path_4}
size=4

[Environment]
additionalPathVariables=${user_additional_pathenv_var_name_2}

[EnvironmentVariables]
${user_additional_env_var_name_1}=${user_additional_env_var_value_1}
${user_additional_env_var_name_2}=${user_additional_env_var_value_2}
${user_additional_env_var_name_3}=${user_additional_env_var_value_3}
${common_env_var_name}=<env:${common_env_var_name}>:${user_common_env_var_value_2}
${common_env_var2_name}=${user_common_env_var2_value_2}:<env:${common_env_var2_name}>

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
# Configure additional settings file used with "--launcher-additional-settings"
set(cmdarg_additional_settings_path "${launcher}AdditionalLauncherSettingsForCmdArg.ini")
set(cmdarg_additional_sys_env_var_name "CTKAPPLAUNCHER_TEST_ADDITIONAL_ENV_EXPRESSION")
set(cmdarg_additional_sys_env_var_value "Powder as in snow")
set(cmdarg_additional_env_var_name_1 "ADD_SOMETHING_NICE")
set(cmdarg_additional_env_var_value_1 "Chocolate :)")
set(cmdarg_additional_env_var_name_2 "ADD_SOMETHING_AWESOME")
set(cmdarg_additional_env_var_value_2 "Rock climbing ! :)")
set(cmdarg_additional_env_var_name_3 "ADD_SOMETHING_GREAT")
set(cmdarg_additional_env_var_value_3 "<env:${cmdarg_additional_sys_env_var_name}>")
set(cmdarg_additional_env_var_name_4 "SETTINGSKEY_ENV_OVERWRITTEN_BY_CMDARG")
set(cmdarg_additional_env_var_value_4 "CmdArgValue")
set(cmdarg_additional_pathenv_var_value_1_1 "/farm/dog")
set(cmdarg_additional_pathenv_var_value_1_2 "/farm/duck")
set(cmdarg_additional_pathenv_var_value_2_1 "/user-farm/dog")
set(cmdarg_additional_pathenv_var_value_2_2 "/user-farm/duck")
set(cmdarg_additional_pathenv_var_name_3 "ADD_SOME_PATH")
set(cmdarg_additional_pathenv_var_value_3_1 "/additional-farm/dog")
set(cmdarg_additional_pathenv_var_value_3_2 "/additional-farm/duck")
set(cmdarg_additional_library_path "/path/to/additional/lib")
set(cmdarg_additional_path_1 "/home/additional/app1")
set(cmdarg_additional_path_2 "/home/additional/app2")
set(cmdarg_additional_path_3 "/home/additional/<env:${cmdarg_additional_sys_env_var_name}>")
set(cmdarg_additional_common_env_var_value_3 "Sun")
set(cmdarg_additional_common_env_var2_value_3 "Trees")

set(ENV{${cmdarg_additional_sys_env_var_name}} ${cmdarg_additional_sys_env_var_value})

file(WRITE ${cmdarg_additional_settings_path} "
[LibraryPaths]
1\\path=${cmdarg_additional_library_path}
size=1

[Paths]
1\\path=${cmdarg_additional_path_1}
2\\path=${cmdarg_additional_path_2}
3\\path=${cmdarg_additional_path_3}
size=3

[Environment]
additionalPathVariables=${cmdarg_additional_pathenv_var_name_3}

[EnvironmentVariables]
${cmdarg_additional_env_var_name_1}=${cmdarg_additional_env_var_value_1}
${cmdarg_additional_env_var_name_2}=${cmdarg_additional_env_var_value_2}
${cmdarg_additional_env_var_name_3}=${cmdarg_additional_env_var_value_3}
${cmdarg_additional_env_var_name_4}=${cmdarg_additional_env_var_value_4}
${common_env_var_name}=<env:${common_env_var_name}>:${cmdarg_additional_common_env_var_value_3}
${common_env_var2_name}=${cmdarg_additional_common_env_var2_value_3}:<env:${common_env_var2_name}>

[${regular_pathenv_var_name_1}]
1\\path=${cmdarg_additional_pathenv_var_value_1_1}
2\\path=${cmdarg_additional_pathenv_var_value_1_2}
size=2

[${user_additional_pathenv_var_name_2}]
1\\path=${cmdarg_additional_pathenv_var_value_2_1}
2\\path=${cmdarg_additional_pathenv_var_value_2_2}
size=2

[${cmdarg_additional_pathenv_var_name_3}]
1\\path=${cmdarg_additional_pathenv_var_value_3_1}
2\\path=${cmdarg_additional_pathenv_var_value_3_2}
size=2

")

# --------------------------------------------------------------------------
# Check if launcher works as expected

set(command ${launcher_exe} --launcher-no-splash --launcher-additional-settings ${cmdarg_additional_settings_path})
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
# Based on the value of "TEST_ADDITIONAL_SETTINGS_EXCLUDE_GROUPS":
#
# (1) if empty, execute launcher with "--launcher-dump-environment" and "--launcher-additional-settings"
#     and check that setting are overwritten and/or expanded as expected.
#
# (2) if set to one or multiple groups, execute launcher with "--launcher-dump-environment", "--launcher-additional-settings"
#     and "--launcher-additional-settings-exclude-groups=${TEST_ADDITIONAL_SETTINGS_EXCLUDE_GROUPS}" and check
#
#

set(cmdarg_additional_settings_exclude_groups)
if(NOT "${TEST_ADDITIONAL_SETTINGS_EXCLUDE_GROUPS}" STREQUAL "")
  set(cmdarg_additional_settings_exclude_groups --launcher-additional-settings-exclude-groups "${TEST_ADDITIONAL_SETTINGS_EXCLUDE_GROUPS}")
endif()

set(command ${launcher_exe} --launcher-no-splash --launcher-dump-environment --launcher-additional-settings ${cmdarg_additional_settings_path} ${cmdarg_additional_settings_exclude_groups})
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


if("${TEST_ADDITIONAL_SETTINGS_EXCLUDE_GROUPS}" STREQUAL "" OR
    "${TEST_ADDITIONAL_SETTINGS_EXCLUDE_GROUPS}" STREQUAL "General")
  set(with_additional_pathenv_var 1)
  set(with_additional_env_var 1)
  set(with_additional_path_librarypath 1)
elseif("${TEST_ADDITIONAL_SETTINGS_EXCLUDE_GROUPS}" STREQUAL "General,Environment")
  set(with_additional_pathenv_var 0)
  set(with_additional_env_var 1)
  set(with_additional_path_librarypath 1)
elseif("${TEST_ADDITIONAL_SETTINGS_EXCLUDE_GROUPS}" STREQUAL "General,Environment,EnvironmentVariables")
  set(with_additional_pathenv_var 0)
  set(with_additional_env_var 0)
  set(with_additional_path_librarypath 1)
elseif("${TEST_ADDITIONAL_SETTINGS_EXCLUDE_GROUPS}" STREQUAL "General,Environment,EnvironmentVariables,Paths,LibraryPaths")
  set(with_additional_pathenv_var 0)
  set(with_additional_env_var 0)
  set(with_additional_path_librarypath 0)
endif()

#
# Set ivars used afterward to set "expected_*_lines" and "unexpected_*_lines" variables.
#

set(expected_regular_pathenv_var_value_1_3 "${launcher_dir}/${regular_pathenv_var_value_1_3}")

if(with_additional_pathenv_var)
  set(expected_pathenv_var_value_1
    "${cmdarg_additional_pathenv_var_value_1_1}${pathsep}${cmdarg_additional_pathenv_var_value_1_2}")
  set(expected_pathenv_var_value_1
    "${expected_pathenv_var_value_1}${pathsep}${user_additional_pathenv_var_value_1_1}${pathsep}${user_additional_pathenv_var_value_1_2}")
  set(expected_pathenv_var_value_1
    "${expected_pathenv_var_value_1}${pathsep}${regular_pathenv_var_value_1_1}${pathsep}${regular_pathenv_var_value_1_2}${pathsep}${expected_regular_pathenv_var_value_1_3}")
else()
  set(expected_pathenv_var_value_1 "${regular_pathenv_var_value_1_1}${pathsep}${regular_pathenv_var_value_1_2}${pathsep}${expected_regular_pathenv_var_value_1_3}")
endif()

if(with_additional_env_var)
  set(expected_common_env_var_value "${common_env_var_value_1}:${user_common_env_var_value_2}:${cmdarg_additional_common_env_var_value_3}")
  set(expected_common_env_var2_value "${cmdarg_additional_common_env_var2_value_3}:${user_common_env_var2_value_2}:${common_env_var2_value_1}")
else()
  set(expected_common_env_var_value "${common_env_var_value_1}")
  set(expected_common_env_var2_value "${common_env_var2_value_1}")
endif()

set(expected_pathenv_var_value_2
  "${cmdarg_additional_pathenv_var_value_2_1}${pathsep}${cmdarg_additional_pathenv_var_value_2_2}")
set(expected_pathenv_var_value_2
  "${expected_pathenv_var_value_2}${pathsep}${user_additional_pathenv_var_value_2_1}${pathsep}${user_additional_pathenv_var_value_2_2}")

set(expected_pathenv_var_value_3
  "${cmdarg_additional_pathenv_var_value_3_1}${pathsep}${cmdarg_additional_pathenv_var_value_3_2}")

set(expected_additional_path_3 "/home/additional/${cmdarg_additional_sys_env_var_value}")
set(expected_additional_env_var_value_3 ${cmdarg_additional_sys_env_var_value})
set(expected_user_additional_path_3 "/home/user-additional/${user_sys_env_var_value}")
set(expected_user_additional_env_var_value_3 ${user_sys_env_var_value})

set(expected_regular_library_path_3 "${launcher_dir}/${regular_library_path_3}")
set(expected_regular_path_3 "${launcher_dir}/${regular_path_3}")
set(expected_user_additional_library_path_2 "${launcher_dir}/${user_additional_library_path_2}")
set(expected_user_additional_path_4 "${launcher_dir}/${user_additional_path_4}")

if(with_additional_path_librarypath)
  if(WIN32)
    set(expected_library_path_env)
    set(expected_path_env "Path=${cmdarg_additional_path_1}${pathsep}${cmdarg_additional_path_2}${pathsep}${expected_additional_path_3}${pathsep}${user_additional_path_1}${pathsep}${user_additional_path_2}${pathsep}${expected_user_additional_path_3}${pathsep}${expected_user_additional_path_4}${pathsep}${regular_path_1}${pathsep}${regular_path_2}${pathsep}${pathsep}${expected_regular_path_3}${additional_library_path}${pathsep}${user_additional_library_path_1}${pathsep}${expected_user_additional_library_path_2}${pathsep}${regular_library_path_1}${pathsep}${regular_library_path_2}${pathsep}${expected_regular_library_path_3}")
  else()
    set(expected_library_path_env "${library_path_variable_name}=${cmdarg_additional_library_path}${pathsep}${user_additional_library_path_1}${pathsep}${expected_user_additional_library_path_2}${pathsep}${regular_library_path_1}${pathsep}${regular_library_path_2}${pathsep}${expected_regular_library_path_3}")
    set(expected_path_env "PATH=${cmdarg_additional_path_1}${pathsep}${cmdarg_additional_path_2}${pathsep}${expected_additional_path_3}${pathsep}${user_additional_path_1}${pathsep}${user_additional_path_2}${pathsep}${expected_user_additional_path_3}${pathsep}${expected_user_additional_path_4}${pathsep}${regular_path_1}${pathsep}${regular_path_2}${pathsep}${expected_regular_path_3}")
  endif()
else()
  if(WIN32)
    set(expected_library_path_env)
    set(expected_path_env "Path=${regular_path_1}${pathsep}${regular_path_2}${pathsep}${expected_regular_path_3}${pathsep}${regular_library_path_1}${pathsep}${regular_library_path_2}${pathsep}${expected_regular_library_path_3}")
  else()
    set(expected_library_path_env "${library_path_variable_name}=${regular_library_path_1}${pathsep}${regular_library_path_2}${pathsep}${expected_regular_library_path_3}")
    set(expected_path_env "PATH=${regular_path_1}${pathsep}${regular_path_2}${pathsep}${expected_regular_path_3}")
  endif()
endif()

#
# Output lines expected independently of "AdditionalSettingsExcludeGroups" value
#

set(expected_env_var_lines
  "${regular_env_var_name_2}=${regular_env_var_value_2}\n"
  "${regular_env_var_name_1}=${regular_env_var_value_1}\n"
  )

set(expected_pathenv_var_lines
  "${regular_pathenv_var_name_1}=${expected_pathenv_var_value_1}\n"
  )

set(expected_common_env_var_lines
  "${common_env_var_name}=${expected_common_env_var_value}\n"
  "${common_env_var2_name}=${expected_common_env_var2_value}\n"
  )

#
# Output lines expected without excluding any settings group
#

set(expected_additional_env_var_lines_without_group_exclude
  "${user_additional_env_var_name_3}=${expected_user_additional_env_var_value_3}"
  "${user_additional_env_var_name_2}=${user_additional_env_var_value_2}"
  "${user_additional_env_var_name_1}=${user_additional_env_var_value_1}"
  "${cmdarg_additional_env_var_name_4}=${cmdarg_additional_env_var_value_4}"
  "${cmdarg_additional_env_var_name_3}=${expected_additional_env_var_value_3}"
  "${cmdarg_additional_env_var_name_2}=${cmdarg_additional_env_var_value_2}"
  "${cmdarg_additional_env_var_name_1}=${cmdarg_additional_env_var_value_1}"
  "${settingskey_additional_env_var_name_1}=${settingskey_additional_env_var_value_1}"
  )

set(expected_additional_pathenv_var_lines_without_group_exclude
  "${user_additional_pathenv_var_name_2}=${expected_pathenv_var_value_2}\n"
  "${cmdarg_additional_pathenv_var_name_3}=${expected_pathenv_var_value_3}\n"
  )

#
# Set "expected_ov_lines" and "unexpected_ov_lines" list based on the
# current test case.
#

set(expected_ov_lines
  ${expected_env_var_lines}
  ${expected_pathenv_var_lines}
  ${expected_common_env_var_lines}
  ${expected_library_path_env}
  ${expected_path_env}
  )

set(unexpected_ov_lines)

if("${TEST_ADDITIONAL_SETTINGS_EXCLUDE_GROUPS}" STREQUAL "" OR
    "${TEST_ADDITIONAL_SETTINGS_EXCLUDE_GROUPS}" STREQUAL "General")
  list(APPEND expected_ov_lines
    ${expected_additional_env_var_lines_without_group_exclude}
    ${expected_additional_pathenv_var_lines_without_group_exclude}
    )
elseif("${TEST_ADDITIONAL_SETTINGS_EXCLUDE_GROUPS}" STREQUAL "General,Environment")
  list(APPEND expected_ov_lines
    ${expected_additional_env_var_lines_without_group_exclude}
    )
  list(APPEND unexpected_ov_lines
    ${expected_additional_pathenv_var_lines_without_group_exclude}
    )
elseif("${TEST_ADDITIONAL_SETTINGS_EXCLUDE_GROUPS}" STREQUAL "General,Environment,EnvironmentVariables")
  list(APPEND expected_ov_lines
    )
  list(APPEND unexpected_ov_lines
    ${expected_additional_env_var_lines_without_group_exclude}
    ${expected_additional_pathenv_var_lines_without_group_exclude}
    )
elseif("${TEST_ADDITIONAL_SETTINGS_EXCLUDE_GROUPS}" STREQUAL "General,Environment,EnvironmentVariables,Paths,LibraryPaths")
  list(APPEND expected_ov_lines
    )
  list(APPEND unexpected_ov_lines
    ${expected_additional_env_var_lines_without_group_exclude}
    ${expected_additional_pathenv_var_lines_without_group_exclude}
    )
endif()

foreach(expected_ov_line ${expected_ov_lines})
  check_expected_string("${ov}" "${expected_ov_line}" "reading additional settings file")
endforeach()

foreach(unexpected_ov_line ${unexpected_ov_lines})
  check_unexpected_string("${ov}" "${unexpected_ov_line}" "reading additional settings file")
endforeach()


# Clean
file(REMOVE ${user_additional_settings_path})
file(REMOVE ${cmdarg_additional_settings_path})
