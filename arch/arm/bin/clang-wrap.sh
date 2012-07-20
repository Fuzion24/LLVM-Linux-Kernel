#!/bin/bash

# PATH, LLVMINSTALLDIR, CSCC_DIR, CSCC_BINDIR, and HOST_TYPE are exported from the Makefile

export PATH=`echo $PATH | sed -E 's/(.*?) :(.*)/\2\1/g; s/(.*?) :(.*)/\2\1/g; s/(.*?) :(.*)/\2\1/g'`

ARMGCC=`which arm-none-linux-gnueabi-gcc`
export ARMGCCDIR=${CSCC_BINDIR:-`dirname $ARMCC`}
export COMPILER_PATH=${CSCC_DIR:-`dirname $ARMGCCDIR`}
export ARMGCCSYSROOT="$COMPILER_PATH/$HOST_TYPE/libc"
export ARMGCCINCLUDE="$ARMGCCSYSROOT/usr/include"
export HOST_TYPE=${HOST_TYPE:-arm-none-linux-gnueabi}
export HOSTRIPLE=${HOSTRIPLE:-arm-none-gnueabi}

CLANGFLAGS="-march=armv7-a -mfloat-abi=softfp -mfpu=neon -fcatch-undefined-behavior"

CC="$LLVMINSTALLDIR/bin/clang -ccc-host-triple $HOST_TYPE -ccc-gcc-name $HOST_TYPE-gcc --sysroot=${ARMGCCSYSROOT} ${CLANGFLAGS}"

${CC} $*
