#!/bin/bash

TOPDIR=`dirname $0`/../../..
export PATH=/opt/arm-2011.03/bin:$PATH
CLANG_INSTALL_DIR=${TOPDIR}/clang/install-dev
ARMGCC=`which arm-none-linux-gnueabi-gcc`
ARMGCCDIR=`dirname $ARMGCC`
ARMGCCINCLUDE="$ARMGCCDIR"/../arm-none-linux-gnueabi/libc/usr/include
export COMPILER_PATH=/opt/arm-2011.03
CC="${CLANG_INSTALL_DIR}/bin/clang -v -ccc-host-triple arm-none-linux-gnueabi -ccc-gcc-name arm-none-linux-gnueabi-gcc --sysroot=/opt/arm-2011.03/arm-none-linux-gnueabi/libc -march=armv7-a -mfpu=neon"

${CC} $*
