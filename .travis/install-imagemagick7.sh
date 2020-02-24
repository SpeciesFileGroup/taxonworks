#!/bin/sh
# Source: https://medium.com/@eplt/5-minutes-to-install-imagemagick-with-heic-support-on-ubuntu-18-04-digitalocean-fe2d09dcef1
sudo sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list
sudo apt-get update
sudo apt-get install build-essential autoconf libtool git-core
sudo apt-get build-dep imagemagick libmagickcore-dev libde265 libheif
cd /usr/src/ 
sudo git clone https://github.com/strukturag/libde265.git  
sudo git clone https://github.com/strukturag/libheif.git 
cd libde265/ 
sudo ./autogen.sh 
sudo ./configure 
sudo make  
sudo make install 
cd /usr/src/libheif/ 
sudo ./autogen.sh 
sudo ./configure 
sudo make  
sudo make install 
cd /usr/src/ 
sudo wget https://www.imagemagick.org/download/ImageMagick.tar.gz 
sudo tar xf ImageMagick.tar.gz 
cd ImageMagick-7*
sudo ./configure --with-heic=yes 
sudo make  
sudo make install  
sudo ldconfig