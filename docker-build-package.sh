#!/bin/sh

set -ex


# Set CMake version
export CMAKE_VERSION=3.27.9

# Download and install
wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz && \
    tar -xzf cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz && \
    mv cmake-${CMAKE_VERSION}-linux-x86_64 /opt/cmake && \
    ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake && \
    rm cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz

# Verify
cmake --version

mkdir -p /home/circleci/project/AppLauncher-build
cd /home/circleci/project/AppLauncher-build
rm -rf *

/opt/cmake/bin/cmake \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DBUILD_TESTING:BOOL=ON \
  -DQT_QMAKE_EXECUTABLE:FILEPATH=/usr/src/qt-everywhere-opensource-release-build-4.8.6/bin/qmake \
    /home/circleci/project/AppLauncher
make -j$(grep -c processor /proc/cpuinfo)
make package
/opt/cmake/bin/ctest -L 'CompilerRequired' -j$(grep -c processor /proc/cpuinfo)
