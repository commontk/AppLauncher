FROM thewtex/centos-build:v1.0.0
MAINTAINER CommonTK Community <ctk-developers@commontk.org>
# Build and package the CTK AppLauncher

RUN yum update -y && \
  yum install -y \
    libX11-devel \
    libXt-devel \
    libXext-devel \
    libXrender-devel

WORKDIR /usr/src

RUN wget http://packages.kitware.com/download/item/6175/qt-everywhere-opensource-src-4.8.6.tar.gz && \
 md5=$(md5sum ./qt-everywhere-opensource-src-4.8.6.tar.gz | awk '{ print $1 }') && \
 [ $md5 == "2edbe4d6c2eff33ef91732602f3518eb" ] && \
 tar -xzvf qt-everywhere-opensource-src-4.8.6.tar.gz && \
 rm qt-everywhere-opensource-src-4.8.6.tar.gz && \
 mv qt-everywhere-opensource-src-4.8.6 qt-everywhere-opensource-release-src-4.8.6 && \
 mkdir qt-everywhere-opensource-release-build-4.8.6 && \
 cd qt-everywhere-opensource-release-src-4.8.6 && \
 LD=${CXX} ./configure -prefix /usr/src/qt-everywhere-opensource-release-build-4.8.6 \
   -confirm-license -opensource \
   -static \
   -release \
   -no-largefile \
   -no-exceptions \
   -no-accessibility \
   -no-sql-db2 \
   -no-sql-ibase \
   -no-sql-mysql \
   -no-sql-oci \
   -no-sql-odbc \
   -no-sql-psql \
   -no-sql-sqlite \
   -no-sql-sqlite2 \
   -no-sql-sqlite_symbian \
   -no-sql-tds \
   -no-qt3support \
   -no-xmlpatterns \
   -no-multimedia \
   -no-audio-backend \
   -no-phonon \
   -no-phonon-backend \
   -no-svg \
   -no-webkit \
   -no-javascript-jit \
   -no-script \
   -no-scripttools \
   -no-declarative \
   -no-gif \
   -no-libtiff \
   -no-libmng \
   -no-openssl \
   -no-nis \
   -no-cups \
   -no-dbus \
   -no-opengl \
   -no-openvg \
   -nomake demos \
   -nomake examples \
   -no-gtkstyle && \
  make -j$(grep -c processor /proc/cpuinfo) && \
  make install && \
  find . -name '*.o' -delete

RUN git clone https://github.com/commontk/AppLauncher.git
RUN mkdir /usr/src/AppLauncher-build
WORKDIR /usr/src/AppLauncher-build
RUN cmake \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DBUILD_TESTING:BOOL=ON \
    -DQT_QMAKE_EXECUTABLE:FILEPATH=/usr/src/qt-everywhere-opensource-release-build-4.8.6/bin/qmake \
      /usr/src/AppLauncher && \
  make -j$(grep -c processor /proc/cpuinfo) && \
  make package
