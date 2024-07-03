FROM commontk/qt-static:4.8.6-centos-5.5
MAINTAINER CommonTK Community <ctk-developers@commontk.org>
# Build and package the CTK AppLauncher

WORKDIR /home/circleci/project

RUN git clone https://github.com/commontk/AppLauncher.git
VOLUME /home/circleci/project/AppLauncher

RUN mkdir /home/circleci/project/AppLauncher-build
WORKDIR /home/circleci/project/AppLauncher-build
ADD docker-build-package.sh /usr/bin/build-package.sh
RUN /usr/bin/build-package.sh
VOLUME /home/circleci/project/AppLauncher-build
