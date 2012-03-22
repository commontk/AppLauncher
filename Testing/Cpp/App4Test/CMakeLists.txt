cmake_minimum_required(VERSION 2.8)

project(App4Test)

# Disable warning C4996: [...] This function or variable may be unsafe. [...]
# To disable deprecation, use _CRT_SECURE_NO_WARNINGS. See online help for details
if(MSVC90)
  add_definitions(-D_CRT_SECURE_NO_WARNINGS)
endif()

set(APP4TEST_LIBRARIES CACHE INTERNAL "App4Test libraries" FORCE)
set(APP4TEST_INCLUDE_DIRS CACHE INTERNAL "App4Test include dirs" FORCE)

# To configure main.cpp
set(LIB_INCLUDES)
set(LIB_INSTANCIATES)

# Configure 20 libraries
foreach(LIBSUFFIX RANGE 1 30)

  set(lib_subdir lib${LIBSUFFIX})
  
  # Create directory
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/${lib_subdir}
    )
  
  # configure 
  configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/lib.template/CMakeLists.txt.in
    ${CMAKE_CURRENT_BINARY_DIR}/${lib_subdir}/CMakeLists.txt
    @ONLY
    )
  configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/lib.template/app4TestLib.h.in
    ${CMAKE_CURRENT_BINARY_DIR}/${lib_subdir}/app4TestLib${LIBSUFFIX}.h
    @ONLY
    )
  configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/lib.template/app4TestLib.cpp.in
    ${CMAKE_CURRENT_BINARY_DIR}/${lib_subdir}/app4TestLib${LIBSUFFIX}.cpp
    @ONLY
    )
  set(LIB_INCLUDES "${LIB_INCLUDES}\#include \"app4TestLib${LIBSUFFIX}.h\"\n")
  set(LIB_INSTANCIATES "${LIB_INSTANCIATES}  new app4TestLib${LIBSUFFIX}();\n")
  
  add_subdirectory(
    ${CMAKE_CURRENT_BINARY_DIR}/${lib_subdir} 
    ${CMAKE_CURRENT_BINARY_DIR}/${lib_subdir}-build)
endforeach()

configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/Main.cpp.in
  ${CMAKE_CURRENT_BINARY_DIR}/Main.cpp
  @ONLY
  )
  
include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_CURRENT_BINARY_DIR}
  ${APP4TEST_INCLUDE_DIRS}
  )
  
# Add excutable
add_executable(${PROJECT_NAME}
  ${CMAKE_CURRENT_BINARY_DIR}/Main.cpp
  )

set_target_properties(${PROJECT_NAME}  PROPERTIES
  SKIP_BUILD_RPATH ON
  RUNTIME_OUTPUT_DIRECTORY ${App4Test_BINARY_DIR}/bin
  )

target_link_libraries(${PROJECT_NAME} ${APP4TEST_LIBRARIES})

