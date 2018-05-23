
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
  set(command ${launcher_exe} --launcher-no-splash --launcher-verbose --launcher-dump-environment ${ARGN})
  execute_process(
    COMMAND ${command}
    WORKING_DIRECTORY ${launcher_binary_dir}
    ERROR_VARIABLE ev
    OUTPUT_VARIABLE ov
    RESULT_VARIABLE rv
    )

  print_command_as_string("${command}")

  if(rv)
    message(FATAL_ERROR "[${launcher_exe}] failed to execute launcher from "
                        "directory [${launcher_binary_dir}]\n${ev}")
  endif()

  string(REGEX REPLACE "^.*\n?info\\: ${settings_name}[ ]+\\[([^\n]*)\\].*"
        "\\1" settings_value "${ov}")

  set(${settings_value_varname} ${settings_value} PARENT_SCOPE)
endfunction()

function(check_expected_string text expected_str context)
  string(FIND "${text}" "${expected_str}" pos)
  if(${pos} STREQUAL -1)
    message(FATAL_ERROR "Problem with ${context} - expected_str:${expected_str} "
                        "not found in text:${text}")
  endif()
endfunction()

function(check_unexpected_string text unexpected_str context)
  string(FIND "${text}" "${unexpected_str}" pos)
  if(NOT ${pos} STREQUAL -1)
    message(FATAL_ERROR "Problem with ${context} - unexpected_str:${unexpected_str} "
                        "found in text:${text}")
  endif()
endfunction()
