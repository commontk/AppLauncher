
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/App4TestStepPrerequisites.cmake)

#
# Build App4Test
#

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# Build App4Test
set(command ${CMAKE_COMMAND} --build ${app4test_binary_dir} --config ${app4test_build_type})
#if(MSVC)
#  list(APPEND command --config=${app4test_build_type})
#endif()
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${app4test_binary_dir}
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Failed to build App4Test:\n${ov}")
endif()
