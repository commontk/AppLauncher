
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Configure settings file
set(organization_domain "www.commontk-${TEST_TREE_TYPE}.org")
set(organization_name "Common ToolKit ${TEST_TREE_TYPE}")
set(application_name "AppLauncher")
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
organizationDomain=${organization_domain}
organizationName=${organization_name}
name=${application_name}

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
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# Extract application settings directory

extract_application_settings_value("AdditionalSettingsDir" additional_settings_dir)
set(additional_settings_path "${additional_settings_dir}/${application_name}.ini")

# --------------------------------------------------------------------------
# Configure user additional settings file
set(additional_library_path "/path/to/user-without-revision-additional/lib")
set(additional_path_1 "/home/user-without-revision-additional/app1")
set(additional_path_2 "/home/user-without-revision-additional/app2")
set(additional_env_var_name_1 "USER_WITHOUT_REVISION_ADD_SOMETHING_NICE")
set(additional_env_var_value_1 "Chocolate :)")
set(additional_env_var_name_2 "USER_WITHOUT_REVISION_ADD_SOMETHING_AWESOME")
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
    "PATH=${additional_path_1}${pathsep}${additional_path_2}${pathsep}${regular_path_1}${pathsep}${regular_path_2}${pathsep}${additional_library_path}${pathsep}${regular_library_path_1}${pathsep}${regular_library_path_2}"
    "${regular_env_var_name_2}=${regular_env_var_value_2}\n"
    "${regular_env_var_name_1}=${regular_env_var_value_1}\n"
    "${common_env_var_name}=${common_env_var_value_1}:${common_env_var_value_2}\n"
    "${common_env_var2_name}=${common_env_var2_value_2}:${common_env_var2_value_1}\n"
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
file(REMOVE ${additional_settings_path})
