#!/bin/sh
# Source: https://medium.com/@eplt/5-minutes-to-install-imagemagick-with-heic-support-on-ubuntu-18-04-digitalocean-fe2d09dcef1
sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list
apt-get update
apt-get install -y build-essential autoconf libtool git-core
apt-get build-dep -y imagemagick libmagickcore-dev libde265 libheif
cd /usr/src/
git clone https://github.com/strukturag/libde265.git
git clone https://github.com/strukturag/libheif.git
cd libde265/
./autogen.sh
./configure
make -j3
make install
cd /usr/src/libheif/
./autogen.sh
./configure
make -j3
make install
cd /usr/src/
wget https://www.imagemagick.org/download/ImageMagick.tar.gz
tar xf ImageMagick.tar.gz
cd ImageMagick-7*
./configure --with-heic=yes
make -j3
make install
ldconfig
