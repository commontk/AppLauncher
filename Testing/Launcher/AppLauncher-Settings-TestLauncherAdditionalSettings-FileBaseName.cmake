
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

set(organization_domain "www.commontk-${TEST_TREE_TYPE}.org")
set(organization_name "Common ToolKit ${TEST_TREE_TYPE}")
set(application_name "AppLauncher")
set(application_revision "4810")

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# Configure settings file

file(WRITE "${launcher}LauncherSettings.ini" "
[Application]
organizationDomain=${organization_domain}
organizationName=${organization_name}
name=${application_name}
revision=${application_revision}
")

# --------------------------------------------------------------------------
# Extract application settings directory

extract_application_settings_value("AdditionalSettingsDir" additional_settings_dir)

# --------------------------------------------------------------------------
# Create user additional settings
set(expected_additional_settings_path "${additional_settings_dir}/${application_name}-${application_revision}.ini")
file(WRITE ${expected_additional_settings_path} "")

# Ask the launcher if it could located the file
extract_application_settings_value("AdditionalSettingsFileName" additional_settings_path)
if(NOT ${expected_additional_settings_path} STREQUAL ${additional_settings_path})
  message(FATAL_ERROR "[${launcher_exe}] failed to lookup additional settings: [${expected_additional_settings_path}]")
endif()

# Clean
file(REMOVE ${expected_additional_settings_path})

# --------------------------------------------------------------------------
# Configure settings file

set(expectedUserAdditionalSettingsFileBaseName "FooBar")

file(WRITE "${launcher}LauncherSettings.ini" "
[General]
userAdditionalSettingsFileBaseName=${expectedUserAdditionalSettingsFileBaseName}

[Application]
organizationDomain=${organization_domain}
organizationName=${organization_name}
name=${application_name}
revision=${application_revision}
")

# Create user additional settings
set(expected_additional_settings_path "${additional_settings_dir}/${application_name}${expectedUserAdditionalSettingsFileBaseName}-${application_revision}.ini")
file(WRITE ${expected_additional_settings_path} "")

# Ask the launcher if it could located the file
extract_application_settings_value("AdditionalSettingsFileName" additional_settings_path)
if(NOT ${expected_additional_settings_path} STREQUAL ${additional_settings_path})
  message(FATAL_ERROR "[${launcher_exe}] failed to lookup additional settings: [${expected_additional_settings_path}]")
endif()

# Clean
file(REMOVE ${expected_additional_settings_path})

# --------------------------------------------------------------------------
# Configure settings file

set(expectedUserAdditionalSettingsFileBaseName "")

file(WRITE "${launcher}LauncherSettings.ini" "
[General]
userAdditionalSettingsFileBaseName=${expectedUserAdditionalSettingsFileBaseName}

[Application]
organizationDomain=${organization_domain}
organizationName=${organization_name}
name=${application_name}
revision=${application_revision}
")

# Create user additional settings
set(expected_additional_settings_path "${additional_settings_dir}/${application_name}${expectedUserAdditionalSettingsFileBaseName}-${application_revision}.ini")
file(WRITE ${expected_additional_settings_path} "")

# Ask the launcher if it could located the file
extract_application_settings_value("AdditionalSettingsFileName" additional_settings_path)
if(NOT ${expected_additional_settings_path} STREQUAL ${additional_settings_path})
  message(FATAL_ERROR "[${launcher_exe}] failed to lookup additional settings: [${expected_additional_settings_path}]")
endif()

# Clean
file(REMOVE ${expected_additional_settings_path})
