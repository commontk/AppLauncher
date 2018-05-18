
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# Configure settings file in one of the recognized sub directory

set(launcher_settings_dir "${launcher_dir}/lib")
file(MAKE_DIRECTORY ${launcher_settings_dir})

file(WRITE "${launcher_settings_dir}/${launcher_name}LauncherSettings.ini" "
[LibraryPaths]
1\\path=${library_path}
size=1
  
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
set(launcher_arg "--launcher-dump-environment")
set(command ${launcher_exe} ${launcher_arg})
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


# Clean
file(REMOVE "${launcher_settings_dir}/${launcher_name}LauncherSettings.ini")
