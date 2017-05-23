project(CTKAppLauncherBase)

#
# See <SOURCE>/CMake/ctkalMacroBuildLib.cmake for details
#

configure_file(
  ${CTKAppLauncher_SOURCE_DIR}/CMake/ctkAppLauncherVersionConfig.h.in
  ${CMAKE_CURRENT_BINARY_DIR}/ctkAppLauncherVersionConfig.h
  )

# Additional directories to include
set(KIT_include_directories
  )

# Source files
set(KIT_SRCS
  ctkAppLauncherSettings.cpp
  ctkAppLauncherSettings.h
  ctkAppLauncherSettings_p.h
  ctkSettingsHelper.cpp
  ctkSettingsHelper.h
  )

# Headers that should run through moc
set(KIT_MOC_SRCS
  ctkAppLauncherSettings.h
  ctkAppLauncherSettings_p.h
  )

# Resources
set(KIT_resources
  )

# Target libraries
set(KIT_target_libraries
  ${QT_LIBRARIES}
  )

ctkMacroBuildLib(
  NAME CTKAppLauncherLib
  INCLUDE_DIRECTORIES ${KIT_include_directories}
  INSTALL_INCLUDE_DIRECTORIES "${CTK_INSTALL_INCLUDE_DIR}"
  SRCS ${KIT_SRCS}
  MOC_SRCS ${KIT_MOC_SRCS}
  TARGET_LIBRARIES ${KIT_target_libraries}
  RESOURCES ${KIT_resources}
  LIBRARY_TYPE "STATIC"
  LABEL ctkAppLauncher
  )

# Export targets for build tree
set_property(GLOBAL APPEND PROPERTY CTKAppLauncherLib_TARGETS CTKAppLauncherLib)

# Export targets for install tree
if(CTK_BUILD_SHARED_LIBS OR CTKAppLauncher_INSTALL_LauncherLibrary)
  install(TARGETS CTKAppLauncherLib
    EXPORT CTKAppLauncherLibTargets
    RUNTIME DESTINATION ${CTK_INSTALL_BIN_DIR} COMPONENT Runtime
    LIBRARY DESTINATION ${CTK_INSTALL_LIB_DIR} COMPONENT Runtime
    ARCHIVE DESTINATION ${CTK_INSTALL_LIB_DIR} COMPONENT Development)
endif()

# Source files
set(KIT_SRCS
  ctkAppArguments.cpp
  ctkAppArguments.h
  ctkAppLauncher.cpp
  ctkAppLauncher.h
  ctkAppLauncher_p.h
  ctkCommandLineParser.cpp
  ctkCommandLineParser.h
  )

# Headers that should run through moc
set(KIT_MOC_SRCS
  ctkAppLauncher.h
  ctkAppLauncher_p.h
  ctkAppLauncherSettings.h
  ctkAppLauncherSettings_p.h
  )

# Resources
set(KIT_resources
  Resources/CTKAppLauncherBase.qrc
  )

# Target libraries
set(KIT_target_libraries
  ${QT_LIBRARIES}
  CTKAppLauncherLib
  )

ctkMacroBuildLib(
  NAME ${PROJECT_NAME}
  INCLUDE_DIRECTORIES ${KIT_include_directories}
  INSTALL_INCLUDE_DIRECTORIES "${CTK_INSTALL_INCLUDE_DIR}"
  SRCS ${KIT_SRCS}
  MOC_SRCS ${KIT_MOC_SRCS}
  TARGET_LIBRARIES ${KIT_target_libraries}
  RESOURCES ${KIT_resources}
  LIBRARY_TYPE "STATIC"
  LABEL ctkAppLauncher
  )

# Install rules
if(CTKAppLauncher_INSTALL_DEVELOPMENT)
  install(
    FILES
      ${CMAKE_CURRENT_BINARY_DIR}/ctkAppLauncherVersionConfig.h
    DESTINATION ${CTK_INSTALL_INCLUDE_DIR} COMPONENT Development
    )
endif()

# Testing
if(BUILD_TESTING)
  add_subdirectory(Testing)
endif()

