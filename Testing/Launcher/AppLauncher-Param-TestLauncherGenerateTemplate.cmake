
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
# Delete template file if it exists
execute_process(
  COMMAND ${CMAKE_COMMAND} -E remove -f ${launcher}LauncherSettings.ini.template
  )

# --------------------------------------------------------------------------
# Check if flag --launcher-generate-template works as expected
set(command ${launcher_exe} --launcher-generate-template)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Failed to run [${launcher_exe}] with parameter --launcher-generate-template\n${ev}")
endif()

if(NOT EXISTS ${launcher}LauncherSettings.ini.template)
   message(FATAL_ERROR "Problem with flag --launcher-generate-template."
                       "Failed to generate template settings file: ${launcher}LauncherSettings.ini.template")
endif()
