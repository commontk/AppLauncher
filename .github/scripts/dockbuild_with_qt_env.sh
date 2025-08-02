#!/usr/bin/env bash

set -euo pipefail

err() { echo -e >&2 "ERROR: $*\n"; }
die() { err "$@"; exit 1; }

if [[ $# -lt 1 ]]; then
  die "Usage: $0 <qt-archive-basename> [args...]"
fi

qt_archive_basename="$1"
shift 1

Qt5_DIR=/work/${qt_archive_basename}

if [[ ! -d "$Qt5_DIR" ]]; then
  die "Qt5_DIR env. variable is set to nonexistent directory: '${Qt5_DIR}'"
fi

# Rename "Qt5Gui_QVncIntegrationPlugin.cmake" to workaround the following error:
#
# CMake Error at /work/qt-5.15.2-manylinux2.28-static-x86_64/lib/cmake/Qt5Gui/Qt5Gui_QVncIntegrationPlugin.cmake:8 (find_package):
#   Could not find a package configuration file provided by "Qt5Network"
#   (requested version 1.0.0) with any of the following names:
#
#     Qt5NetworkConfig.cmake
#     qt5network-config.cmake
#
#   Add the installation prefix of "Qt5Network" to CMAKE_PREFIX_PATH or set
#   "Qt5Network_DIR" to a directory containing one of the above files.  If
#   "Qt5Network" provides a separate development package or SDK, be sure it has
#   been installed.
# Call Stack (most recent call first):
#   /work/qt-5.15.2-manylinux2.28-static-x86_64/lib/cmake/Qt5Gui/Qt5GuiConfig.cmake:394 (include)
#   /work/qt-5.15.2-manylinux2.28-static-x86_64/lib/cmake/Qt5Widgets/Qt5WidgetsConfig.cmake:219 (find_package)
#   /work/qt-5.15.2-manylinux2.28-static-x86_64/lib/cmake/Qt5/Qt5Config.cmake:28 (find_package)
#   CMakeLists.txt:267 (find_package)
#
if [[ -f ${Qt5_DIR}/lib/cmake/Qt5Gui/Qt5Gui_QVncIntegrationPlugin.cmake ]]; then
  mv \
    ${Qt5_DIR}/lib/cmake/Qt5Gui/Qt5Gui_QVncIntegrationPlugin.cmake \
    ${Qt5_DIR}/lib/cmake/Qt5Gui/Qt5Gui_QVncIntegrationPlugin.cmake.disabled
fi

gosu root dnf install -y \
  libxkbcommon-devel \
  libxkbcommon-x11-devel \
  xcb-util-devel \
  xcb-util-image-devel \
  xcb-util-keysyms-devel \
  xcb-util-renderutil-devel \
  xcb-util-wm-devel

$@
