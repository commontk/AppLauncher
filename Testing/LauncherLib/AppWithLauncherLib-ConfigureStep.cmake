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

string(TOUPPER ${APPLIB_BUILD_TYPE} APPLIB_BUILD_TYPE_UC)

set(args
  -DCMAKE_BUILD_TYPE:STRING=${APPLIB_BUILD_TYPE}
  -DCTKAppLauncherLib_DIR:PATH=${CTKAppLauncherLib_DIR}
  -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
  -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
  -DCMAKE_CXX_FLAGS_${APPLIB_BUILD_TYPE_UC}:STRING=${CMAKE_CXX_FLAGS_${APPLIB_BUILD_TYPE_UC}}
  -G ${APPLIB_CMAKE_GENERATOR}
  )
if(DEFINED CTKAppLauncher_QT_STATIC_LIBRARIES)
  list(APPEND args
    -DCTKAppLauncher_QT_STATIC_LIBRARIES:STRING=${CTKAppLauncher_QT_STATIC_LIBRARIES}
    )
endif()
if(CTKAppLauncher_QT_VERSION VERSION_GREATER "4")
  list(APPEND args
    -DQt5_DIR:PATH=${Qt5_DIR}
    )
else()
  list(APPEND args
    -DQT_QMAKE_EXECUTABLE:FILEPATH=${QT_QMAKE_EXECUTABLE}
    )
endif()
foreach(varname IN ITEMS
    CMAKE_OSX_ARCHITECTURES
    CMAKE_OSX_DEPLOYMENT_TARGET
    CMAKE_OSX_SYSROOT
    CMAKE_GENERATOR_PLATFORM
    CMAKE_GENERATOR_TOOLSET
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
