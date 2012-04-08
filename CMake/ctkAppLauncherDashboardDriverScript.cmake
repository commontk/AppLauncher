

#
# Included from a dashboard script, this cmake file will drive the configure and build
# steps of the different CTK sub-project (library, application or plugins)
#

# The following variable are expected to be define in the top-level script:
set(expected_variables
  ADDITIONNAL_CMAKECACHE_OPTION
  CTEST_NOTES_FILES
  CTEST_SITE
  CTEST_DASHBOARD_ROOT
  CTEST_CMAKE_GENERATOR
  WITH_MEMCHECK
  WITH_COVERAGE
  WITH_DOCUMENTATION
  CTEST_BUILD_CONFIGURATION
  CTEST_TEST_TIMEOUT
  CTEST_BUILD_FLAGS
  TEST_TO_EXCLUDE_REGEX
  CTEST_PROJECT_NAME
  CTEST_SOURCE_DIRECTORY
  CTEST_BINARY_DIRECTORY
  CTEST_BUILD_NAME
  SCRIPT_MODE
  CTEST_COVERAGE_COMMAND
  CTEST_MEMORYCHECK_COMMAND
  CTEST_GIT_COMMAND
  QT_QMAKE_EXECUTABLE
  )
if(WITH_DOCUMENTATION)
  list(APPEND expected_variables DOCUMENTATION_ARCHIVES_OUTPUT_DIRECTORY)
endif()

if(NOT DEFINED MIDAS_API_URL)
  set(MIDAS_API_URL "http://midas3.kitware.com/midas")
endif()
if(NOT DEFINED MIDAS_SERVER_EXPERIMENTAL_PACKAGES_FOLDERID)
  set(MIDAS_SERVER_EXPERIMENTAL_PACKAGES_FOLDERID 1227)
endif()
if(NOT DEFINED MIDAS_SERVER_NIGHTLY_PACKAGES_FOLDERID)
  set(MIDAS_SERVER_NIGHTLY_PACKAGES_FOLDERID 1228)
endif()
if(NOT DEFINED MIDAS_SERVER_CONTINUOUS_PACKAGES_FOLDERID)
  set(MIDAS_SERVER_CONTINUOUS_PACKAGES_FOLDERID 1229)
endif()

foreach(var ${expected_variables})
  if(NOT DEFINED ${var})
    message(FATAL_ERROR "Variable ${var} should be defined in top-level script !")
  endif()
endforeach()

# Make sure command 'ctest_upload' is available if WITH_PACKAGES is True
if(WITH_PACKAGES)
  if(NOT COMMAND ctest_upload)
    message(FATAL_ERROR "Failed to enable option WITH_PACKAGES ! CMake ${CMAKE_VERSION} doesn't support 'ctest_upload' command.")
  endif()
endif()

set(git_repository http://github.com/commontk/AppLauncher.git)

# Should binary directory be cleaned?
set(empty_binary_directory FALSE)

# Attempt to build and test also if 'ctest_update' returned an error
set(force_build FALSE)

# Set model options
set(model "")
if(SCRIPT_MODE STREQUAL "experimental")
  set(empty_binary_directory FALSE)
  set(force_build TRUE)
  set(model Experimental)
elseif(SCRIPT_MODE STREQUAL "continuous")
  set(empty_binary_directory TRUE)
  set(force_build FALSE)
  set(model Continuous)
elseif(SCRIPT_MODE STREQUAL "nightly")
  set(empty_binary_directory TRUE)
  set(force_build TRUE)
  set(model Nightly)
else()
  message(FATAL_ERROR "Unknown script mode: '${SCRIPT_MODE}'. Script mode should be either 'experimental', 'continuous' or 'nightly'")
endif()
string(TOUPPER ${model} model_uc)
set(track ${model})
if(WITH_PACKAGES)
  set(track "${track}-Packages")
endif()
set(track ${CTEST_TRACK_PREFIX}${track}${CTEST_TRACK_SUFFIX})

set(CTEST_USE_LAUNCHERS 0)
if(CTEST_CMAKE_GENERATOR MATCHES ".*Makefiles.*")
  set(CTEST_USE_LAUNCHERS 1)
endif()

if(empty_binary_directory)
  message("Directory ${CTEST_BINARY_DIRECTORY} cleaned !")
  ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
endif()

if(NOT EXISTS "${CTEST_SOURCE_DIRECTORY}")
  set(CTEST_CHECKOUT_COMMAND "${CTEST_GIT_COMMAND} clone ${git_repository} ${CTEST_SOURCE_DIRECTORY}")
endif()

set(CTEST_UPDATE_COMMAND "${CTEST_GIT_COMMAND}")

# Macro allowing to set a variable to its default value only if not already defined
macro(setIfNotDefined var defaultvalue)
  if(NOT DEFINED ${var})
    set(${var} "${defaultvalue}")
  endif()
endmacro()

# The following variable can be used while testing the driver scripts
setIfNotDefined(run_ctest_submit TRUE)
setIfNotDefined(run_ctest_with_update TRUE)
setIfNotDefined(run_ctest_with_configure TRUE)
setIfNotDefined(run_ctest_with_build TRUE)
setIfNotDefined(run_ctest_with_test TRUE)
setIfNotDefined(run_ctest_with_coverage TRUE)
setIfNotDefined(run_ctest_with_memcheck TRUE)
setIfNotDefined(run_ctest_with_packages TRUE)
setIfNotDefined(run_ctest_with_upload TRUE)
setIfNotDefined(run_ctest_with_notes TRUE)

#
# run_ctest macro
#
macro(run_ctest)
  ctest_start(${model} TRACK ${track})

  if(run_ctest_with_update)
    ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}" RETURN_VALUE res)
  endif()

  # force a build if this is the first run and the build dir is empty
  if(NOT EXISTS "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt")
    message("First time build - Initialize CMakeCache.txt")
    set(res 1)

    # Write initial cache.
    file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" "
