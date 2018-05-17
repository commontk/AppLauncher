#!/bin/sh

set -ex

mkdir -p /usr/src/AppLauncher-build
cd /usr/src/AppLauncher-build
rm -rf *

cmake \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DBUILD_TESTING:BOOL=ON \
  -DQT_QMAKE_EXECUTABLE:FILEPATH=/usr/src/qt-everywhere-opensource-release-build-4.8.6/bin/qmake \
    /usr/src/AppLauncher
make -j$(grep -c processor /proc/cpuinfo)
make package
ctest -L 'CompilerRequired' -j$(grep -c processor /proc/cpuinfo)
