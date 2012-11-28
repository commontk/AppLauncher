
# --------------------------------------------------------------------------
# Helper macro
function(print_command_as_string command)
  if(PRINT_COMMAND)
    set(command_as_string)
    foreach(elem ${command})
      set(command_as_string "${command_as_string} ${elem}")
    endforeach()
    message(STATUS "COMMAND:${command_as_string}")
  endif()
endfunction()

function(list_to_string input output_var)
  set(stringified)
  foreach(item ${input})
    if(NOT "${stringified}" STREQUAL "")
      set(stringified "${stringified}\;")
    endif()
    set(stringified "${stringified}${item}")
  endforeach()
  set(${output_var} "${stringified}" PARENT_SCOPE)
endfunction()

# Extract application settings value
function(extract_application_settings_value settings_name settings_value_varname)
  set(command ${launcher_exe} --launcher-no-splash --launcher-verbose --launcher-help)
  execute_process(
    COMMAND ${command}
    WORKING_DIRECTORY ${launcher_binary_dir}
    ERROR_VARIABLE ev
    OUTPUT_VARIABLE ov
    RESULT_VARIABLE rv
    )

  print_command_as_string("${command}")

  string(REGEX REPLACE "^.*\n?info\\: ${settings_name}[ ]+\\[([^\n]+)\\].*"
        "\\1" settings_value "${ov}")

  set(${settings_value_varname} ${settings_value} PARENT_SCOPE)
endfunction()
