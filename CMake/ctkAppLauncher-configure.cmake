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
#    BUILD_SETTINGS_CONFIGURATION_FILEPATH
#
#    INSTALL_SETTINGS_CONFIGURATION_FILEPATH
#
#    TARGET_SUBDIR
#

# Check for non-defined var
foreach(var
    BUILD_SETTINGS_CONFIGURATION_FILEPATH
    INSTALL_SETTINGS_CONFIGURATION_FILEPATH
    TARGET_SUBDIR
    )
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
# Settings specific to the build tree.
#-----------------------------------------------------------------------------

set(updated_config_filepath ${BUILD_SETTINGS_CONFIGURATION_FILEPATH}.updated)

_replace_cfg_intdir_in_settings(
  ${BUILD_SETTINGS_CONFIGURATION_FILEPATH}
  ${updated_config_filepath}
  )

include(${updated_config_filepath})

set(CTKAPPLAUNCHER_APPLICATION_SUBDIR "${CTKAPPLAUNCHER_APPLICATION_SUBDIR}${TARGET_SUBDIR}/")
configure_file(
  ${CTKAPPLAUNCHER_SETTINGS_TEMPLATE}
  ${CTKAPPLAUNCHER_DESTINATION_DIR}/${CTKAPPLAUNCHER_APPLICATION_NAME}LauncherSettings.ini
  @ONLY
  )


#-----------------------------------------------------------------------------
# Settings specific to the install tree.
#-----------------------------------------------------------------------------

set(updated_config_filepath ${INSTALL_SETTINGS_CONFIGURATION_FILEPATH}.updated)

_replace_cfg_intdir_in_settings(
  ${INSTALL_SETTINGS_CONFIGURATION_FILEPATH}
  ${updated_config_filepath}
  )

include(${updated_config_filepath})

configure_file(
  ${CTKAPPLAUNCHER_SETTINGS_TEMPLATE}
  ${CTKAPPLAUNCHER_DESTINATION_DIR}/${CTKAPPLAUNCHER_APPLICATION_NAME}LauncherSettingsToInstall.ini
  @ONLY
  )
