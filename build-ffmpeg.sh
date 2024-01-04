#!/bin/bash

FFMPEG_VERSION=6.1.1
CURRENT_DIR=$(pwd)

apt-get update && apt-get install --reinstall -y wget \
                                    autoconf \
                                    automake \
                                    build-essential \
                                    cmake \
                                    git-core \
                                    libass-dev \
                                    libfreetype6-dev \
                                    libgnutls28-dev \
                                    libmp3lame-dev \
                                    libsdl2-dev \
                                    libtool \
                                    libva-dev \
                                    libvdpau-dev \
                                    libvorbis-dev \
                                    libxcb1-dev \
                                    libxcb-shm0-dev \
                                    libxcb-xfixes0-dev \
                                    meson \
                                    ninja-build \
                                    pkg-config \
                                    texinfo \
                                    wget \
                                    yasm \
                                    zlib1g-dev \
                                    libunistring-dev libaom-dev

mkdir -p $CURRENT_DIR/ffmpeg_sources $CURRENT_DIR/bin
apt-get install -y nasm
apt-get install -y libx264-dev
apt-get install -y libx265-dev libnuma-dev
apt-get install -y libvpx-dev
apt-get install -y libfdk-aac-dev
apt-get install -y libopus-dev
cd $CURRENT_DIR/ffmpeg_sources && \
git -C aom pull 2> /dev/null || git clone --depth 1 https://aomedia.googlesource.com/aom && \
mkdir -p aom_build && \
cd aom_build && \
PATH="$CURRENT_DIR/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$CURRENT_DIR/ffmpeg_build" -DENABLE_TESTS=OFF -DENABLE_NASM=on ../aom && \
PATH="$CURRENT_DIR/bin:$PATH" make && \
make install

cd $CURRENT_DIR/ffmpeg_sources && \
git -C SVT-AV1 pull 2> /dev/null || git clone https://gitlab.com/AOMediaCodec/SVT-AV1.git && \
mkdir -p SVT-AV1/build && \
cd SVT-AV1/build && \
PATH="$CURRENT_DIR/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$CURRENT_DIR/ffmpeg_build" -DCMAKE_BUILD_TYPE=Release -DBUILD_DEC=OFF -DBUILD_SHARED_LIBS=OFF .. && \
PATH="$CURRENT_DIR/bin:$PATH" make && \
make install

cd $CURRENT_DIR/ffmpeg_sources && \
git -C dav1d pull 2> /dev/null || git clone --depth 1 https://code.videolan.org/videolan/dav1d.git && \
mkdir -p dav1d/build && \
cd dav1d/build && \
meson setup -Denable_tools=false -Denable_tests=false --default-library=static .. --prefix "$CURRENT_DIR/ffmpeg_build" --libdir="$CURRENT_DIR/ffmpeg_build/lib" && \
ninja && \
ninja install

cd $CURRENT_DIR/ffmpeg_sources && \
wget https://github.com/Netflix/vmaf/archive/v2.3.1.tar.gz && \
tar xvf v2.3.1.tar.gz && \
mkdir -p vmaf-2.3.1/libvmaf/build &&\
cd vmaf-2.3.1/libvmaf/build && \
meson setup -Denable_tests=false -Denable_docs=false --buildtype=release --default-library=static .. --prefix "$CURRENT_DIR/ffmpeg_build" --bindir="$CURRENT_DIR/ffmpeg_build/bin" --libdir="$CURRENT_DIR/ffmpeg_build/lib" && \
ninja && \
ninja install

cd $CURRENT_DIR/ffmpeg_sources && \
wget -O ffmpeg-$FFMPEG_VERSION.tar.xz https://www.ffmpeg.org/releases/ffmpeg-$FFMPEG_VERSION.tar.xz && \
tar xf ffmpeg-$FFMPEG_VERSION.tar.xz && \
mv ffmpeg-$FFMPEG_VERSION ffmpeg && \
cd ffmpeg && \
PATH="$CURRENT_DIR/bin:$PATH" PKG_CONFIG_PATH="$CURRENT_DIR/ffmpeg_build/lib/pkgconfig" ./configure \
  --prefix="$CURRENT_DIR/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$CURRENT_DIR/ffmpeg_build/include" \
  --extra-ldflags="-L$CURRENT_DIR/ffmpeg_build/lib" \
  --extra-libs="-lpthread -lm" \
  --ld="g++" \
  --bindir="$CURRENT_DIR/bin" \
  --enable-gpl \
  --enable-gnutls \
  --enable-libaom \
  --enable-libass \
  --enable-libfdk-aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libsvtav1 \
  --enable-libdav1d \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libx265 \
  --enable-nonfree && \
PATH="$CURRENT_DIR/bin:$PATH" make
