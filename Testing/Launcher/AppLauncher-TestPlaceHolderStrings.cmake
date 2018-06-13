
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# Configure settings file in one of the recognized sub directory

set(launcher_settings_dir "${launcher_dir}/lib")
file(MAKE_DIRECTORY ${launcher_settings_dir})

set(organization_domain "www.commontk-${TEST_TREE_TYPE}.org")
set(organization_name "Common ToolKit ${TEST_TREE_TYPE}")
set(application_name "AppLauncher")

file(WRITE "${launcher_settings_dir}/${launcher_name}LauncherSettings.ini" "
[Application]
organizationDomain=${organization_domain}
organizationName=${organization_name}
name=${application_name}
  
[EnvironmentVariables]
TEST_APPLAUNCHER_DIR=<APPLAUNCHER_DIR>/cat
TEST_APPLAUNCHER_SETTINGS_DIR=<APPLAUNCHER_SETTINGS_DIR>/bob
")

# --------------------------------------------------------------------------
extract_application_settings_value("LauncherDir" current_launcher_dir)
if(NOT "${current_launcher_dir}" STREQUAL "${launcher_dir}")
  message(FATAL_ERROR "Problem with LauncherDir.
  current : ${current_launcher_dir}
  expected: ${launcher_dir}
")
endif()

extract_application_settings_value("SettingsDir" current_launcher_settings_dir)
if(NOT "${current_launcher_settings_dir}" STREQUAL "${launcher_settings_dir}")
  message(FATAL_ERROR "Problem with SettingsDir.
  current : ${current_launcher_settings_dir}
  expected: ${launcher_settings_dir}
")
endif()


# --------------------------------------------------------------------------
# Extract application settings directory
extract_application_settings_value("UserAdditionalSettingsDir" user_additional_settings_dir)
set(user_additional_settings_path "${user_additional_settings_dir}/${application_name}.ini")

# Configure user additional settings file
file(WRITE ${user_additional_settings_path} "
[EnvironmentVariables]
TEST_APPLAUNCHER_DIR_FROM_USER_ADDITIONAL_SETTINGS=<APPLAUNCHER_DIR>/cat-from-user-additional-settings
TEST_APPLAUNCHER_SETTINGS_DIR_FROM_USER_ADDITIONAL_SETTINGS=<APPLAUNCHER_SETTINGS_DIR>/bob-from-user-additional-settings
")

# --------------------------------------------------------------------------
# Configure explicit additional settings file
set(additional_settings_dir "${launcher_dir}/additionalsettings")
file(MAKE_DIRECTORY "${additional_settings_dir}")
set(additional_settings_path "${additional_settings_dir}/${launcher_name}AdditionalLauncherSettings.ini")
file(WRITE ${additional_settings_path} "
[EnvironmentVariables]
TEST_APPLAUNCHER_DIR_FROM_ADDITIONAL_SETTINGS=<APPLAUNCHER_DIR>/cat-from-additional-settings
TEST_APPLAUNCHER_SETTINGS_DIR_FROM_ADDITIONAL_SETTINGS=<APPLAUNCHER_SETTINGS_DIR>/bob-from-additional-settings
")

# --------------------------------------------------------------------------
set(launcher_args "--launcher-dump-environment" "--launcher-additional-settings" "${additional_settings_path}")
set(command ${launcher_exe} ${launcher_args})
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_dir}
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "[${launcher_exe}] failed to start application [${application}] from "
                      "directory [${launcher_dir}]\n${ev}")
endif()

check_expected_string("${ov}" "TEST_APPLAUNCHER_DIR=${launcher_dir}/cat" "<APPLAUNCHER_DIR> placeholder")
check_expected_string("${ov}" "TEST_APPLAUNCHER_SETTINGS_DIR=${launcher_settings_dir}/bob" "<APPLAUNCHER_SETTINGS_DIR> placeholder")

check_expected_string("${ov}" "TEST_APPLAUNCHER_DIR_FROM_USER_ADDITIONAL_SETTINGS=${launcher_dir}/cat-from-user-additional-settings" "<APPLAUNCHER_DIR> placeholder")
check_expected_string("${ov}" "TEST_APPLAUNCHER_SETTINGS_DIR_FROM_USER_ADDITIONAL_SETTINGS=${user_additional_settings_dir}/bob-from-user-additional-settings" "<APPLAUNCHER_SETTINGS_DIR> placeholder")

check_expected_string("${ov}" "TEST_APPLAUNCHER_DIR_FROM_ADDITIONAL_SETTINGS=${launcher_dir}/cat-from-additional-settings" "<APPLAUNCHER_DIR> placeholder")
check_expected_string("${ov}" "TEST_APPLAUNCHER_SETTINGS_DIR_FROM_ADDITIONAL_SETTINGS=${additional_settings_dir}/bob-from-additional-settings" "<APPLAUNCHER_SETTINGS_DIR> placeholder")

# Clean
file(REMOVE "${launcher_settings_dir}/${launcher_name}LauncherSettings.ini")
file(REMOVE "${user_additional_settings_path}")
file(REMOVE "${additional_settings_path}")
