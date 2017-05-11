
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)

# --------------------------------------------------------------------------
# Sanity checks

foreach(varname IN ITEMS LAUNCHER_BUILD_DIR LAUNCHER_INSTALL_DIR)
  if(NOT EXISTS "${${varname}}")
    message(FATAL_ERROR "Make sure variable ${varname} is set to a valid directory. "
                        "${varname} [${${varname}}]")
  endif()
endforeach()

# Remove install directory and its content
file(REMOVE_RECURSE ${LAUNCHER_INSTALL_DIR})

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

set(command ${CMAKE_COMMAND}
  -DCMAKE_INSTALL_PREFIX:PATH=${LAUNCHER_INSTALL_DIR}
  -DCTKAppLauncher_INSTALL_LauncherLibrary:BOOL=${CTKAppLauncherTest_INSTALL_LauncherLibrary}
  ${LAUNCHER_BUILD_DIR}
  )
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${LAUNCHER_BUILD_DIR}
  ERROR_VARIABLE ev
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Failed to build configure\n${ev}")
endif()

# --------------------------------------------------------------------------
set(command ${CMAKE_COMMAND} --build . --config ${TEST_CONFIGURATION} --target install)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${LAUNCHER_BUILD_DIR}
  ERROR_VARIABLE ev
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Failed to build 'install' target\n${ev}")
endif()
