FROM commontk/qt-static:4.8.6-centos-5.5
MAINTAINER CommonTK Community <ctk-developers@commontk.org>
# Build and package the CTK AppLauncher

WORKDIR /home/circleci/project

# Install basic tools
RUN yum install -y wget tar gcc gcc-c++ make

# Set CMake version
ENV CMAKE_VERSION=3.27.9

# Download and install
RUN wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz && \
    tar -xzf cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz && \
    mv cmake-${CMAKE_VERSION}-linux-x86_64 /opt/cmake && \
    ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake && \
    rm cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz

# Verify
RUN cmake --version

RUN git clone https://github.com/commontk/AppLauncher.git
VOLUME /home/circleci/project/AppLauncher

RUN mkdir /home/circleci/project/AppLauncher-build
WORKDIR /home/circleci/project/AppLauncher-build
ADD docker-build-package.sh /usr/bin/build-package.sh
RUN /usr/bin/build-package.sh
VOLUME /home/circleci/project/AppLauncher-build
