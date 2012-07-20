
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
