
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

set(organization_domain "www.commontk-${TEST_TREE_TYPE}.org")
set(organization_name "Common ToolKit ${TEST_TREE_TYPE}")
set(application_name "AppLauncher")
set(application_revision "4810")

# --------------------------------------------------------------------------
# Configure settings file

set(regular_library_path_1 ${library_path})
file(WRITE "${launcher}LauncherSettings.ini" "
[Application]
path=${application}
organizationDomain=${organization_domain}
organizationName=${organization_name}
name=${application_name}
revision=${application_revision}

[LibraryPaths]
1\\path=${regular_library_path_1}
size=1

")

# --------------------------------------------------------------------------
# Extract application settings directory

extract_application_settings_value("AdditionalSettingsDir" additional_settings_dir)
set(additional_settings_path "${additional_settings_dir}/${application_name}-${application_revision}.ini")

# --------------------------------------------------------------------------
# Configure user additional settings file
set(additional_env_var_name_1 "USER_ADD_SOMETHING_NICE")
set(additional_env_var_value_1 "Chocolate :)")

file(WRITE ${additional_settings_path} "
[EnvironmentVariables]
${additional_env_var_name_1}=${additional_env_var_value_1}

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
# Check that additional user settings are considered

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
  "${additional_env_var_name_1}=${additional_env_var_value_1}"
  )

foreach(expected_ov_line ${expected_ov_lines})
  string(FIND "${ov}" ${expected_ov_line} pos)
  if(${pos} STREQUAL -1)
    message(FATAL_ERROR "Problem with reading additional settings file - expected_ov_line:${expected_ov_line} "
                        "not found in current_ov:${ov}")
  endif()
endforeach()

# --------------------------------------------------------------------------
# Check that additional user settings are ignored

set(command ${launcher_exe} --launcher-no-splash --launcher-dump-environment --launcher-ignore-user-additional-settings)
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

set(unexpected_ov_lines
  "${additional_env_var_name_1}=${additional_env_var_value_1}"
  )

foreach(unexpected_ov_line ${unexpected_ov_lines})
  string(FIND "${ov}" ${unexpected_ov_line} pos)
  if(NOT ${pos} STREQUAL -1)
    message(FATAL_ERROR "Problem with reading additional settings file - unexpected_ov_line:${unexpected_ov_line} "
                        "found in current_ov:${ov}")
  endif()
endforeach()

# Clean
file(REMOVE ${additional_settings_path})