CTEST_USE_LAUNCHERS:BOOL=${CTEST_USE_LAUNCHERS}
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
QT_QMAKE_EXECUTABLE:FILEPATH=${QT_QMAKE_EXECUTABLE}
WITH_COVERAGE:BOOL=${WITH_COVERAGE}
DOCUMENTATION_TARGET_IN_ALL:BOOL=${WITH_DOCUMENTATION}
DOCUMENTATION_ARCHIVES_OUTPUT_DIRECTORY:PATH=${DOCUMENTATION_ARCHIVES_OUTPUT_DIRECTORY}
${ADDITIONNAL_CMAKECACHE_OPTION}
")
  endif()

  if(res GREATER 0 OR force_build)

    if(run_ctest_with_update AND run_ctest_submit)
      ctest_submit(PARTS Update)
    endif()

    #-----------------------------------------------------------------------------
    # Configure
    #-----------------------------------------------------------------------------
    if(run_ctest_with_configure)
      message("----------- [ Configure ${CTEST_PROJECT_NAME} ] -----------")

      set(label ctkAppLauncher)

      set_property(GLOBAL PROPERTY SubProject ${label})
      set_property(GLOBAL PROPERTY Label ${label})

      ctest_configure(BUILD "${CTEST_BINARY_DIRECTORY}")
      ctest_read_custom_files("${CTEST_BINARY_DIRECTORY}")
      if(run_ctest_submit)
        ctest_submit(PARTS Configure)
      endif()
    endif()

    #-----------------------------------------------------------------------------
    # Build top level
    #-----------------------------------------------------------------------------
    set(build_errors)
    if(run_ctest_with_build)
      message("----------- [ Build ${CTEST_PROJECT_NAME} ] -----------")
      ctest_build(BUILD "${CTEST_BINARY_DIRECTORY}" NUMBER_ERRORS build_errors APPEND)
      if(run_ctest_submit)
        ctest_submit(PARTS Build)
      endif()
    endif()

    #-----------------------------------------------------------------------------
    # Test
    #-----------------------------------------------------------------------------
    if(run_ctest_with_test)
      message("----------- [ Test ${CTEST_PROJECT_NAME} ] -----------")
      ctest_test(
        BUILD "${CTEST_BINARY_DIRECTORY}"
        INCLUDE_LABEL ${label}
        PARALLEL_LEVEL 8
        EXCLUDE ${TEST_TO_EXCLUDE_REGEX})
      # runs only tests that have a LABELS property matching "${label}"
      if(run_ctest_submit)
        ctest_submit(PARTS Test)
      endif()
    endif()

    #-----------------------------------------------------------------------------
    # Global coverage ...
    #-----------------------------------------------------------------------------
    if(WITH_COVERAGE AND CTEST_COVERAGE_COMMAND AND run_ctest_with_coverage)
      message("----------- [ Global coverage ] -----------")
      ctest_coverage(BUILD "${CTEST_BINARY_DIRECTORY}")
      if(run_ctest_submit)
        ctest_submit(PARTS Coverage)
      endif()
    endif()

    #-----------------------------------------------------------------------------
    # Global dynamic analysis ...
    #-----------------------------------------------------------------------------
    if(WITH_MEMCHECK AND CTEST_MEMORYCHECK_COMMAND AND run_ctest_with_memcheck)
      message("----------- [ Global memcheck ] -----------")
      ctest_memcheck(BUILD "${CTEST_BINARY_DIRECTORY}")
      if(run_ctest_submit)
        ctest_submit(PARTS MemCheck)
      endif()
    endif()

    #-----------------------------------------------------------------------------
    # Create packages / installers ...
    #-----------------------------------------------------------------------------
    if(WITH_PACKAGES AND (run_ctest_with_packages OR run_ctest_with_upload))
      message("----------- [ WITH_PACKAGES and UPLOAD ] -----------")

      if(build_errors GREATER "0")
        message("Build Errors Detected: ${build_errors}. Aborting package generation")
      else()

        # Update CMake module path so that our custom macros/functions can be included.
        set(CMAKE_MODULE_PATH ${CTEST_SOURCE_DIRECTORY}/CMake ${CMAKE_MODULE_PATH})

        # Include locally available module(s)
        include(MIDASAPICore)

        # Download and include CTestPackage
        set(url http://viewvc.slicer.org/viewvc.cgi/Slicer4/trunk/CMake/CTestPackage.cmake?revision=19739&view=co)
        set(dest ${CTEST_BINARY_DIRECTORY}/CTestPackage.cmake)
        download_file(${url} ${dest})
        include(${dest})

        # Download and include MIDASCTestUploadURL
        set(url http://viewvc.slicer.org/viewvc.cgi/Slicer4/trunk/CMake/MIDASCTestUploadURL.cmake?revision=19739&view=co)
        set(dest ${CTEST_BINARY_DIRECTORY}/MIDASCTestUploadURL.cmake)
        download_file(${url} ${dest})
        include(${dest})

        set(packages)
        if(run_ctest_with_packages)
          message("Packaging ...")
          ctest_package(
            BINARY_DIR ${CTEST_BINARY_DIRECTORY}
            CONFIG ${CTEST_BUILD_CONFIGURATION}
            RETURN_VAR packages)
        else()
          set(packages ${CMAKE_CURRENT_LIST_FILE})
        endif()

        if(run_ctest_with_upload)
          message("Uploading ...")
          foreach(p ${packages})
            get_filename_component(package_name "${p}" NAME)
            set(midas_upload_status "fail")
            if(DEFINED MIDAS_API_URL
               AND DEFINED MIDAS_API_EMAIL
               AND DEFINED MIDAS_API_KEY)
              message("Uploading [${package_name}] on [${MIDAS_API_URL}]")
              midas_api_item_upload(
                API_URL ${MIDAS_API_URL}
                API_EMAIL ${MIDAS_API_EMAIL}
                API_KEY ${MIDAS_API_KEY}
                FOLDERID ${MIDAS_SERVER_${model_uc}_PACKAGES_FOLDERID}
                ITEM_FILEPATH ${p}
                RESULT_VARNAME midas_upload_status
                )
              if(midas_upload_status STREQUAL "ok")
                message("Uploading URL on CDash")
                set(MIDAS_PACKAGE_URL ${MIDAS_API_URL})
                midas_ctest_upload_url(${p}) # on success, upload a link to CDash
              endif()
            endif()
            if(NOT midas_upload_status STREQUAL "ok")
              message("        => Failed to upload item package ! See [${CMAKE_CURRENT_BINARY_DIR}/midas.*_response.txt] for more details.\n")
              message("Uploading [${package_name}] on CDash")
              ctest_upload(FILES ${p})
            endif()
            if(run_ctest_submit)
              ctest_submit(PARTS Upload)
            endif()
          endforeach()
        endif()

      endif()
    endif()

    #-----------------------------------------------------------------------------
    # Note should be at the end
    #-----------------------------------------------------------------------------
    if(run_ctest_with_notes AND run_ctest_submit)
      ctest_submit(PARTS Notes)
    endif()

  endif()
endmacro()

if(SCRIPT_MODE STREQUAL "continuous")
  while(${CTEST_ELAPSED_TIME} LESS 46800) # Lasts 13 hours (Assuming it starts at 9am, it will end around 10pm)
    set(START_TIME ${CTEST_ELAPSED_TIME})
    run_ctest()
    # Loop no faster than once every 5 minutes
    message("Wait for 5 minutes ...")
    ctest_sleep(${START_TIME} 300 ${CTEST_ELAPSED_TIME})
  endwhile()
else()
  run_ctest()
endif()
