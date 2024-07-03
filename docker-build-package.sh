#!/bin/sh

set -ex

mkdir -p /home/circleci/project/AppLauncher-build
cd /home/circleci/project/AppLauncher-build
rm -rf *

cmake \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DBUILD_TESTING:BOOL=ON \
  -DQT_QMAKE_EXECUTABLE:FILEPATH=/usr/src/qt-everywhere-opensource-release-build-4.8.6/bin/qmake \
    /home/circleci/project/AppLauncher
make -j$(grep -c processor /proc/cpuinfo)
make package
ctest -L 'CompilerRequired' -j$(grep -c processor /proc/cpuinfo)
