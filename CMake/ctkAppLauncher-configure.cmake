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
#    TARGET_OUTPUT_NAME ........:
#
#    TARGET_SUBDIR .............:
#
#    CMAKE_EXECUTABLE_SUFFIX ...:
#

# Check for non-defined var
FOREACH(var TARGET_NAME TARGET_SUBDIR CMAKE_EXECUTABLE_SUFFIX)
  IF(NOT DEFINED ${var})
    MESSAGE(SEND_ERROR "${var} not specified when calling ctkAppLauncher-configure.cmake")
  ENDIF()
ENDFOREACH()

#-----------------------------------------------------------------------------
# Settings common to build and install tree
#-----------------------------------------------------------------------------

SET(CTKAPPLAUNCHER_APPLICATION_EXECUTABLE_NAME ${TARGET_OUTPUT_NAME}${CMAKE_EXECUTABLE_SUFFIX})

# Replace <CMAKE_CFG_INTDIR> with the appropriate value
SET(settings_file CTKAppLauncher-${TARGET_NAME}-common-settings)

FILE(READ ${settings_file}.cmake tmp_var)
STRING(REPLACE "<CMAKE_CFG_INTDIR>" "${TARGET_SUBDIR}" tmp_var ${tmp_var})
FILE(WRITE ${settings_file}_updated.cmake ${tmp_var})

INCLUDE(${settings_file}_updated.cmake)

# Copy launcher executable into the build tree
EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} -E copy_if_different 
  ${CTKAPPLAUNCHER_EXECUTABLE} 
  ${CTKAPPLAUNCHER_DESTINATION_DIR}/${CTKAPPLAUNCHER_APPLICATION_NAME}${CMAKE_EXECUTABLE_SUFFIX})



#-----------------------------------------------------------------------------
# Settings specific to the build tree.
#-----------------------------------------------------------------------------

# Replace <CMAKE_CFG_INTDIR> with the appropriate value
SET(settings_file CTKAppLauncher-${TARGET_NAME}-buildtree-settings)

FILE(READ ${settings_file}.cmake tmp_var)
STRING(REPLACE "<CMAKE_CFG_INTDIR>" "${TARGET_SUBDIR}" tmp_var ${tmp_var})
FILE(WRITE ${settings_file}_updated.cmake ${tmp_var})

INCLUDE(${settings_file}_updated.cmake)

SET(CTKAPPLAUNCHER_APPLICATION_SUBDIR "${CTKAPPLAUNCHER_APPLICATION_SUBDIR}${TARGET_SUBDIR}/")
CONFIGURE_FILE(
  ${CTKAPPLAUNCHER_SETTINGS_TEMPLATE}
  ${CTKAPPLAUNCHER_DESTINATION_DIR}/${CTKAPPLAUNCHER_APPLICATION_NAME}LauncherSettings.ini
  @ONLY
  )


#-----------------------------------------------------------------------------
# Settings specific to the install tree.
#-----------------------------------------------------------------------------

SET(settings_file CTKAppLauncher-${TARGET_NAME}-installtree-settings)

FILE(READ ${settings_file}.cmake tmp_var)
STRING(REPLACE "<CMAKE_CFG_INTDIR>" "${TARGET_SUBDIR}" tmp_var ${tmp_var})
FILE(WRITE ${settings_file}_updated.cmake ${tmp_var})

INCLUDE(${settings_file}_updated.cmake)

CONFIGURE_FILE(
  ${CTKAPPLAUNCHER_SETTINGS_TEMPLATE}
  ${CTKAPPLAUNCHER_DESTINATION_DIR}/${CTKAPPLAUNCHER_APPLICATION_NAME}LauncherSettingsToInstall.ini
  @ONLY
  )
