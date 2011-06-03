PROJECT(CTKAppLauncherBase)

#
# See <SOURCE>/CMake/ctkalMacroBuildLib.cmake for details
#

#SET(KIT_export_directive "CTK_APPLAUNCHER_BASE_EXPORT")

# Additional directories to include
SET(KIT_include_directories
  )
  
# Source files
SET(KIT_SRCS
  ctkAppLauncher.cpp
  ctkAppLauncher.h
  ctkAppLauncher_p.h
  ctkCommandLineParser.cpp
  ctkCommandLineParser.h
  ctkSettingsHelper.cpp
  ctkSettingsHelper.h
  )

# Headers that should run through moc
SET(KIT_MOC_SRCS
  ctkAppLauncher.h
  ctkAppLauncher_p.h
  )

# UI files
SET(KIT_UI_FORMS
)

# Resources
SET(KIT_resources
  Resources/CTKAppLauncherBase.qrc
  )

# Target libraries
SET(KIT_target_libraries
  ${QT_LIBRARIES}
  )

ctkMacroBuildLib(
  NAME ${PROJECT_NAME}
  #EXPORT_DIRECTIVE ${KIT_export_directive}
  INCLUDE_DIRECTORIES ${KIT_include_directories}
  SRCS ${KIT_SRCS}
  MOC_SRCS ${KIT_MOC_SRCS}
  UI_FORMS ${KIT_UI_FORMS}
  TARGET_LIBRARIES ${KIT_target_libraries}
  RESOURCES ${KIT_resources}
  LIBRARY_TYPE "STATIC"
  LABEL ctkAppLauncher
  )

# Testing
IF(BUILD_TESTING)
  ADD_SUBDIRECTORY(Testing)
ENDIF(BUILD_TESTING)

