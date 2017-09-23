#
# ctkAppLauncher-configure
#

#
# Depends on:
#  ctkAppLauncher.cmake
#

#
# The different parameters are:
#
#    TARGET_NAME ...............:
#
#    TARGET_SUBDIR .............:
#
#    CMAKE_EXECUTABLE_SUFFIX ...:
#
#    BUILD_SETTINGS_FILEPATH ...:
#
#    INSTALL_SETTINGS_FILEPATH .:
#

# Check for non-defined var
foreach(var TARGET_NAME TARGET_SUBDIR CMAKE_EXECUTABLE_SUFFIX BUILD_SETTINGS_FILEPATH INSTALL_SETTINGS_FILEPATH)
  if(NOT DEFINED ${var})
    message(FATAL_ERROR "${var} not specified when calling ctkAppLauncher-configure.cmake")
  endif()
endforeach()

macro(_replace_cfg_intdir_in_settings settings_filepath updated_settings_filepath)
  # Replace <CMAKE_CFG_INTDIR> with the appropriate value
  file(READ ${settings_filepath} tmp_var)
  string(REPLACE "<CMAKE_CFG_INTDIR>" "${TARGET_SUBDIR}" tmp_var ${tmp_var})
  file(WRITE ${updated_settings_filepath} ${tmp_var})
endmacro()

#-----------------------------------------------------------------------------
# Settings common to build and install tree
#-----------------------------------------------------------------------------

set(CTKAPPLAUNCHER_APPLICATION_EXECUTABLE_NAME ${TARGET_NAME}${CMAKE_EXECUTABLE_SUFFIX})


#-----------------------------------------------------------------------------
# Settings specific to the build tree.
#-----------------------------------------------------------------------------

set(BUILD_SETTINGS_FILEPATH_UPDATED ${BUILD_SETTINGS_FILEPATH}.updated)

_replace_cfg_intdir_in_settings(
  ${BUILD_SETTINGS_FILEPATH}
  ${BUILD_SETTINGS_FILEPATH_UPDATED}
  )

include(${BUILD_SETTINGS_FILEPATH_UPDATED})

set(CTKAPPLAUNCHER_APPLICATION_SUBDIR "${CTKAPPLAUNCHER_APPLICATION_SUBDIR}${TARGET_SUBDIR}/")
configure_file(
  ${CTKAPPLAUNCHER_SETTINGS_TEMPLATE}
  ${CTKAPPLAUNCHER_DESTINATION_DIR}/${CTKAPPLAUNCHER_APPLICATION_NAME}LauncherSettings.ini
  @ONLY
  )


#-----------------------------------------------------------------------------
# Settings specific to the install tree.
#-----------------------------------------------------------------------------

set(INSTALL_SETTINGS_FILEPATH_UPDATED ${INSTALL_SETTINGS_FILEPATH}.updated)

_replace_cfg_intdir_in_settings(
  ${INSTALL_SETTINGS_FILEPATH}
  ${INSTALL_SETTINGS_FILEPATH_UPDATED}
  )

include(${INSTALL_SETTINGS_FILEPATH_UPDATED})

configure_file(
  ${CTKAPPLAUNCHER_SETTINGS_TEMPLATE}
  ${CTKAPPLAUNCHER_DESTINATION_DIR}/${CTKAPPLAUNCHER_APPLICATION_NAME}LauncherSettingsToInstall.ini
  @ONLY
  )
