
if(NOT DEFINED MIDAS_API_DISPLAY_URL)
  set(MIDAS_API_DISPLAY_URL 0)
endif()

function(download_file url dest)
  file(DOWNLOAD ${url} ${dest} STATUS status)
  list(GET status 0 error_code)
  list(GET status 1 error_msg)
  if(error_code)
    message(FATAL_ERROR "error: Failed to download ${url} - ${error_msg}")
  endif()
endfunction()

# Download and include MIDASAPILogin
set(url http://viewvc.slicer.org/viewvc.cgi/Slicer4/trunk/CMake/MIDASAPILogin.cmake?revision=19751&view=co)
set(dest ${CMAKE_CURRENT_BINARY_DIR}/MIDASAPILogin.cmake)
download_file(${url} ${dest})
include(${dest})



#
# Uploads a file and create the associated item in the given folder.
#
#   API_URL    The url of the MIDAS server
#   API_EMAIL  The email to use to authenticate to the server
#   API_KEY The default api key to use to authenticate to the server
#
#   RESULT_VARNAME Will set the value of ${RESULT_VARNAME} to either "ok" or "fail".

function(midas_api_item_upload)
  include(CMakeParseArguments)
  set(options)
  set(oneValueArgs API_URL API_EMAIL API_KEY FOLDERID ITEM_FILEPATH RESULT_VARNAME)
  set(multiValueArgs)
  cmake_parse_arguments(MY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  # Sanity check
  _midas_api_expected_nonempty_vars(API_URL API_EMAIL API_KEY FOLDERID RESULT_VARNAME)
  _midas_api_expected_existing_vars(ITEM_FILEPATH)

  get_filename_component(filename "${MY_ITEM_FILEPATH}" NAME)

  midas_api_item_create(
    API_URL ${MY_API_URL}
    API_EMAIL ${MY_API_EMAIL}
    API_KEY ${MY_API_KEY}
    PARENTID ${MY_FOLDERID}
    NAME ${filename}
    RESULT_VARNAME itemid
    )

  file(MD5 ${MY_ITEM_FILEPATH} checksum)

  midas_api_upload_generatetoken(
    API_URL ${MY_API_URL}
    API_EMAIL ${MY_API_EMAIL}
    API_KEY ${MY_API_KEY}
    ITEMID ${itemid}
    FILENAME ${filename}
    CHECKSUM ${checksum}
    RESULT_VARNAME generatetoken
    )

  midas_api_upload_perform(
    API_URL ${MY_API_URL}
    UPLOADTOKEN ${generatetoken}
    FOLDERID ${MY_FOLDERID}
    ITEMID ${itemid}
    ITEM_FILEPATH ${MY_ITEM_FILEPATH}
    RESULT_VARNAME output
    )

  set(${MY_RESULT_VARNAME} ${output} PARENT_SCOPE)
endfunction()



#
# Uploads a file into a given item.
#
#   API_URL    The url of the MIDAS server
#   API_EMAIL  The email to use to authenticate to the server
#   API_KEY The default api key to use to authenticate to the server
#
#   RESULT_VARNAME Will set the value of ${RESULT_VARNAME} to either "ok" or "fail".

function(midas_api_upload_perform)
  include(CMakeParseArguments)
  set(options)
  set(oneValueArgs API_URL UPLOADTOKEN FOLDERID ITEMID ITEM_FILEPATH RESULT_VARNAME)
  set(multiValueArgs)
  cmake_parse_arguments(MY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  # Sanity check
  _midas_api_expected_nonempty_vars(API_URL UPLOADTOKEN FOLDERID ITEMID RESULT_VARNAME)
  _midas_api_expected_existing_vars(ITEM_FILEPATH)

  midas_api_escape_for_url(uploadtoken "${MY_UPLOADTOKEN}")
  get_filename_component(filename "${MY_ITEM_FILEPATH}" NAME)
  midas_api_escape_for_url(filename "${filename}")
  midas_api_escape_for_url(itemid "${MY_ITEMID}")
  midas_api_escape_for_url(folderid "${MY_FOLDERID}")

  midas_api_file_size(${MY_ITEM_FILEPATH} length)

  set(api_method "midas.upload.perform")
  set(params "&uploadtoken=${uploadtoken}")
  set(params "${params}&filename=${filename}")
  set(params "${params}&length=${length}")
  set(params "${params}&itemid=${itemid}")
  set(params "${params}&folderid=${folderid}")
  set(url "${MY_API_URL}/api/json?method=${api_method}${params}")

  if("${MIDAS_API_DISPLAY_URL}")
    message(STATUS "URL: ${url}")
  endif()
  file(UPLOAD ${MY_ITEM_FILEPATH} ${url} INACTIVITY_TIMEOUT 120 STATUS status LOG log SHOW_PROGRESS)

  set(api_call_log ${CMAKE_CURRENT_BINARY_DIR}/${api_method}_response.txt)
  # For some reason, passing directly 'log' to 'midas_api_extract_json_value' return
  # status:0"no error"
  file(WRITE ${api_call_log} ${log})
  file(READ ${api_call_log} response)
  midas_api_extract_json_value(${response} "stat" status)

  if(status STREQUAL "ok")
    file(REMOVE ${api_call_log})
    set(${MY_RESULT_VARNAME} "ok" PARENT_SCOPE)
  else()
    set(${MY_RESULT_VARNAME} "fail" PARENT_SCOPE)
  endif()
endfunction()



#
# Uploads an item to the MIDAS server.
#
#   API_URL    The url of the MIDAS server
#   API_EMAIL  The email to use to authenticate to the server
#   API_KEY The default api key to use to authenticate to the server
#
#   RESULT_VARNAME  An upload token that can be used to upload a file. If checksum is passed
#                   and the token returned is blank, the server already has this file and there
#                   is no need to upload.
#                   Return "fail" in case of error.

function(midas_api_upload_generatetoken)
  include(CMakeParseArguments)
  set(options)
  set(oneValueArgs API_URL API_EMAIL API_KEY ITEMID FILENAME CHECKSUM RESULT_VARNAME)
  set(multiValueArgs)
  cmake_parse_arguments(MY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  # Sanity check
  _midas_api_expected_nonempty_vars(API_URL API_EMAIL API_KEY ITEMID FILENAME CHECKSUM RESULT_VARNAME)

  midas_api_login(
    API_URL ${MY_API_URL}
    API_EMAIL ${MY_API_EMAIL}
    API_KEY ${MY_API_KEY}
    RESULT_VARNAME midas_api_token
    )

  midas_api_escape_for_url(itemid "${MY_ITEMID}")
  midas_api_escape_for_url(filename "${MY_FILENAME}")
  midas_api_escape_for_url(checksum "${MY_CHECKSUM}")

  set(api_method "midas.upload.generatetoken")
  set(params "&token=${midas_api_token}")
  set(params "${params}&itemid=${itemid}")
  set(params "${params}&filename=${filename}")
  set(params "${params}&checksum=${checksum}")
  set(url "${MY_API_URL}/api/json?method=${api_method}${params}")

  midas_api_submit_request(${url} ${api_method} "token" token)

  if("${token}" STREQUAL "")
    set(token "fail")
  endif()
  set(${MY_RESULT_VARNAME} "${token}" PARENT_SCOPE)

endfunction()


#
# Create an item on the MIDAS server.
#
#   API_URL    The url of the MIDAS server
#   API_EMAIL  The email to use to authenticate to the server
#   API_KEY The default api key to use to authenticate to the server
#
#   RESULT_VARNAME  The itemid that was created. Return "fail" in case of error.

function(midas_api_item_create)
  include(CMakeParseArguments)
  set(options)
  set(oneValueArgs API_URL API_EMAIL API_KEY PARENTID NAME RESULT_VARNAME)
  set(multiValueArgs)
  cmake_parse_arguments(MY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  # Sanity check
  _midas_api_expected_nonempty_vars(API_URL API_EMAIL API_KEY PARENTID NAME RESULT_VARNAME)

  midas_api_login(
    API_URL ${MY_API_URL}
    API_EMAIL ${MY_API_EMAIL}
    API_KEY ${MY_API_KEY}
    RESULT_VARNAME midas_api_token
    )

  midas_api_escape_for_url(parentid "${MY_PARENTID}")
  midas_api_escape_for_url(name "${MY_NAME}")

  set(api_method "midas.item.create")
  set(params "&token=${midas_api_token}")
  set(params "${params}&parentid=${parentid}")
  set(params "${params}&name=${name}")
  set(url "${MY_API_URL}/api/json?method=${api_method}${params}")

  midas_api_submit_request(${url} ${api_method} "item_id" itemid)

  if("${itemid}" STREQUAL "")
    set(itemid "fail")
  endif()

  set(${MY_RESULT_VARNAME} "${itemid}" PARENT_SCOPE)
endfunction()

function(_midas_api_expected_nonempty_vars varlist)
  foreach(var ${varlist})
    if("${MY_${var}}" STREQUAL "")
      message(FATAL_ERROR "error: ${var} CMake variable is empty !")
    endif()
  endforeach()
endfunction()

function(_midas_api_expected_existing_vars varlist)
  foreach(var ${varlist})
    if(NOT EXISTS "${MY_${var}}")
      message(FATAL_ERROR "Variable ${var} is set to an inexistent directory or file ! [${${var}}]")
    endif()
  endforeach()
endfunction()

macro(midas_api_extract_json_value response json_item varname)
  string(REGEX REPLACE ".*{\"${json_item}\":\"([^\"]*)\".*" "\\1" ${varname} ${response})
endmacro()

function(midas_api_submit_request url api_method json_item varname)
  if("${MIDAS_API_DISPLAY_URL}")
    message(STATUS "URL: ${url}")
  endif()
  set(_midas_api_response ${CMAKE_CURRENT_BINARY_DIR}/${api_method}_response.txt)
  file(DOWNLOAD ${url} ${_midas_api_response} INACTIVITY_TIMEOUT 120)
  file(READ ${_midas_api_response} response)
  string(REPLACE "\\" "\\\\" response ${response}) # CMake escape
  file(REMOVE ${_midas_api_response})
  midas_api_extract_json_value(${response} ${json_item} json_item_value)
  set(${varname} ${json_item_value} PARENT_SCOPE)
endfunction()

function(midas_api_file_size filepath varname)
  # Download required FileInformation module
  find_package(Git REQUIRED)
  set(download_script ${CMAKE_CURRENT_BINARY_DIR}/download-fileinformation.cmake)
  set(git_repo git://github.com/sakra/FileInformation.git)
  set(git_tag 23fb28d7)
  set(src_name FileInformation)
  file(REMOVE_RECURSE ${CMAKE_CURRENT_BINARY_DIR}/${src_name})
  execute_process(
    COMMAND ${GIT_EXECUTABLE} clone ${git_repo} ${src_name}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    RESULT_VARIABLE error_code OUTPUT_QUIET ERROR_QUIET
    )
  if(error_code)
    message(FATAL_ERROR "Failed to clone repository: '${git_repo}'")
  endif()
  execute_process(
    COMMAND ${GIT_EXECUTABLE} checkout ${git_tag}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${src_name}
    RESULT_VARIABLE error_code OUTPUT_QUIET ERROR_QUIET
    )
  if(error_code)
    message(FATAL_ERROR "Failed to checkout tag: '${git_tag}'")
  endif()
  include(${CMAKE_CURRENT_BINARY_DIR}/${src_name}/Module/FileInformation.cmake)

  file(SIZE ${filepath} size)

  file(REMOVE_RECURSE ${CMAKE_CURRENT_BINARY_DIR}/${src_name})

  set(${varname} ${size} PARENT_SCOPE)
endfunction()


################################################################################
# Testing
################################################################################

set(ALL_TESTS) # This variable will hold the list of all test functions

macro(_midas_api_test_prerequisites)
  set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR} ${CMAKE_MODULE_PATH})

  if(NOT DEFINED API_URL)
    set(API_URL "http://karakoram/midas")
  endif()
  if(NOT DEFINED API_EMAIL)
    set(API_EMAIL "jchris.fillionr@kitware.com")
  endif()
  if(NOT DEFINED API_KEY)
    set(API_KEY "a4d947d1772e227adf75639b449974d3")
  endif()
  if(NOT DEFINED PARENTID)
    set(PARENTID 19)
  endif()
endmacro()

#
# cmake -DTEST_midas_api_item_create_test:BOOL=ON -P MIDASAPICore.cmake
#
function(midas_api_item_create_test)

  _midas_api_test_prerequisites()

  set(name midas_api_item_create_test)

  midas_api_item_create(
    API_URL ${API_URL}
    API_EMAIL ${API_EMAIL}
    API_KEY ${API_KEY}
    PARENTID ${PARENTID}
    NAME ${name}
    RESULT_VARNAME output
    )
  set(unexpected_output "fail")
  if("${output}" STREQUAL "${unexpected_output}")
    message(FATAL_ERROR "Problem with midas_api_item_create()\n"
                        "parentid:${PARENTID}\n"
                        "name:${name}")
  endif()

  message("SUCCESS - itemid:${output}")
endfunction()
list(APPEND ALL_TESTS midas_api_item_create_test)
if(TEST_midas_api_item_create_test)
  midas_api_item_create_test()
endif()

#
# cmake -DTEST_midas_api_upload_generatetoken_test:BOOL=ON -P MIDASAPICore.cmake
#
function(midas_api_upload_generatetoken_test)

  _midas_api_test_prerequisites()

  set(filename "midas_api_upload_generatetoken_test.txt")
  set(item_filepath ${CMAKE_CURRENT_BINARY_DIR}/${filename})
  file(WRITE ${item_filepath} "parentid: ${PARENTID} - filename:${filename}")
  file(MD5 ${item_filepath} checksum)
  file(REMOVE ${item_filepath})

  midas_api_item_create(
    API_URL ${API_URL}
    API_EMAIL ${API_EMAIL}
    API_KEY ${API_KEY}
    PARENTID ${PARENTID}
    NAME ${filename}
    RESULT_VARNAME itemid
    )

  message("itemid:${itemid}")

  midas_api_upload_generatetoken(
    API_URL ${API_URL}
    API_EMAIL ${API_EMAIL}
    API_KEY ${API_KEY}
    ITEMID ${itemid}
    FILENAME ${filename}
    CHECKSUM ${checksum}
    RESULT_VARNAME output
    )
  set(unexpected_output "fail")
  if("${output}" STREQUAL "${unexpected_output}")
    message(FATAL_ERROR "Problem with midas_api_item_create()\n"
                        "itemid:${itemid}\n"
                        "filename:${filename}\n"
                        "checksum:${checksum}")
  endif()

  message("SUCCESS - generatetoken:${output}")
endfunction()
list(APPEND ALL_TESTS midas_api_upload_generatetoken_test)
if(TEST_midas_api_upload_generatetoken_test)
  midas_api_upload_generatetoken_test()
endif()

#
# cmake -DTEST_midas_api_upload_perform_test:BOOL=ON -P MIDASAPICore.cmake
#
function(midas_api_upload_perform_test)

  _midas_api_test_prerequisites()

  set(filename "midas_api_upload_perform_test.txt")
  set(item_filepath ${CMAKE_CURRENT_BINARY_DIR}/${filename})
  file(WRITE ${item_filepath} "parentid: ${PARENTID} - filename:${filename}")
  file(MD5 ${item_filepath} checksum)

  midas_api_item_create(
    API_URL ${API_URL}
    API_EMAIL ${API_EMAIL}
    API_KEY ${API_KEY}
    PARENTID ${PARENTID}
    NAME ${filename}
    RESULT_VARNAME itemid
    )

  message("itemid:${itemid}")

  midas_api_upload_generatetoken(
    API_URL ${API_URL}
    API_EMAIL ${API_EMAIL}
    API_KEY ${API_KEY}
    ITEMID ${itemid}
    FILENAME ${filename}
    CHECKSUM ${checksum}
    RESULT_VARNAME generatetoken
    )

  message("generatetoken:${generatetoken}")

  midas_api_upload_perform(
    API_URL ${API_URL}
    UPLOADTOKEN ${generatetoken}
    FOLDERID ${PARENTID}
    ITEMID ${itemid}
    ITEM_FILEPATH ${item_filepath}
    RESULT_VARNAME output
    )

  file(REMOVE ${item_filepath})

  set(expected_output "ok")
  if(NOT "${output}" STREQUAL "${expected_output}")
    message(FATAL_ERROR "Problem with midas_api_upload_perform()\n"
                        "output:${output}\n"
                        "expected_output:${expected_output}")
  endif()

  message("SUCCESS - filename:${filename} uploaded.")
endfunction()
list(APPEND ALL_TESTS midas_api_upload_perform_test)
if(TEST_midas_api_upload_perform_test)
  midas_api_upload_perform_test()
endif()

#
# cmake -DTEST_midas_api_item_upload_test:BOOL=ON -P MIDASAPICore.cmake
#
function(midas_api_item_upload_test)

  _midas_api_test_prerequisites()

  set(item_filepath ${CMAKE_CURRENT_BINARY_DIR}/midas_api_item_upload_test.txt)
  file(WRITE ${item_filepath} "This is the content of a file within folderid: ${PARENTID}")

  midas_api_item_upload(
    API_URL ${API_URL}
    API_EMAIL ${API_EMAIL}
    API_KEY ${API_KEY}
    FOLDERID ${PARENTID}
    ITEM_FILEPATH ${item_filepath}
    RESULT_VARNAME output
    )

  set(expected_output "ok")
  if(NOT "${output}" STREQUAL "${expected_output}")
    message(FATAL_ERROR "Problem with midas_api_upload_perform()\n"
                        "output:${output}\n"
                        "expected_output:${expected_output}")
  endif()

  message("SUCCESS - filename: ${item_filepath} uploaded.")
endfunction()
list(APPEND ALL_TESTS midas_api_item_upload_test)
if(TEST_midas_api_item_upload_test)
  midas_api_item_upload_test()
endif()


#
# cmake -DTEST_all:BOOL=ON -P MIDASAPICore.cmake
#
function(midas_api_test_all)
  set(run_all_launcher ${CMAKE_CURRENT_BINARY_DIR}/MIDASAPICoreRunAllTests.cmake)
  set(run_all_tests "set(TEST_all OFF)\ninclude(\"${CMAKE_CURRENT_LIST_DIR}/MIDASAPICore.cmake\")\n\n")
  foreach(test ${ALL_TESTS})
    message(STATUS "Preparing test: ${test}")
    set(run_all_tests "${run_all_tests}message(STATUS \"Running test: ${test}\")\n${test}()\n\n")
  endforeach()
  file(WRITE ${run_all_launcher} ${run_all_tests})
  include(${run_all_launcher})
  file(REMOVE "${run_all_launcher}")
endfunction()
if(TEST_all)
  midas_api_test_all()
endif()
