include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/ConfiguredAppLauncherTestPrerequisites.cmake)

# Helper function
function(compare_files ACTUAL EXPECTED)
  file(READ ${ACTUAL} actual)
  string(STRIP "${actual}" actual)
  file(READ ${EXPECTED} expected)
  string(CONFIGURE "${expected}" expected @ONLY)
  string(STRIP "${expected}" expected)
  if(NOT "${actual}" STREQUAL "${expected}")
    message(FATAL_ERROR "Content validation failed:
  ACTUAL: ${ACTUAL}
EXPECTED: ${EXPECTED}

--
expected content:
${expected}

--
actual content:
${actual}
")
  endif()
endfunction()

# --------------------------------------------------------------------------
# Check the generated launcher configurations against the expected content.
compare_files(
  ${app4configurelaunchertest_binary_dir}/CTKAppLauncher-App4ConfigureLauncherTest-real-common-settings.cmake
  ${TEST_SOURCE_DIR}/App4ConfigureLauncherTest-expected-common-settings.cmake.in
  )

compare_files(
  ${app4configurelaunchertest_binary_dir}/CTKAppLauncher-App4ConfigureLauncherTest-real-build-settings.cmake
  ${TEST_SOURCE_DIR}/App4ConfigureLauncherTest-expected-build-settings.cmake.in
  )

compare_files(
  ${app4configurelaunchertest_binary_dir}/CTKAppLauncher-App4ConfigureLauncherTest-real-install-settings.cmake
  ${TEST_SOURCE_DIR}/App4ConfigureLauncherTest-expected-install-settings.cmake.in
  )

compare_files(
  ${app4configurelaunchertest_binary_dir}/App4ConfigureLauncherTestLauncherSettings.ini
  ${TEST_SOURCE_DIR}/App4ConfigureLauncherTestLauncherSettings.ini.expected.in
  )

compare_files(
  ${app4configurelaunchertest_binary_dir}/App4ConfigureLauncherTestLauncherSettingsToInstall.ini
  ${TEST_SOURCE_DIR}/App4ConfigureLauncherTestLauncherSettingsToInstall.ini.expected.in
  )
