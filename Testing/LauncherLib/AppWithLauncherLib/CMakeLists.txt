cmake_minimum_required(VERSION 3.0)

project(AppWithLauncherLib)

# Disable warning C4996: [...] This function or variable may be unsafe. [...]
# To disable deprecation, use _CRT_SECURE_NO_WARNINGS. See online help for details
if(MSVC90)
  add_definitions(-D_CRT_SECURE_NO_WARNINGS)
endif()

find_package(CTKAppLauncherLib REQUIRED)

add_executable(${PROJECT_NAME} main.cpp)
target_link_libraries(${PROJECT_NAME} PUBLIC
  ${CTKAppLauncherLib_LIBRARIES}
  )
