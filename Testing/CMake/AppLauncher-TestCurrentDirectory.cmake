
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# Configure settings file
file(WRITE "${launcher}LauncherSettings.ini" "
[LibraryPaths]
1\\path=${library_path}
size=1
")

# --------------------------------------------------------------------------
# Attempt to start launcher from its directory
set(command ${launcher_exe} --launcher-no-splash --launch ${application} --print-current-working-directory)
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
  message(FATAL_ERROR "[${launcher_exe}] failed to start application [${application}] from "
                      "directory [${launcher_dir}]\n${ev}")
endif()

set(expected_msg "currentWorkingDirectory=${launcher_dir}")
string(REGEX MATCH ${expected_msg} current_msg ${ov})
if(NOT "${expected_msg}" STREQUAL "${current_msg}")
  message(FATAL_ERROR "Working directory associated with ${application_name} is incorrect ! "
                      "ExpectedWorkingDirectory:${launcher_dir}\n${ov}")
endif()

# --------------------------------------------------------------------------
# Attempt to start launcher from its directory
set(command ${launcher_exe} --launcher-no-splash --launch ${application} --print-current-working-directory)
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
  message(FATAL_ERROR "[${launcher_exe}] failed to start application [${application}] from "
                      "directory [${launcher_dir}]\n${ev}")
endif()

set(expected_msg "currentWorkingDirectory=${launcher_dir}")
string(REGEX MATCH ${expected_msg} current_msg ${ov})
if(NOT "${expected_msg}" STREQUAL "${current_msg}")
  message(FATAL_ERROR "Working directory associated with ${application_name} is incorrect ! "
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
  message(FATAL_ERROR "[${launcher_exe}] failed to start application [${application}] from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

set(expected_msg "currentWorkingDirectory=${launcher_working_dir}")
string(REGEX MATCH ${expected_msg} current_msg ${ov})
if(NOT "${expected_msg}" STREQUAL "${current_msg}")
  message(FATAL_ERROR "Working directory associated with ${application_name} is incorrect ! "
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
  message(FATAL_ERROR "[${launcher_exe}] failed to start application [${application}] from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

set(expected_msg "currentWorkingDirectory=${launcher_working_dir}")
string(REGEX MATCH ${expected_msg} current_msg ${ov})
if(NOT "${expected_msg}" STREQUAL "${current_msg}")
  message(FATAL_ERROR "Working directory associated with ${application_name} is incorrect ! "
                      "ExpectedWorkingDirectory:${launcher_working_dir}\n${ov}")
endif()
