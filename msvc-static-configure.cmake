
#
# This script was designed to be executed from the build directory:
#
#  cd build
#  cmake -DQt5_DIR:PATH=$Qt5_DIR -DCTKAppLauncher_SOURCE_DIR:PATH=$pwd.Path + "\.." -P ..\msvc-static-configure.cmake
#
# Static build of Qt5 may be download from
#
#  https://github.com/jcfr/qt-static-build/releases/tag/applauncher-5.11.2-vs2017
#

if(NOT EXISTS "${Qt5_DIR}")
  message(FATAL_ERROR "Qt5_DIR is set to a non-existent directory [${Qt5_DIR}]")
endif()
if(NOT EXISTS "${CTKAppLauncher_SOURCE_DIR}")
  message(FATAL_ERROR "CTKAppLauncher_SOURCE_DIR is set to a non-existent directory [${CTKAppLauncher_SOURCE_DIR}]")
endif()

set(QT_PREFIX_DIR "${Qt5_DIR}/../../../")
get_filename_component(QT_PREFIX_DIR ${QT_PREFIX_DIR} ABSOLUTE)
message(STATUS "Setting QT_PREFIX_DIR: ${QT_PREFIX_DIR}")

# Dependencies of QPA plugin needed for running GUI based application
# and avoid runtime error: qt.qpa.plugin: Could not find the Qt platform plugin "windows" in ""
set(qt_qpa_plugin_static_libraries
  ${QT_PREFIX_DIR}/lib/Qt5EventDispatcherSupport.lib
  ${QT_PREFIX_DIR}/lib/Qt5FontDatabaseSupport.lib
  ${QT_PREFIX_DIR}/lib/Qt5ThemeSupport.lib
  ${QT_PREFIX_DIR}/lib/Qt5WindowsUIAutomationSupport.lib
  Dwmapi.lib
  Imm32.lib
  )
set(qt_static_libraries
  # Qt
  ${QT_PREFIX_DIR}/lib/qtharfbuzz.lib
  ${QT_PREFIX_DIR}/lib/qtlibpng.lib
  ${QT_PREFIX_DIR}/lib/qtpcre2.lib
  ${QT_PREFIX_DIR}/plugins/platforms/qwindows.lib
  ${qt_qpa_plugin_static_libraries}
  # Windows API
  Netapi32.lib
  OLDNAMES.LIB
  Userenv.lib
  version.lib
  Winmm.lib
  Ws2_32.lib
  # C runtime - https://msdn.microsoft.com/en-us/library/abx4dbyh.aspx#Anchor_0
  libcmt.lib
  libvcruntime.lib
  libucrt.lib
  # C++ runtime - See https://msdn.microsoft.com/en-us/library/abx4dbyh.aspx#Anchor_1
  LIBCPMT.lib
  )
set(CMAKE_CXX_FLAGS_RELEASE "/MT /O2 /Ob2 /DNDEBUG")
set(INITIAL_CACHE "
ADDITIONAL_EXE_LINKER_FLAGS_RELEASE:STRING=/nodefaultlib
BUILD_TESTING:BOOL=1
CMAKE_CXX_FLAGS_RELEASE:STRING=${CMAKE_CXX_FLAGS_RELEASE}
CTKAppLauncher_QT_STATIC_LIBRARIES:STRING=${qt_static_libraries}
Qt5_DIR:PATH=${Qt5_DIR}"
)
file(WRITE CMakeCache.txt "${INITIAL_CACHE}")

set(ENV{LDFLAGS} "/INCREMENTAL:NO /LTCG")

execute_process(COMMAND ${CMAKE_COMMAND} -G "Visual Studio 15 2017" ${CTKAppLauncher_SOURCE_DIR})
