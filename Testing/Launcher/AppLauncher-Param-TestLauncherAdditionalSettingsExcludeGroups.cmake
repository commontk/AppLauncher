
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
function(applauncher_test_launcher_additional_settings_exclude_groups_test_case
    testcase_id
    exclude_groups_commandline_arg
    exclude_groups_settings_value
    expected_settings_value
    )

  set(settings)
  if(NOT "${exclude_groups_settings_value}" STREQUAL "")
    set(settings "additionalSettingsExcludeGroups=${exclude_groups_settings_value}")
  endif()

  # Configure settings file
  file(WRITE "${launcher}LauncherSettings.ini" "
[General]
${settings}

[Application]
path=${application}

[LibraryPaths]
1\\path=${library_path}
size=1
")

  set(cmdarg)
  if(NOT "${exclude_groups_commandline_arg}" STREQUAL "")
    set(cmdarg "--launcher-additional-settings-exclude-groups" "${exclude_groups_commandline_arg}")
  endif()

  extract_application_settings_value("AdditionalSettingsExcludeGroups" current_settings_value ${cmdarg})

  if(NOT "${current_settings_value}" STREQUAL "${expected_settings_value}")
    message(FATAL_ERROR "TestCase: ${testcase_id}\n"
                        "expected_additional_settings_exclude_groups [${expected_settings_value}]\n"
                        "current_additional_settings_exclude_groups [${current_settings_value}]")
  endif()

endfunction()

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
applauncher_test_launcher_additional_settings_exclude_groups_test_case(
  "1" # testcase_id
  "" # exclude_groups_commandline_arg
  "" # exclude_groups_settings_value
  "" # expected_settings_value
  )

#
# With "--launcher-additional-settings-exclude-groups" only
#
applauncher_test_launcher_additional_settings_exclude_groups_test_case(
  "2" # testcase_id
  "" # exclude_groups_commandline_arg
  "General" # exclude_groups_settings_value
  "General" # expected_settings_value
  )

applauncher_test_launcher_additional_settings_exclude_groups_test_case(
  "3" # testcase_id
  "General,Application,Application" # exclude_groups_commandline_arg
  "" # exclude_groups_settings_value
  "General,Application,Application" # expected_settings_value
  )

applauncher_test_launcher_additional_settings_exclude_groups_test_case(
  "4" # testcase_id
  "General,Application,ExtraApplicationToLaunch,LibraryPaths,Paths,EnvironmentVariables" # exclude_groups_commandline_arg
  "" # exclude_groups_settings_value
  "General,Application,ExtraApplicationToLaunch,LibraryPaths,Paths,EnvironmentVariables" # expected_settings_value
  )

applauncher_test_launcher_additional_settings_exclude_groups_test_case(
  "5" # testcase_id
  "Invalid" # exclude_groups_commandline_arg
  "" # exclude_groups_settings_value
  "Invalid" # expected_settings_value
  )

#
# With settings key "additionalSettingsExcludeGroups" only
#

applauncher_test_launcher_additional_settings_exclude_groups_test_case(
  "6" # testcase_id
  "" # exclude_groups_commandline_arg
  "General" # exclude_groups_settings_value
  "General" # expected_settings_value
  )

applauncher_test_launcher_additional_settings_exclude_groups_test_case(
  "7" # testcase_id
  "" # exclude_groups_commandline_arg
  "General,Application,Application" # exclude_groups_settings_value
  "General,Application,Application" # expected_settings_value
  )

applauncher_test_launcher_additional_settings_exclude_groups_test_case(
  "8" # testcase_id
  "" # exclude_groups_commandline_arg
  "General,Application,ExtraApplicationToLaunch,LibraryPaths,Paths,EnvironmentVariables" # exclude_groups_settings_value
  "General,Application,ExtraApplicationToLaunch,LibraryPaths,Paths,EnvironmentVariables" # expected_settings_value
  )

#
# With both settings key "additionalSettingsExcludeGroups" and "--launcher-additional-settings-exclude-groups"
#

applauncher_test_launcher_additional_settings_exclude_groups_test_case(
  "9" # testcase_id
  "General,Application,ExtraApplicationToLaunch" # exclude_groups_commandline_arg
  "LibraryPaths,Paths,EnvironmentVariables" # exclude_groups_settings_value
  "General,Application,ExtraApplicationToLaunch" # expected_settings_value
  )
