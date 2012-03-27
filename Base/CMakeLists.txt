project(CTKAppLauncherBase)

#
# See <SOURCE>/CMake/ctkalMacroBuildLib.cmake for details
#

# Additional directories to include
set(KIT_include_directories
  )

# Source files
set(KIT_SRCS
  ctkAppArguments.cpp
  ctkAppArguments.h
  ctkAppLauncher.cpp
  ctkAppLauncher.h
  ctkAppLauncher_p.h
  ctkCommandLineParser.cpp
  ctkCommandLineParser.h
  ctkSettingsHelper.cpp
  ctkSettingsHelper.h
  )

# Headers that should run through moc
set(KIT_MOC_SRCS
  ctkAppLauncher.h
  ctkAppLauncher_p.h
  )

# UI files
set(KIT_UI_FORMS
)

# Resources
set(KIT_resources
  Resources/CTKAppLauncherBase.qrc
  )

# Target libraries
set(KIT_target_libraries
  ${QT_LIBRARIES}
  )

ctkMacroBuildLib(
  NAME ${PROJECT_NAME}
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
if(BUILD_TESTING)
  add_subdirectory(Testing)
endif()

