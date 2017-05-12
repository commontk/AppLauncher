FROM commontk/qt-static:4.8.6-centos-5.5
MAINTAINER CommonTK Community <ctk-developers@commontk.org>
# Build and package the CTK AppLauncher

WORKDIR /usr/src

RUN git clone https://github.com/commontk/AppLauncher.git
VOLUME /usr/src/AppLauncher

RUN mkdir /usr/src/AppLauncher-build
WORKDIR /usr/src/AppLauncher-build
ADD docker-build-package.sh /usr/bin/build-package.sh
RUN /usr/bin/build-package.sh
VOLUME /usr/src/AppLauncher-build
