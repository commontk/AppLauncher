
#
# AppLauncherTest3
#

include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# Attempt to start launcher from its directory
# Since there is no setting file and no parameter are given to the launcher,
# we expect it to fail with the following message:
set(expected_error_msg "error: Application does NOT exists []
error: --launch argument has NOT been specified
error: Launcher setting file [${launcher_name}LauncherSettings.ini] does NOT exist in any of these directories:
${launcher_dir}/.
${launcher_dir}/bin
${launcher_dir}/lib
${expected_help_text}")

set(command ${launcher_exe} --launcher-no-splash)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_dir}
  ERROR_VARIABLE ev
  ERROR_STRIP_TRAILING_WHITESPACE
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(NOT ${ev} STREQUAL ${expected_error_msg})
  message(FATAL_ERROR "Test1 - Since ${launcher_name} was started without any setting file or "
                      " parameter, it should have failed to start.")
endif()

# --------------------------------------------------------------------------
# Configure settings file
file(WRITE "${launcher}LauncherSettings.ini" "
[LibraryPaths]
1\\path=${library_path}
size=1
")

# --------------------------------------------------------------------------
# Attempt to start launcher from its directory
# Since no application to launch has been specified - An error message is expected ...
set(command ${launcher_exe} --launcher-no-splash --launch)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_dir}
  ERROR_VARIABLE ev
  OUTPUT_QUIET
  ERROR_STRIP_TRAILING_WHITESPACE
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

set(expected_error_msg "Error\n  Argument --launch has 0 value(s) associated whereas exacly 1 are expected.\n${expected_help_text}")
if(NOT ${ev} STREQUAL ${expected_error_msg})
  message(FATAL_ERROR "Test2 - \nexpected_error_msg[${expected_error_msg}]\ncurrent[${ev}]")
endif()

# --------------------------------------------------------------------------
# Attempt to start launcher from its directory
set(command ${launcher} --launcher-no-splash --launch ${application} --print-current-working-directory)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_dir}
  ERROR_VARIABLE ev
  ERROR_STRIP_TRAILING_WHITESPACE
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Test3 - [${launcher_exe}] failed to start application [${application}] from "
                      "directory [${launcher_dir}]\n${ev}")
endif()

set(expected_msg "currentWorkingDirectory=${launcher_dir}")
string(REGEX MATCH ${expected_msg} current_msg ${ov})
if(NOT "${expected_msg}" STREQUAL "${current_msg}")
  message(FATAL_ERROR "Test3 - Working directory associated with ${application_name} is incorrect ! "
                      "ExpectedWorkingDirectory:${launcher_dir}\n${ov}")
endif()

# --------------------------------------------------------------------------
# Attempt to start launcher from an other directory
get_filename_component(launcher_working_dir ${launcher_dir}/../ REALPATH)
set(command ${launcher_exe} --launcher-no-splash --launch ${application} --print-current-working-directory)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_working_dir}
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Test4 - [${launcher_exe}] failed to start application [${application}] from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

set(expected_msg "currentWorkingDirectory=${launcher_working_dir}")
string(REGEX MATCH ${expected_msg} current_msg ${ov})
if(NOT "${expected_msg}" STREQUAL "${current_msg}")
  message(FATAL_ERROR "Test4 - Working directory associated with ${application_name} is incorrect ! "
                      "ExpectedWorkingDirectory:${launcher_working_dir}\n${ov}")
endif()

# --------------------------------------------------------------------------
# Attempt to start launcher using <APPLAUNCHER_DIR> syntax
get_filename_component(launcher_working_dir ${launcher_dir}/../ REALPATH)
file(RELATIVE_PATH relative_application ${launcher_dir} ${application})
set(command ${launcher_exe} --launcher-no-splash --launch <APPLAUNCHER_DIR>/${relative_application} --print-current-working-directory)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_working_dir}
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Test5 - [${launcher_exe}] failed to start application [${application}] from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

set(expected_msg "currentWorkingDirectory=${launcher_working_dir}")
string(REGEX MATCH ${expected_msg} current_msg ${ov})
if(NOT "${expected_msg}" STREQUAL "${current_msg}")
  message(FATAL_ERROR "Test5 - Working directory associated with ${application_name} is incorrect ! "
                      "ExpectedWorkingDirectory:${launcher_working_dir}\n${ov}")
endif()
