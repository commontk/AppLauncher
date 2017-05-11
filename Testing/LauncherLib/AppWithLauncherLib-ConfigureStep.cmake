include(${TEST_SOURCE_DIR}/../Launcher/AppLauncherTestMacros.cmake)

# --------------------------------------------------------------------------
# Delete AppWithLauncherLib-build directory if it exists
execute_process(
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${APPLIB_BINARY_DIR}
  )

# --------------------------------------------------------------------------
# Create AppWithLauncherLib-build directory
execute_process(
  COMMAND ${CMAKE_COMMAND} -E make_directory ${APPLIB_BINARY_DIR}
  )

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# Configure AppWithLauncherLib
set(command ${CMAKE_COMMAND}
  -DCMAKE_BUILD_TYPE:STRING=${APPLIB_BUILD_TYPE}
  -DCTKAppLauncher_DIR:PATH=${CTKAppLauncher_DIR}
  -DQT_QMAKE_EXECUTABLE:FILEPATH=${QT_QMAKE_EXECUTABLE}
  -G ${APPLIB_CMAKE_GENERATOR} ${APPLIB_SOURCE_DIR}
  )
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${APPLIB_BINARY_DIR}
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Failed to configure AppWithLauncherLib:\n${ov}")
endif()
