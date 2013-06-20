#!/bin/bash

# PATH, LLVMINSTALLDIR, and HOST_TYPE are exported from the Makefile

#export PATH=`echo $PATH | sed -E 's/(.*?) :(.*)/\2\1/g; s/(.*?) :(.*)/\2\1/g; s/(.*?) :(.*)/\2\1/g'`

export ARMGCCSYSROOT="${COMPILER_PATH}/${HOST}/libc"
export ARMGCCINCLUDE="${ARMGCCSYSROOT}/usr/include"

CLANGFLAGS="-march=armv7-a -mfloat-abi=softfp -mfpu=neon -fsanitize=undefined-trap -fsanitize-undefined-trap-on-error"

CC="${LLVMINSTALLDIR}/bin/clang -target ${HOST_TRIPLE} -ccc-gcc-name ${HOST}-gcc --sysroot=${ARMGCCSYSROOT} ${CLANGFLAGS}"

${CC} $*
