include(${TEST_SOURCE_DIR}/../Launcher/AppLauncherTestMacros.cmake)

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# Build AppWithLauncherLib
set(command ${CMAKE_COMMAND} --build ${APPLIB_BINARY_DIR} --config ${APPLIB_BUILD_TYPE})
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${APPLIB_BINARY_DIR}
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Failed to build AppWithLauncherLib:\n${ov}")
endif()
