#!/bin/sh

cd /usr/src/AppLauncher-build
rm -rf *

cmake \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DBUILD_TESTING:BOOL=ON \
  -DQT_QMAKE_EXECUTABLE:FILEPATH=/usr/src/qt-everywhere-opensource-release-build-4.8.6/bin/qmake \
    /usr/src/AppLauncher || exit 1
make -j$(grep -c processor /proc/cpuinfo) || exit 1
make package || exit 1
