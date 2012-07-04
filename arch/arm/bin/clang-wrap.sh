#!/bin/bash

TOPDIR=`dirname $0`/../../..

CLANG_INSTALL_DIR=${TOPDIR}/clang/install
export PATH=/opt/arm-2011.03/bin:$PATH
export COMPILER_PATH=/opt/arm-2011.03
ARMGCC=`which arm-none-linux-gnueabi-gcc`
export ARMGCCDIR=`dirname $ARMGCC`
export ARMGCCINCLUDE="$ARMGCCDIR"/../arm-none-linux-gnueabi/libc/usr/include
if [ ! x"$ARMGCCDIR" == x"" ] ; then export COMPILER_PATH="$ARMGCCDIR/../" ; fi

CC="${CLANG_INSTALL_DIR}/bin/clang -ccc-host-triple arm-none-linux-gnueabi -ccc-gcc-name arm-none-linux-gnueabi-gcc --sysroot=${COMPILER_PATH}/arm-none-linux-gnueabi/libc -march=armv7-a -mfloat-abi=softfp -mfpu=neon"

${CC} $*
