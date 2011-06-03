
#
# AppLauncherTest1
#

include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTest1Prerequisites.cmake)

#
# Configure and build App4Test
#

# --------------------------------------------------------------------------
# Note: app4test_binary_dir is NOT suppose to exist. Let's check if the parent directory is valid
get_filename_component(app4test_binary_parent_dir ${app4test_binary_dir}/../ ABSOLUTE)
if(NOT EXISTS ${app4test_binary_parent_dir})
  message(FATAL_ERROR "Make sure variable APP4TEST_BINARY_DIR/../ is set to a valid directory. "
                      "APP4TEST_BINARY_DIR/../ [${app4test_binary_parent_dir}]")
endif()

if(${app4test_build_type} STREQUAL "")
  message(FATAL_ERROR "Make sure variable APP4TEST_BUILD_TYPE is not empty. "
                      "APP4TEST_BUILD_TYPE [${app4test_build_type}]")
endif()

# --------------------------------------------------------------------------
# Delete App4Test-build directory if it exists
execute_process(
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${app4test_binary_dir}
  )

# --------------------------------------------------------------------------
# Create App4Test-build directory
execute_process(
  COMMAND ${CMAKE_COMMAND} -E make_directory ${app4test_binary_dir}
  )

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# Configure App4Test
set(command ${CMAKE_COMMAND} -DCMAKE_BUILD_TYPE:STRING=${app4test_build_type} -G ${app4test_cmake_generator} ${app4test_source_dir})
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${app4test_binary_dir}
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Failed to configure App4Test:\n${ov}")
endif()

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
