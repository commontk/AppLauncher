include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/App4ConfigureLauncherTestStepPrerequisites.cmake)

# --------------------------------------------------------------------------
# Note: app4configurelaunchertest_binary_dir is NOT suppose to exist. Let's check if the parent directory is valid
get_filename_component(app4configurelaunchertest_binary_parent_dir ${app4configurelaunchertest_binary_dir}/../ ABSOLUTE)
if(NOT EXISTS ${app4configurelaunchertest_binary_parent_dir})
  message(FATAL_ERROR "Make sure variable APP4CONFIGURELAUNCHERTEST_BINARY_DIR/../ is set to a valid directory. "
                      "APP4CONFIGURELAUNCHERTEST_BINARY_DIR/../ [${app4configurelaunchertest_binary_parent_dir}]")
endif()

if(${app4configurelaunchertest_build_type} STREQUAL "")
  message(FATAL_ERROR "Make sure variable APP4CONFIGURELAUNCHERTEST_BUILD_TYPE is not empty. "
                      "APP4CONFIGURELAUNCHERTEST_BUILD_TYPE [${app4configurelaunchertest_build_type}]")
endif()

# --------------------------------------------------------------------------
# Delete App4ConfigureLauncherTest-build directory if it exists
execute_process(
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${app4configurelaunchertest_binary_dir}
  )

# --------------------------------------------------------------------------
# Create App4ConfigureLauncherTest-build directory
execute_process(
  COMMAND ${CMAKE_COMMAND} -E make_directory ${app4configurelaunchertest_binary_dir}
  )
  
# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# Configure App4ConfigureLauncherTest
set(command ${CMAKE_COMMAND}
  -DCMAKE_BUILD_TYPE:STRING=${app4configurelaunchertest_build_type}
  -DCTKAPPLAUNCHER_DIR:PATH=${ctkapplauncher_dir}
  -DCTKAPPLAUNCHER_BUILD_CONFIGURATIONS:STRING=${TEST_CONFIGURATION}
  -G ${app4configurelaunchertest_cmake_generator}
  ${app4configurelaunchertest_source_dir}
  )
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${app4configurelaunchertest_binary_dir}
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Failed to configure App4ConfigureLauncherTest:\n${ov}")
endif()
