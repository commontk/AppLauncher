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

# Check for non-defined var
foreach(var TARGET_NAME TARGET_SUBDIR CMAKE_EXECUTABLE_SUFFIX)
  if(NOT DEFINED ${var})
    message(FATAL_ERROR "${var} not specified when calling ctkAppLauncher-configure.cmake")
  endif()
endforeach()

macro(_replace_cfg_intdir_in_settings setting_type)
  # Replace <CMAKE_CFG_INTDIR> with the appropriate value
  set(settings_file CTKAppLauncher-${TARGET_NAME}-${setting_type}-settings)

  file(READ ${settings_file}.cmake tmp_var)
  string(REPLACE "<CMAKE_CFG_INTDIR>" "${TARGET_SUBDIR}" tmp_var ${tmp_var})
  file(WRITE ${settings_file}_updated.cmake ${tmp_var})

  include(${settings_file}_updated.cmake)
endmacro()

#-----------------------------------------------------------------------------
# Settings common to build and install tree
#-----------------------------------------------------------------------------

set(CTKAPPLAUNCHER_APPLICATION_EXECUTABLE_NAME ${TARGET_NAME}${CMAKE_EXECUTABLE_SUFFIX})

_replace_cfg_intdir_in_settings("common")


#-----------------------------------------------------------------------------
# Settings specific to the build tree.
#-----------------------------------------------------------------------------

_replace_cfg_intdir_in_settings("build")

set(CTKAPPLAUNCHER_APPLICATION_SUBDIR "${CTKAPPLAUNCHER_APPLICATION_SUBDIR}${TARGET_SUBDIR}/")
configure_file(
  ${CTKAPPLAUNCHER_SETTINGS_TEMPLATE}
  ${CTKAPPLAUNCHER_DESTINATION_DIR}/${CTKAPPLAUNCHER_APPLICATION_NAME}LauncherSettings.ini
  @ONLY
  )


#-----------------------------------------------------------------------------
# Settings specific to the install tree.
#-----------------------------------------------------------------------------

_replace_cfg_intdir_in_settings("install")

configure_file(
  ${CTKAPPLAUNCHER_SETTINGS_TEMPLATE}
  ${CTKAPPLAUNCHER_DESTINATION_DIR}/${CTKAPPLAUNCHER_APPLICATION_NAME}LauncherSettingsToInstall.ini
  @ONLY
  )
