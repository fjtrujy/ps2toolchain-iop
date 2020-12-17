#!/bin/bash
# gcc-3.2.3-stage1.sh by AKuHAK
# Based on gcc-3.2.2-stage1.sh by Naomi Peori (naomi@peori.ca)

## Download the source code.
REPO_URL="https://github.com/fjtrujy/gcc.git"
REPO_FOLDER="gcc"
BRANCH_NAME="iop-v9.2.0"
if test ! -d "$REPO_FOLDER"; then
	git clone --depth 1 -b $BRANCH_NAME $REPO_URL && cd $REPO_FOLDER || exit 1
else
	cd $REPO_FOLDER && git fetch origin && git reset --hard origin/${BRANCH_NAME} || exit 1
fi

TARGET_ALIAS="iop" 
TARGET="iop"

OSVER=$(uname)
## Apple needs to pretend to be linux
if [ ${OSVER:0:6} == Darwin ]; then
	TARG_XTRA_OPTS="--build=i386-linux-gnu --host=i386-linux-gnu"
else
	TARG_XTRA_OPTS=""
fi

## Determine the maximum number of processes that Make can work with.
PROC_NR=$(getconf _NPROCESSORS_ONLN)

## Create and enter the toolchain/build directory
mkdir build-$TARGET-stage1 && cd build-$TARGET-stage1 || { exit 1; }

## Configure the build.
../configure \
  --quiet \
  --prefix="$PS2DEV/$TARGET_ALIAS" \
  --target="$TARGET" \
  --enable-languages="c" \
  --with-float=hard \
  --with-newlib \
  --disable-nls \
  --disable-shared \
  --disable-libssp \
  --disable-libmudflap \
  --disable-threads \
  --disable-libgomp \
  --disable-libquadmath \
  --disable-target-libiberty \
  --disable-target-zlib \
  --without-ppl \
  --without-cloog \
  --with-headers=no \
  --disable-libada \
  --disable-libatomic \
  --disable-multilib \
  --disable-lto \
  $TARG_XTRA_OPTS || { exit 1; }

## Compile and install.
make --quiet -j $PROC_NR clean   || { exit 1; }
make --quiet -j $PROC_NR all     || { exit 1; }
make --quiet -j $PROC_NR install || { exit 1; }
make --quiet -j $PROC_NR clean   || { exit 1; }