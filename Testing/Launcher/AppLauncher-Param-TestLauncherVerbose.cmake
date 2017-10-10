
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Configure settings file
file(WRITE "${launcher}LauncherSettings.ini" "
[LibraryPaths]
1\\path=${library_path}
size=1
")

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# Check if flag --launcher-verbose works as expected
set(command ${launcher_exe} --launcher-no-splash --launcher-verbose --launch ${application})
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "[${launcher_exe}] failed to start application [${application}] from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

if(WIN32)
  set(regex "Setting env. variable \\[Path\\].*info: Starting")
else()
  set(regex "Setting env. variable \\[(DY)?LD_LIBRARY_PATH\\].*info: Starting")
endif()
string(REGEX MATCH ${regex} current_msg ${ov})
if("${current_msg}" STREQUAL "")
  message(FATAL_ERROR "Problem with flag --launcher-verbose")
endif()

