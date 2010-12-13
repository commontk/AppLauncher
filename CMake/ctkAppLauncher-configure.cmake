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
FOREACH(var TARGET_NAME TARGET_SUBDIR CMAKE_EXECUTABLE_SUFFIX)
  IF(NOT DEFINED ${var})
    MESSAGE(SEND_ERROR "${var} not specified when calling ctkAppLauncher-configure.cmake")
  ENDIF()
ENDFOREACH()

# Settings common to build and install tree

SET(CTKAPPLAUNCHER_APPLICATION_EXECUTABLE_NAME ${TARGET_NAME}${CMAKE_EXECUTABLE_SUFFIX})
INCLUDE(CTKAppLauncher-${TARGET_NAME}-common-settings.cmake)

# Copy launcher executable into the build tree
EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} -E copy_if_different 
  ${CTKAPPLAUNCHER_EXECUTABLE} 
  ${CTKAPPLAUNCHER_DESTINATION_DIR}/${CTKAPPLAUNCHER_APPLICATION_NAME}${CMAKE_EXECUTABLE_SUFFIX})

# Settings specific to the build tree.

INCLUDE(CTKAppLauncher-${TARGET_NAME}-buildtree-settings.cmake)
SET(CTKAPPLAUNCHER_APPLICATION_SUBDIR "${CTKAPPLAUNCHER_APPLICATION_SUBDIR}${TARGET_SUBDIR}/")
CONFIGURE_FILE(
  ${CTKAPPLAUNCHER_SETTINGS_TEMPLATE}
  ${CTKAPPLAUNCHER_DESTINATION_DIR}/${CTKAPPLAUNCHER_APPLICATION_NAME}LauncherSettings.ini
  @ONLY
  )

# Settings specific to the install tree.
INCLUDE(CTKAppLauncher-${TARGET_NAME}-installtree-settings.cmake)
CONFIGURE_FILE(
  ${CTKAPPLAUNCHER_SETTINGS_TEMPLATE}
  ${CTKAPPLAUNCHER_DESTINATION_DIR}/${CTKAPPLAUNCHER_APPLICATION_NAME}LauncherSettingsToInstall.ini
  @ONLY
  )
