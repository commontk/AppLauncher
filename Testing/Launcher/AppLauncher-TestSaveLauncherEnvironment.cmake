cmake_minimum_required(VERSION 3.16.3)

# --------------------------------------------------------------------------
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# Debug flags - Set to True to display the environment
set(DISPLAY_ENV 0)

# --------------------------------------------------------------------------
# Define how many time the launcher should be recursively called from
# the launched process.
set(TEST_MAX_LEVEL 4)

# --------------------------------------------------------------------------
if(WIN32)
  set(pathsep ";")
else()
  set(pathsep ":")
endif()

# --------------------------------------------------------------------------
function(run_laucher expected_level)
  message(STATUS "Executing launcher for level [${expected_level}]")
  set(command ${launcher_exe} --launcher-no-splash
    --launch ${CMAKE_COMMAND}
    -DTEST_SOURCE_DIR:PATH=${TEST_SOURCE_DIR}
    -DTEST_BINARY_DIR:PATH=${TEST_BINARY_DIR}
    -DEXPECTED_LEVEL:BOOL=${expected_level}
    -DTEST_NAME:STRING=${TEST_NAME}
    -DAppLauncherTestPrerequisites_COPY_LAUNCHER:BOOL=FALSE
    -P ${CMAKE_CURRENT_LIST_FILE}
    )
  print_command_as_string("${command}")
  execute_process(
    COMMAND ${command}
    WORKING_DIRECTORY ${launcher_dir}
    RESULT_VARIABLE rv
    )
  if(rv)
    message(FATAL_ERROR "[${launcher_exe}] failed to start application [${CMAKE_COMMAND}]")
  endif()
endfunction()

# --------------------------------------------------------------------------
function(write_launcher_settings level)
  message(STATUS "Writing launcher settings for level [${level}]")
  file(WRITE "${launcher}LauncherSettings.ini" "
[Paths]
1\\path=/level_${level}/path/1
2\\path=/level_${level}/path/2
size=2

[EnvironmentVariables]
LEVEL_VALUE=value-overridden-at-level_${level}
LEVEL_${level}_VALUE=level_${level}
")
endfunction()

# --------------------------------------------------------------------------
function(display_env)
  message(STATUS "---------------------------------------------")
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E environment
    OUTPUT_VARIABLE ov
    )
  string(REPLACE "\n" ";" list_ov ${ov})
  list(SORT list_ov)
  foreach(line IN LISTS list_ov)
    if(line MATCHES "^APPLAUNCHER" OR line MATCHES "^LEVEL")
      message("${line}")
    endif()
  endforeach()
  message(STATUS "---------------------------------------------")
endfunction()

# --------------------------------------------------------------------------
function(check_value env_var_name expected_value)
  if(NOT "$ENV{${env_var_name}}" STREQUAL "${expected_value}")
    message(FATAL_ERROR "Problem saving or restoring the environment
Environment variable: ${env_var_name}
  expected_value [${expected_value}]
   current_value [$ENV{${env_var_name}}]
")
  endif()
endfunction()

# --------------------------------------------------------------------------
function(check_env level)

  # Env. variables
  check_value("LEVEL_VALUE"          "value-overridden-at-level_${level}")
  set(expected_path "")
  foreach(idx RANGE ${level})
    check_value("LEVEL_${idx}_VALUE" "level_${idx}")
    if(idx EQUAL 0)
      set(expected_path "/level_${idx}/path/1${pathsep}/level_${idx}/path/2")
    else()
      set(expected_path "/level_${idx}/path/1${pathsep}/level_${idx}/path/2${pathsep}${expected_path}")
    endif()
  endforeach()
  check_value("PATH" "${expected_path}")

  # Saved Env. variables
  message(STATUS "Checking saved environment at level [${level}]")
  math(EXPR saved_level "${level} - 1")
  set(extra)
  foreach(idx RANGE ${saved_level})
    if(idx EQUAL 0)
      set(extra "APPLAUNCHER_${idx}_")
    else()
      set(extra "${extra}, APPLAUNCHER_${idx}_")
    endif()
  endforeach()
  message(STATUS "  -> Expect env. variables prefixed with ${extra}")

  if(DISPLAY_ENV)
    display_env()
  endif()

  check_value("APPLAUNCHER_LEVEL" "${level}")

  set(expected_path "")
  foreach(idx RANGE 0 ${saved_level})
    if(idx EQUAL 0)
      check_value("APPLAUNCHER_${idx}_LEVEL_VALUE" "value-set-at-level_${idx}")
    else()
      check_value("APPLAUNCHER_${idx}_LEVEL_VALUE" "value-overridden-at-level_${idx}")
    endif()

    if(idx EQUAL 0)
      set(expected_path "/level_${idx}/path/1${pathsep}/level_${idx}/path/2")
    else()
      set(expected_path "/level_${idx}/path/1${pathsep}/level_${idx}/path/2${pathsep}${expected_path}")
    endif()

    check_value("APPLAUNCHER_${idx}_PATH" "${expected_path}")
  endforeach()

  # Check that variables used to save an environment are excluded from
  # enviroment save operations.
  if(level GREATER 1)
    set(prefix "")
    foreach(idx RANGE 1 ${level})
      set(prefix "APPLAUNCHER_${idx}_${prefix}")
    endforeach()
    set(envvar_name "${prefix}LEVEL_VALUE")
    set(envvar_value "value-set-at-level_0")
    if("$ENV{${envvar_name}}" STREQUAL "${envvar_value}")
      message(FATAL_ERROR "Env variable '${envvar_name}' should NOT be set")
    endif()
  endif()

  # Check that APPLAUNCHER_LEVEL variable is not saved
  if(level GREATER 0)
    set(envvar_name "APPLAUNCHER_${level}_APPLAUNCHER_LEVEL")
    if(NOT "$ENV{${envvar_name}}" STREQUAL "")
      message(FATAL_ERROR "Env variable '${envvar_name}' should NOT be set")
    endif()
  endif()

endfunction()

# --------------------------------------------------------------------------
if(DEFINED EXPECTED_LEVEL)

  check_env(${EXPECTED_LEVEL})

  math(EXPR next_level "${EXPECTED_LEVEL} + 1")
  if(NOT next_level GREATER TEST_MAX_LEVEL)
    write_launcher_settings(${next_level})
    run_laucher(${next_level})
  endif()
  return()
endif()

# --------------------------------------------------------------------------
set(ENV{LEVEL_0_VALUE} "level_0")
set(ENV{LEVEL_VALUE} "value-set-at-level_0")
set(ENV{PATH} "/level_0/path/1${pathsep}/level_0/path/2")

# --------------------------------------------------------------------------
write_launcher_settings(1)
run_laucher(1)
