
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# Create a directory named like the "application to launch" to
# test that the launcher ignores it when searching for the executable.
set(path_with_same_name_directory "${application_dir}/same_name_directory")
file(MAKE_DIRECTORY "${path_with_same_name_directory}/${application_name}")

# Create a non-executable file named like the "application to launch" to
# test that the launcher ignores it when searching for the executable.
set(path_with_same_name_nonexecutable_file "${application_dir}/same_name_nonexecutable_file")
file(MAKE_DIRECTORY "${path_with_same_name_nonexecutable_file}")
file(WRITE "${path_with_same_name_nonexecutable_file}/${application_name}")

set(path_with_working_app ${application_dir})
if(UNIX)
  set(path_with_same_name_symlink "${application_dir}/same_name_symlink")
  file(MAKE_DIRECTORY "${path_with_same_name_symlink}")
  execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink
    ${application} ${path_with_same_name_symlink}/${application_name})
  set(path_with_working_app ${path_with_same_name_symlink})
endif()



# --------------------------------------------------------------------------
# Configure settings file
file(WRITE "${launcher}LauncherSettings.ini" "

[Paths]
1\\path=${path_with_same_name_directory}
2\\path=${path_with_same_name_nonexecutable_file}
3\\path=${path_with_working_app}
size=3

[LibraryPaths]
1\\path=${library_path}
size=1
")

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# TestLaunchExecutableInPath - If launcher search considers PATH as expected, the launcher should
#                              execute App4Test if specified as command line parameter.
set(command ${launcher_exe} --launcher-no-splash --launch ${application_name} --print-hello-world)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

set(expected_msg "Hello world !")
string(REGEX MATCH ${expected_msg} current_msg "${ov}")
if("${current_msg}" STREQUAL "")
  message(FATAL_ERROR "TestLaunchExecutableInPath\n"
                      "  expected_msg:${expected_msg}\n"
                      "  current_msg:${ov}")
endif()

# Clean
file(REMOVE_RECURSE "${path_with_same_name_directory}")
file(REMOVE_RECURSE "${path_with_same_name_nonexecutable_file}")
if(UNIX)
  file(REMOVE_RECURSE "${path_with_same_name_symlink}")
endif()
