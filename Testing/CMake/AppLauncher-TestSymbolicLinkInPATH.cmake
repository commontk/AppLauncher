include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
set(symlink_dir "${launcher_binary_dir}/TestSymbolicLinkInPATH")
set(symlink_name "SymLinkToLauncher")

# --------------------------------------------------------------------------
# Configure settings file
file(WRITE "${launcher}LauncherSettings.ini" "
[LibraryPaths]
1\\path=${library_path}
size=1
")

# Set path
set(old_path "$ENV{PATH}")
set(ENV{PATH} "${symlink_dir}:$ENV{PATH}")

# --------------------------------------------------------------------------
# Delete test directory if it exists
execute_process(
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${symlink_dir}
  )

# Re-create test directory
file(MAKE_DIRECTORY ${symlink_dir})

# .. and add a symlink
execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink
  ${launcher_exe} ${symlink_dir}/${symlink_name})

# --------------------------------------------------------------------------
# Attempt to start launcher using symlink added to the PATH
set(cwd ${launcher_binary_dir})
set(command ${symlink_name} --launcher-no-splash --launch ${application} --print-current-working-directory)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${cwd}
  ERROR_VARIABLE ev
  ERROR_STRIP_TRAILING_WHITESPACE
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

# Restore path
set(ENV{PATH} "${old_path}")

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "[${symlink_name}] failed to start application [${application}] from "
                      "directory [${cwd}]\n${ev}")
endif()

set(expected_msg "currentWorkingDirectory=${cwd}")
string(REGEX MATCH ${expected_msg} current_msg ${ov})
if(NOT "${expected_msg}" STREQUAL "${current_msg}")
  message(FATAL_ERROR "Working directory associated with ${application_name} is incorrect ! "
                      "ExpectedWorkingDirectory:${cwd}\n${ov}")
endif()
