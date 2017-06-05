#!/bin/bash
# This file is under the GPL
# Copyright (C) hdsdi3g for hd3g.tv 2017
#
# Setup Media tools
# 
# Please run it after read doc.md
# THIS SCRIPT CAN TAKE A LOT OF TIME
# Checked with shellcheck media.bash

set -e

export DEBIAN_FRONTEND=noninteractive
HOSTNAME=$(hostname);
CPU_COUNT=$(grep -c ^processor /proc/cpuinfo)

echo " > Base build tools";
apt-get install -y yasm autoconf automake libtool libtool-bin pkg-config perl-modules git unzip make mercurial g++ cmake cmake-curses-gui libnuma-dev xzdec uuid-dev

echo " > For ffmpeg ssh and smb file handling.";
apt-get install -y libssh-dev samba-dev libsmbclient-dev

echo " > Audio and video lib";
apt-get install -y \
	flac \
	libflac-dev \
	lame \
	libmp3lame-dev \
	libogg-dev \
	libvorbis-dev \
	libtwolame-dev \
	libopencore-amrnb-dev \
	libopencore-amrwb-dev \
	libwavpack-dev \
	libvo-amrwbenc-dev \
	libvo-aacenc-dev \
	libspeex-dev \
	libgsm1-dev \
	libopus-dev \
	libopusfile-dev \
	libopenjpeg-dev \
	libopenjpeg5 \
	openjpeg-tools \
	libopenjp2-7-dev \
	libopenjp2-7 \
	libtheora-dev \
	libvpx-dev \
	libxvidcore-dev \
	libfaac-dev \
	libzvbi-dev \
	libwebp-dev \
	libschroedinger-dev \
	librtmp-dev \
	libbluray-dev

# libx264-dev

echo " > dcadec";
git clone https://github.com/foo86/dcadec.git
cd dcadec/
make -j "$CPU_COUNT"
make install
ldconfig
cd ..
rm -rf dcadec

echo " > libx264";
git clone http://git.videolan.org/git/x264.git
cd x264/
./configure --disable-ffms --disable-lavf --disable-swscale 
make -j "$CPU_COUNT"
make install
ldconfig
cd ..
rm -rf x264

echo " > libx265";
wget https://bitbucket.org/multicoreware/x265/downloads/x265_1.9.tar.gz
# https://bitbucket.org/multicoreware/x265/downloads/x265_2.1.tar.gz
tar xvfz x265_1.9.tar.gz
cd x265_1.9/build/linux
cmake -G "Unix Makefiles" ../../source
make -j "$CPU_COUNT"
make install
ldconfig
cd ..
cd ..
cd ..
rm -rf x265
rm x265*.tar.gz

echo " > fdk-aac";
git clone https://github.com/mstorsjo/fdk-aac.git
cd fdk-aac
./autogen.sh
./configure
make -j "$CPU_COUNT"
make install
ldconfig
cd ..
rm -rf fdk-aac

echo " > ffmpeg";
wget http://ffmpeg.org/releases/ffmpeg-3.2.2.tar.bz2
bzcat ffmpeg-3.2.2.tar.bz2 | tar xvf -
cd ffmpeg-3.2.2
./configure --enable-gpl --enable-version3 --enable-nonfree --as=yasm \
	--enable-libmp3lame \
	--enable-libbluray \
	--enable-libopenjpeg \
	--enable-libtheora  \
	--enable-libvorbis  \
	--enable-libtwolame  \
	--enable-libvpx  \
	--enable-libxvid  \
	--enable-libgsm  \
	--enable-libopencore-amrnb \
	--enable-libopencore-amrwb \
	--enable-libopus \
	--enable-librtmp \
	--enable-libschroedinger \
	--enable-libsmbclient \
	--enable-libspeex \
	--enable-libssh \
	--enable-libwavpack \
	--enable-libwebp \
	--enable-libzvbi \
	--enable-libx264 \
	--enable-libsmbclient \
	--enable-libssh \
	--enable-libfdk-aac \
	--enable-libx265

make -j "$CPU_COUNT"
make install
ldconfig
gcc tools/qt-faststart.c
mv a.out /usr/local/bin/qt-faststart
cd ..
rm -rf ffmpeg-*

## ffmpeg CentOS
#./configure --enable-static --disable-shared --enable-gpl --enable-version3 --enable-nonfree --as=yasm --enable-libmp3lame --enable-libbluray --enable-libopenjpeg --enable-libtheora --enable-libvorbis --enable-libtwolame --enable-libvpx --enable-libxvid --enable-libgsm --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libopus --enable-librtmp --enable-libschroedinger --enable-libsmbclient --enable-libspeex --enable-libwavpack --enable-libx264 --enable-libsmbclient --enable-libfdk-aac
## yum install libopencore-amr-devel libbluray-devel openjpeg-devel opus-devel librtmp-devel schroedinger-devel speex-devel libtheora-devel libtwolame-devel libvorbis-devel libvpx-devel libxml2-devel fontconfig-devel ant gsm-devel numactl-devel libxvidcore-devel
#http://www.wavpack.com/wavpack-5.0.0.tar.bz2 + x264 + fdk-aac + dcadec
#ldconfig

echo " > ffmbc";
git clone https://github.com/bcoudurier/FFmbc.git ffmbc
cd ffmbc
./configure --disable-ffprobe --enable-gpl --enable-nonfree --as=yasm --disable-shared --enable-static --disable-doc
make -j "$CPU_COUNT"
make install
ldconfig
cd ..
rm -rf ffmbc

echo " > bbc bmx";
# Centos : https://sourceforge.net/projects/libuuid/
#cd libuuid-1.0.3
#./configure --enable-static --disable-shared PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
#make -j $CPU_COUNT
#make install

git clone https://github.com/hdsdi3g/bmx.git
cd bmx
cd uriparser
./configure --disable-test --disable-doc --enable-static --disable-shared PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
make -j "$CPU_COUNT"
make check
make install
cd ..
cd expat
./configure --enable-static --disable-shared PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
make -j "$CPU_COUNT"
make install
cd ..
cd ..
rm -rf bmx

git clone https://git.code.sf.net/p/bmxlib/libmxf bmxlib-libmxf
cd bmxlib-libmxf
./autogen.sh
./configure --enable-static --disable-shared PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
make -j "$CPU_COUNT"
make install
cd ..
rm -rf bmxlib-libmxf

git clone https://git.code.sf.net/p/bmxlib/libmxfpp bmxlib-libmxfpp
cd bmxlib-libmxfpp
./autogen.sh
./configure --enable-static --disable-shared PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
make -j "$CPU_COUNT"
make install
cd ..
rm -rf bmxlib-libmxfpp

git clone https://git.code.sf.net/p/bmxlib/bmx bmxlib-bmx
cd bmxlib-bmx
./autogen.sh
./configure --enable-static --disable-shared PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
make -j "$CPU_COUNT"
make install
cd ..
ldconfig
rm -rf bmxlib-bmx
