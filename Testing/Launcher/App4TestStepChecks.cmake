
if(NOT EXISTS ${app4test_binary_dir})
  message(FATAL_ERROR "Make sure variable APP4TEST_BINARY_DIR is set to a valid directory. "
                      "APP4TEST_BINARY_DIR [${app4test_binary_dir}]")
endif()

if(NOT EXISTS ${application})
  message(FATAL_ERROR "Application ${application} doesn't exists !")
endif()

set(library_path ${app4test_binary_dir}/libs)
if(CMAKE_CONFIGURATION_TYPES)
  set(library_path ${library_path}/${app4test_build_type})
endif()

if (NOT EXISTS ${library_path})
  message(FATAL_ERROR "Library path [${library_path}] doesn't exist")
endif()
