find_package(CTKAppLauncher REQUIRED)

foreach(varname IN ITEMS
    CTKAppLauncher_EXECUTABLE
    CTKAppLauncher_SETTINGS_TEMPLATE
    )
  if(NOT DEFINED ${varname})
    message(FATAL_ERROR "Variable ${varname} is not defined")
  endif()
  if(NOT EXISTS "${${varname}}")
    message(FATAL_ERROR "${varname} references an unexistent file or directory [${${varname}}]")
  endif()
endforeach()
