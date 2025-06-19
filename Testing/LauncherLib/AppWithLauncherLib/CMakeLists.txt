cmake_minimum_required(VERSION 3.16.3)

project(AppWithLauncherLib)

# Disable warning C4996: [...] This function or variable may be unsafe. [...]
# To disable deprecation, use _CRT_SECURE_NO_WARNINGS. See online help for details
if(MSVC90)
  add_definitions(-D_CRT_SECURE_NO_WARNINGS)
endif()

find_package(CTKAppLauncherLib REQUIRED)

set(APPLAUNCHER_ROOT_DIR "${AppWithLauncherLib_SOURCE_DIR}/../../..")
set(CTKAppLauncherTestingHelper_SOURCE_DIR "${APPLAUNCHER_ROOT_DIR}/Base/Testing/Cpp/")

add_executable(${PROJECT_NAME} main.cpp
  ${CTKAppLauncherTestingHelper_SOURCE_DIR}/ctkAppLauncherTestingHelper.cpp
  ${CTKAppLauncherTestingHelper_SOURCE_DIR}/ctkAppLauncherTestingHelper.h
  ${CTKAppLauncherTestingHelper_SOURCE_DIR}/ctkAppLauncherTestingHelper.txx
  )
target_include_directories(${PROJECT_NAME} PUBLIC
  ${CTKAppLauncherTestingHelper_SOURCE_DIR}
  )
target_link_libraries(${PROJECT_NAME} PUBLIC
  ${CTKAppLauncherLib_LIBRARIES}
  )
