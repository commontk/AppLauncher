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

set(args
  -DCTKAppLauncherLib_DIR:PATH=${CTKAppLauncherLib_DIR}
  -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
  -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
  -G ${APPLIB_CMAKE_GENERATOR}
  )
if(NOT CMAKE_CONFIGURATION_TYPES)
  list(APPEND args
    -DCMAKE_BUILD_TYPE:STRING=${APPLIB_BUILD_TYPE}
    )
endif()
if(DEFINED CTKAppLauncher_QT_STATIC_LIBRARIES)
  list(APPEND args
    -DCTKAppLauncher_QT_STATIC_LIBRARIES:STRING=${CTKAppLauncher_QT_STATIC_LIBRARIES}
    )
endif()
if(CTKAppLauncher_QT_VERSION VERSION_EQUAL "5")
  list(APPEND args
    -DQt5_DIR:PATH=${Qt5_DIR}
    )
else()
  message(FATAL_ERROR "Setting CTKAppLauncher_QT_VERSION to '${CTKAppLauncher_QT_VERSION}' is not supported")
endif()
foreach(varname IN ITEMS
    CMAKE_OSX_ARCHITECTURES
    CMAKE_OSX_DEPLOYMENT_TARGET
    CMAKE_OSX_SYSROOT
    CMAKE_GENERATOR_PLATFORM
    CMAKE_GENERATOR_TOOLSET
    CMAKE_MSVC_RUNTIME_LIBRARY
    )
  if(DEFINED ${varname})
    list(APPEND args
      -D${varname}:STRING=${${varname}}
      )
  endif()
endforeach()

set(command ${CMAKE_COMMAND} ${args} ${APPLIB_SOURCE_DIR})
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
