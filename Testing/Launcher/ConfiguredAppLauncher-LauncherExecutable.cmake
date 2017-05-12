include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/ConfiguredAppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Check that we can run the application using the generated launcher. This
# also verifies that the launcher executable was created as expected.
set(command ${launcher_exe} --launcher-no-splash)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${app4configurelaunchertest_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "[${launcher_exe}] failed to start from directory "
                      "[${app4configurelaunchertest_binary_dir}]\n${ev}")
endif()
