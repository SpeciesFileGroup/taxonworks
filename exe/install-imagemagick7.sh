#!/bin/bash
set -e
set -x
apt-get update
apt-get install -y libx265-dev
apt-get build-dep -y libmagickcore-dev

cd /usr/src/

# Workaround for strukturag/libde265#387
PATCH=$(cat <<'EOF'
diff -ruN orig/libde265.pc.in new/libde265.pc.in
--- orig/libde265.pc.in	2023-01-27 11:31:04.000000000 -0300
+++ new/libde265.pc.in	2023-01-30 19:23:30.385640774 -0300
@@ -1,7 +1,7 @@
-prefix=@CMAKE_INSTALL_PREFIX@
-exec_prefix=@CMAKE_INSTALL_PREFIX@
-libdir=${exec_prefix}/@CMAKE_INSTALL_LIBDIR@
-includedir=${prefix}/@CMAKE_INSTALL_INCLUDEDIR@
+prefix=@prefix@
+exec_prefix=@exec_prefix@
+libdir=@libdir@
+includedir=@includedir@
 
 Name: libde265
 Description: H.265/HEVC video decoder.
EOF
)
[ ! -d libde265-* ] && curl -sL $(curl -s https://api.github.com/repos/strukturag/libde265/releases/latest | jq --raw-output '.assets[0] | .browser_download_url') | tar xzf - && \
  cd libde265-* && \
  (echo "$PATCH" | patch -p1 || echo "WARN: Workaround patch no longer needed.") && \
  ./autogen.sh && \
  ./configure && \
  cd ..
cd libde265-*
make -j${MAKE_JOBS-3}
make install
cd ..

[ ! -d libheif-* ] && \
  curl -sL $(curl -s https://api.github.com/repos/strukturag/libheif/releases/latest | jq --raw-output '.assets[0] | .browser_download_url') | tar xzf - && \
  cd libheif-* && \
  ./autogen.sh && \
  ./configure --disable-examples --disable-go && \
  cd ..
cd libheif-*
make -j${MAKE_JOBS-3}
make install
cd ..

[ ! -d ImageMagick-7* ] && curl -sL https://imagemagick.org/archive/ImageMagick.tar.gz | tar xzf - && \
  cd ImageMagick-7*
  ./configure --with-modules=yes --with-heic=yes && \
  cd ..
cd ImageMagick-7*
make -j${MAKE_JOBS-3}
make install
cd ..

ldconfig
