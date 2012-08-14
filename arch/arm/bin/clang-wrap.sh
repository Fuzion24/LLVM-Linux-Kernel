#!/bin/bash

# PATH, LLVMINSTALLDIR, CSCC_DIR, CSCC_BINDIR, and HOST_TYPE are exported from the Makefile

#export PATH=`echo $PATH | sed -E 's/(.*?) :(.*)/\2\1/g; s/(.*?) :(.*)/\2\1/g; s/(.*?) :(.*)/\2\1/g'`

export ARMGCCSYSROOT="${COMPILER_PATH}/${HOST}/libc"
export ARMGCCINCLUDE="${ARMGCCSYSROOT}/usr/include"

CLANGFLAGS="-march=armv7-a -mfloat-abi=softfp -mfpu=neon -fcatch-undefined-behavior"

CC="${LLVMINSTALLDIR}/bin/clang -ccc-host-triple ${HOST_TRIPLE} -ccc-gcc-name ${HOST}-gcc --sysroot=${ARMGCCSYSROOT} ${CLANGFLAGS}"

${CC} $*
