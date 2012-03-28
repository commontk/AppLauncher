
#
# AppLauncherTest6
#

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

")

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# Test1 - Check if flag --launcher-additional-settings works as expected
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
  message(FATAL_ERROR "Test1 - [${launcher_exe}] failed to start from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

set(expected_ov "${additional_env_var_name_2}=${additional_env_var_value_2}
${additional_env_var_name_1}=${additional_env_var_value_1}
${library_path_variable_name}=${additional_library_path}${pathsep}${regular_library_path_1}${pathsep}${regular_library_path_2}${pathsep}
PATH=${additional_path_1}${pathsep}${additional_path_2}${pathsep}${regular_path_1}${pathsep}${regular_path_2}${pathsep}
${regular_env_var_name_2}=${regular_env_var_value_2}
${regular_env_var_name_1}=${regular_env_var_value_1}\n")
if(WIN32)
  set(expected_ov "${additional_env_var_name_2}=${additional_env_var_value_2}
${additional_env_var_name_1}=${additional_env_var_value_1}
PATH=${additional_path_1}${pathsep}${additional_path_2}${pathsep}${regular_path_1}${pathsep}${regular_path_2}${pathsep}${additional_library_path}${pathsep}${regular_library_path_1}${pathsep}${regular_library_path_2}${pathsep}
${regular_env_var_name_2}=${regular_env_var_value_2}
${regular_env_var_name_1}=${regular_env_var_value_1}\n")
endif()

if(NOT "${ov}" STREQUAL "${expected_ov}")
  message(FATAL_ERROR "Test3 - Problem with flag --launcher-additional-settings - expected_ov:${expected_ov} "
                      "current_ov:${ov}")
endif()

