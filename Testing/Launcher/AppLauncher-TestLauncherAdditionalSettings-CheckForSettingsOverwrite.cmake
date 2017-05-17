
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)


function(applauncher_test_launcher_overwrite_settings_test_case
  testcase_id

  LauncherSplashScreenHideDelayMs
  user_additional_LauncherSplashScreenHideDelayMs
  additional_LauncherSplashScreenHideDelayMs
  expected_LauncherSplashScreenHideDelayMs

  LauncherSplashImagePath
  user_additional_LauncherSplashImagePath
  additional_LauncherSplashImagePath
  expected_LauncherSplashImagePath

  UserAdditionalSettingsFileBaseName
  user_additional_UserAdditionalSettingsFileBaseName
  additional_UserAdditionalSettingsFileBaseName
  expected_UserAdditionalSettingsFileBaseName

  AdditionalLauncherHelpShortArgument
  user_additional_AdditionalLauncherHelpShortArgument
  additional_AdditionalLauncherHelpShortArgumenth
  expected_AdditionalLauncherHelpShortArgument

  AdditionalLauncherHelpLongArgument
  user_additional_AdditionalLauncherHelpLongArgument
  additional_AdditionalLauncherHelpLongArgument
  expected_AdditionalLauncherHelpLongArgument

  AdditionalLauncherNoSplashArguments
  user_additional_AdditionalLauncherNoSplashArguments
  additional_AdditionalLauncherNoSplashArguments
  expected_AdditionalLauncherNoSplashArguments
  )

  foreach(setting
    LauncherSplashScreenHideDelayMs
    LauncherSplashImagePath
    UserAdditionalSettingsFileBaseName
    AdditionalLauncherHelpShortArgument
    AdditionalLauncherHelpLongArgument
    AdditionalLauncherNoSplashArguments
    )

    if(NOT ${setting} STREQUAL "NA")
      set(${setting}_set "${setting}=${${setting}}")
    endif()
    if(NOT additional_${setting} STREQUAL "NA")
      set(additional_${setting}_set "${setting}=${additional_${setting}}")
    endif()
    if(NOT user_additional_${setting} STREQUAL "NA")
      set(user_additional_${setting}_set "${setting}=${user_additional_${setting}}")
    endif()

  endforeach()

  # Configure settings file
  set(organization_domain "www.commontk-${TEST_TREE_TYPE}.org")
  set(organization_name "Common ToolKit ${TEST_TREE_TYPE}")
  set(application_name "AppLauncher")
  set(application_revision "4810")
  set(launcherSplashScreenHideDelayMs "1")
  file(WRITE "${launcher}LauncherSettings.ini" "
[General]
${LauncherSplashScreenHideDelayMs_set}
${LauncherSplashImagePath_set}
${UserAdditionalSettingsFileBaseName_set}
${AdditionalLauncherHelpShortArgument_set}
${AdditionalLauncherHelpLongArgument_set}
${AdditionalLauncherNoSplashArguments_set}

[Application]
path=${application}
organizationDomain=${organization_domain}
organizationName=${organization_name}
name=${application_name}
revision=${application_revision}

[LibraryPaths]
1\\path=${library_path}
size=1
")

  # Extract application settings directory
  extract_application_settings_value("AdditionalSettingsDir" user_additional_settings_dir)
  set(user_additional_settings_path "${user_additional_settings_dir}/${application_name}${UserAdditionalSettingsFileBaseName}-${application_revision}.ini")

  # Configure user additional settings file
  file(WRITE ${user_additional_settings_path} "
[General]
${user_additional_LauncherSplashScreenHideDelayMs_set}
${user_additional_LauncherSplashImagePath_set}
${user_additional_UserAdditionalSettingsFileBaseName_set}
${user_additional_AdditionalLauncherHelpShortArgument_set}
${user_additional_AdditionalLauncherHelpLongArgument_set}
${user_additional_AdditionalLauncherNoSplashArguments_set}
")

  # Configure additional settings file
  set(additional_settings_path "${launcher}AdditionalLauncherSettings.ini")
  file(WRITE ${additional_settings_path} "
[General]
${additional_LauncherSplashScreenHideDelayMs_set}
${additional_LauncherSplashImagePath_set}
${additional_UserAdditionalSettingsFileBaseName_set}
${additional_AdditionalLauncherHelpShortArgument_set}
${additional_AdditionalLauncherHelpLongArgument_set}
${additional_AdditionalLauncherNoSplashArguments_set}
")

  # Check if launcher works as expected
  foreach(setting LauncherSplashScreenHideDelayMs LauncherSplashImagePath)

    extract_application_settings_value("${setting}" current_${setting} --launcher-additional-settings ${additional_settings_path})
    if(NOT ${current_${setting}} STREQUAL ${expected_${setting}})
      message(FATAL_ERROR "TestCase: ${testcase_id}\n"
                          "expected_${setting} [${expected_${setting}}]\n"
                          "current_${setting} [${current_${setting}}]")
    endif()

  endforeach()

  # Clean
  file(REMOVE ${user_additional_settings_path})
endfunction()

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

applauncher_test_launcher_overwrite_settings_test_case(
  "1" # testcase_id
  "1" "2" "3" "3" # LauncherSplashScreenHideDelayMs
  "/home/path/image1.png" "/home/path/image2.png" "/home/path/image3.png" "/home/path/image3.png" # LauncherSplashImagePath
  "Foo1Settings" "Foo2Settings" "Foo3Settings" "Foo1Settings" # UserAdditionalSettingsFileBaseName
  "-h1" "-h2" "-h3" "-h3" # AdditionalLauncherHelpShortArgument
  "--help1" "--help2" "--help3" "--help3" # AdditionalLauncherHelpLongArgument
  "--foo1,-b1" "--foo2,-b2" "--foo3,-b3" "--foo3,-b3" # AdditionalLauncherNoSplashArguments
  )

applauncher_test_launcher_overwrite_settings_test_case(
  "2" # testcase_id
  "1" "2" "NA" "2" # LauncherSplashScreenHideDelayMs
  "/home/path/image1.png" "/home/path/image2.png" "NA" "/home/path/image2.png" # LauncherSplashImagePath
  "Foo1Settings" "Foo2Settings" "NA" "Foo1Settings" # UserAdditionalSettingsFileBaseName
  "-h1" "-h2" "NA" "-h2" # AdditionalLauncherHelpShortArgument
  "--help1" "--help2" "NA" "--help2" # AdditionalLauncherHelpLongArgument
  "--foo1,-b1" "--foo2,-b2" "NA" "--foo2,-b2" # AdditionalLauncherNoSplashArguments
  )

applauncher_test_launcher_overwrite_settings_test_case(
  "3" # testcase_id
  "1" "NA" "NA" "1" # LauncherSplashScreenHideDelayMs
  "/home/path/image1.png" "NA" "NA" "/home/path/image1.png" # LauncherSplashImagePath
  "Foo1Settings" "NA" "NA" "Foo1Settings" # UserAdditionalSettingsFileBaseName
  "-h1" "NA" "NA" "-h1" # AdditionalLauncherHelpShortArgument
  "--help1" "NA" "NA" "--help1" # AdditionalLauncherHelpLongArgument
  "--foo1,-b1" "NA" "NA" "--foo1,-b1" # AdditionalLauncherNoSplashArguments
  )

applauncher_test_launcher_overwrite_settings_test_case(
  "4" # testcase_id
  "NA" "NA" "NA" "800" # LauncherSplashScreenHideDelayMs
  "NA" "NA" "NA" ":Images/ctk-splash.png" # LauncherSplashImagePath
  "NA" "NA" "NA" "AdditionalLauncherSettings" # UserAdditionalSettingsFileBaseName
  "NA" "NA" "NA" "" # AdditionalLauncherHelpShortArgument
  "NA" "NA" "NA" "" # AdditionalLauncherHelpLongArgument
  "NA" "NA" "NA" "" # AdditionalLauncherNoSplashArguments
  )

applauncher_test_launcher_overwrite_settings_test_case(
  "1" # testcase_id
  "1" "2" "3" "3" # LauncherSplashScreenHideDelayMs
  "/home/path/image1.png" "/home/path/image2.png" "/home/path/image3.png" "/home/path/image3.png" # LauncherSplashImagePath
  "Foo1Settings" "Foo2Settings" "Foo3Settings" "Foo3Settings" # UserAdditionalSettingsFileBaseName
  "-h1" "-h2" "-h3" "-h3" # AdditionalLauncherHelpShortArgument
  "--help1" "--help2" "--help3" "--help3" # AdditionalLauncherHelpLongArgument
  "--foo1,-b1" "--foo2,-b2" "--foo3,-b3" "--foo3,-b3" # AdditionalLauncherNoSplashArguments
  )
