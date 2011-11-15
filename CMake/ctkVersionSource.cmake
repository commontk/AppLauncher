# Adapted from: CMake/Utilites/CMakeVersionSource.cmake

# Try to identify the current development source version.
set(CTKAppLauncher_VERSION_SOURCE "")
if(NOT EXISTS ${CMAKE_SOURCE_DIR}/.git/HEAD)
  message(FATAL_ERROR "error: ${CMAKE_SOURCE_DIR} is NOT a git repository. ")
endif()
find_program(GIT_EXECUTABLE NAMES git git.cmd)
mark_as_advanced(GIT_EXECUTABLE)
if(GIT_EXECUTABLE)
  execute_process(
    COMMAND ${GIT_EXECUTABLE} rev-parse --verify -q --short=4 HEAD
    OUTPUT_VARIABLE head
    OUTPUT_STRIP_TRAILING_WHITESPACE
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )
  if(head)
    set(CTKAppLauncher_VERSION_SOURCE "g${head}")
    execute_process(
      COMMAND ${GIT_EXECUTABLE} update-index -q --refresh
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      )
    execute_process(
      COMMAND ${GIT_EXECUTABLE} diff-index --name-only HEAD --
      OUTPUT_VARIABLE dirty
      OUTPUT_STRIP_TRAILING_WHITESPACE
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      )
    if(dirty)
      set(CTKAppLauncher_VERSION_SOURCE "${CTKAppLauncher_VERSION_SOURCE}-dirty")
    endif()
  endif()
endif()

