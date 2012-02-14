#!/bin/bash

TOPDIR=`dirname $0`/../../..
export PATH=/opt/arm-2011.03/bin:$PATH
CLANG_INSTALL_DIR=${TOPDIR}/clang/install
ARMGCC=`which arm-none-linux-gnueabi-gcc`
ARMGCCDIR=`dirname $ARMGCC`
ARMGCCINCLUDE="$ARMGCCDIR"/../arm-none-linux-gnueabi/libc/usr/include
CC="${CLANG_INSTALL_DIR}/bin/clang -g -march=armv7-a -ccc-host-triple arm -mfloat-abi=softfp -mfpu=neon -ccc-gcc-name none-linux-gnueabi-gcc -I ${ARMGCCINCLUDE} -I ${CLANG_INSTALL_DIR}/lib/clang/*/include"


${CC} $*
