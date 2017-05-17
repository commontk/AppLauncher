include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/App4ConfigureLauncherTestStepPrerequisites.cmake)

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# Build App4ConfigureLauncherTest
set(command ${CMAKE_COMMAND} --build ${app4configurelaunchertest_binary_dir} --config ${app4configurelaunchertest_build_type})
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${app4configurelaunchertest_binary_dir}
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Failed to build App4ConfigureLauncherTest:\n${ov}")
endif()
