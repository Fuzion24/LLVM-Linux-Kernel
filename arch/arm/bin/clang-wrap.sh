#!/bin/bash

# PATH, LLVMINSTALLDIR, CSCC_DIR, CSCC_BINDIR, and HOSTTYPE are exported from the Makefile

export PATH=`echo $PATH | sed -E 's/(.*?) :(.*)/\2\1/g; s/(.*?) :(.*)/\2\1/g; s/(.*?) :(.*)/\2\1/g'`

ARMGCC=`which arm-none-linux-gnueabi-gcc`
export ARMGCCDIR=${CSCC_BINDIR:-`dirname $ARMCC`}
export COMPILER_PATH=${CSCC_DIR:-`dirname $ARMGCCDIR`}
export ARMGCCSYSROOT="$COMPILER_PATH/$HOSTTYPE/libc"
export ARMGCCINCLUDE="$ARMGCCSYSROOT/usr/include"
export HOSTTYPE=${HOSTTYPE:-arm-none-linux-gnueabi}
export HOSTRIPLE=${HOSTRIPLE:-arm-none-gnueabi}

CLANGFLAGS="-march=armv7-a -mfloat-abi=softfp -mfpu=neon -fcatch-undefined-behavior"

CC="$LLVMINSTALLDIR/bin/clang -ccc-host-triple $HOSTTYPE -ccc-gcc-name $HOSTTYPE-gcc --sysroot=${ARMGCCSYSROOT} ${CLANGFLAGS}"

${CC} $*
