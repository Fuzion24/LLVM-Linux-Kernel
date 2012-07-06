#!/bin/bash

# PATH, LLVMINSTALLDIR, CSCC_DIR, CSCC_BINDIR, and HOSTTYPE are exported from the Makefile

export PATH=`echo $PATH | sed -E 's/(.*?) :(.*)/\2\1/g; s/(.*?) :(.*)/\2\1/g; s/(.*?) :(.*)/\2\1/g'`

ARMGCC=`which arm-none-linux-gnueabi-gcc`
export ARMGCCDIR=${CSCC_BINDIR:-`dirname $ARMCC`}
export COMPILER_PATH=${CSCC_DIR:-`dirname $ARMGCCDIR`}
export ARMGCCSYSROOT="$COMPILER_PATH/$HOSTTYPE/libc"
export ARMGCCINCLUDE="$ARMGCCSYSROOT/usr/include"
export HOSTTYPE=${HOSTTYPE:-arm-none-linux-gnueabi}

CC="$LLVMINSTALLDIR/bin/clang -ccc-host-triple $HOSTTYPE -ccc-gcc-name $HOSTTYPE-gcc --sysroot=${ARMGCCSYSROOT} -march=armv7-a -mfloat-abi=softfp -mfpu=neon"

${CC} $*
