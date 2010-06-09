#SET(KIT ${PROJECT_NAME})

#CREATE_TEST_SOURCELIST(Tests ${KIT}CppTests.cpp
  #ctkAppLauncherTest2.cpp
  #EXTRA_INCLUDE TestingMacros.h
#  )

#SET (TestsToRun ${Tests})
#REMOVE (TestsToRun ${KIT}CppTests.cpp)

#SET(LIBRARY_NAME )

#ADD_EXECUTABLE(${KIT}CppTests ${Tests})
#TARGET_LINK_LIBRARIES(${KIT}CppTests ${LIBRARY_NAME} ${CTK_BASE_LIBRARIES})

#SET( KIT_TESTS ${CPP_TEST_PATH}/${KIT}CppTests)
#IF(WIN32)
#  SET(KIT_TESTS ${CPP_TEST_PATH}/${CMAKE_BUILD_TYPE}/${KIT}CppTests)
#ENDIF(WIN32)

set(label ctkAppLauncher)

#MACRO( SIMPLE_TEST  TESTNAME )
#  ADD_TEST( ${TESTNAME} ${KIT_TESTS} ${TESTNAME} )
#  #SET_PROPERTY(TEST ${TESTNAME} PROPERTY LABELS ${label})
#ENDMACRO( SIMPLE_TEST  )

set(LAUNCHER_BINARY_DIR ${CTKAppLauncher_BINARY_DIR})
set(LAUNCHER_NAME ${PROJECT_NAME})
if ("${CMAKE_BUILD_TYPE}" STREQUAL "")
  set(LAUNCHER_BUILD_TYPE Debug)
else()
  set(LAUNCHER_BUILD_TYPE ${CMAKE_BUILD_TYPE})
endif()

set(APP4TEST_BUILD_TYPE "Release")
set(APP4TEST_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/App4Test)
set(APP4TEST_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/App4Test-build)

#
# Configure Tests
#
foreach(testid RANGE 1 5)
  configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/AppLauncherTest${testid}.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/AppLauncherTest${testid}.cmake
    @ONLY
    )
endforeach()

#
# Set variables
#
set(application_dir "${APP4TEST_BINARY_DIR}/bin")
if(WIN32)
  set(application_dir ${APP4TEST_BINARY_DIR}/${APP4TEST_BUILD_TYPE})
endif()
set(application_name App4Test)

#
# Add Tests
#

ADD_TEST(AppLauncherTest1 ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/AppLauncherTest1.cmake)
SET_PROPERTY(TEST AppLauncherTest1 PROPERTY LABELS ${label})

ADD_TEST(AppLauncherTest2 ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/AppLauncherTest2.cmake)
SET_TESTS_PROPERTIES(AppLauncherTest2 PROPERTIES DEPENDS AppLauncherTest1)
SET_PROPERTY(TEST AppLauncherTest2 PROPERTY LABELS ${label})

ADD_TEST(AppLauncherTest3 ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/AppLauncherTest3.cmake)
SET_TESTS_PROPERTIES(AppLauncherTest3 PROPERTIES DEPENDS AppLauncherTest1)
SET_PROPERTY(TEST AppLauncherTest3 PROPERTY LABELS ${label})

ADD_TEST(AppLauncherTest4 ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/AppLauncherTest4.cmake)
SET_TESTS_PROPERTIES(AppLauncherTest4 PROPERTIES DEPENDS AppLauncherTest1)
SET_PROPERTY(TEST AppLauncherTest4 PROPERTY LABELS ${label})

ADD_TEST(AppLauncherTest5 ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/AppLauncherTest5.cmake)
SET_TESTS_PROPERTIES(AppLauncherTest5 PROPERTIES DEPENDS AppLauncherTest1)
SET_PROPERTY(TEST AppLauncherTest5 PROPERTY LABELS ${label})

