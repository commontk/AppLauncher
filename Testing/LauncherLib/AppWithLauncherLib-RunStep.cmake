include(${TEST_SOURCE_DIR}/../Launcher/AppLauncherTestMacros.cmake)

# --------------------------------------------------------------------------
# Set application variable

set(application_dir "${APPLIB_BINARY_DIR}")
if(CMAKE_CONFIGURATION_TYPES)
  set(application_dir ${application_dir}/${APPLIB_BUILD_TYPE})
endif()
set(application_name AppWithLauncherLib)

set(application ${application_dir}/${application_name}${CMAKE_EXECUTABLE_SUFFIX})

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
foreach(filename IN ITEMS
    settings.ini
    launcher-settings.ini
    launcher-additional-settings.ini
    )
  configure_file(
    ${APPLIB_SOURCE_DIR}/${filename}
    ${application_dir}/${filename}
    COPYONLY
    )
endforeach()

set(command ${application})
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${application_dir}
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Failed to run application [${application}]:\n${ov}")
endif()
