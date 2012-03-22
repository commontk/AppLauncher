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
    message(SEND_ERROR "${var} not specified when calling ctkAppLauncher-configure.cmake")
  endif()
endforeach()

#-----------------------------------------------------------------------------
# Settings common to build and install tree
#-----------------------------------------------------------------------------

set(CTKAPPLAUNCHER_APPLICATION_EXECUTABLE_NAME ${TARGET_NAME}${CMAKE_EXECUTABLE_SUFFIX})

# Replace <CMAKE_CFG_INTDIR> with the appropriate value
set(settings_file CTKAppLauncher-${TARGET_NAME}-common-settings)

file(READ ${settings_file}.cmake tmp_var)
string(REPLACE "<CMAKE_CFG_INTDIR>" "${TARGET_SUBDIR}" tmp_var ${tmp_var})
file(WRITE ${settings_file}_updated.cmake ${tmp_var})

include(${settings_file}_updated.cmake)

# Copy launcher executable into the build tree
execute_process(COMMAND ${CMAKE_COMMAND} -E copy_if_different 
  ${CTKAPPLAUNCHER_EXECUTABLE} 
  ${CTKAPPLAUNCHER_DESTINATION_DIR}/${CTKAPPLAUNCHER_APPLICATION_NAME}${CMAKE_EXECUTABLE_SUFFIX})



#-----------------------------------------------------------------------------
# Settings specific to the build tree.
#-----------------------------------------------------------------------------

# Replace <CMAKE_CFG_INTDIR> with the appropriate value
set(settings_file CTKAppLauncher-${TARGET_NAME}-buildtree-settings)

file(READ ${settings_file}.cmake tmp_var)
string(REPLACE "<CMAKE_CFG_INTDIR>" "${TARGET_SUBDIR}" tmp_var ${tmp_var})
file(WRITE ${settings_file}_updated.cmake ${tmp_var})

include(${settings_file}_updated.cmake)

set(CTKAPPLAUNCHER_APPLICATION_SUBDIR "${CTKAPPLAUNCHER_APPLICATION_SUBDIR}${TARGET_SUBDIR}/")
configure_file(
  ${CTKAPPLAUNCHER_SETTINGS_TEMPLATE}
  ${CTKAPPLAUNCHER_DESTINATION_DIR}/${CTKAPPLAUNCHER_APPLICATION_NAME}LauncherSettings.ini
  @ONLY
  )


#-----------------------------------------------------------------------------
# Settings specific to the install tree.
#-----------------------------------------------------------------------------

set(settings_file CTKAppLauncher-${TARGET_NAME}-installtree-settings)

file(READ ${settings_file}.cmake tmp_var)
string(REPLACE "<CMAKE_CFG_INTDIR>" "${TARGET_SUBDIR}" tmp_var ${tmp_var})
file(WRITE ${settings_file}_updated.cmake ${tmp_var})

include(${settings_file}_updated.cmake)

configure_file(
  ${CTKAPPLAUNCHER_SETTINGS_TEMPLATE}
  ${CTKAPPLAUNCHER_DESTINATION_DIR}/${CTKAPPLAUNCHER_APPLICATION_NAME}LauncherSettingsToInstall.ini
  @ONLY
  )
