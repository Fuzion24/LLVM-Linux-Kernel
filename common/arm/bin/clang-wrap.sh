#!/bin/bash
TOPDIR=`dirname $0`/../../..
CLANG_INSTALL_DIR=${TOPDIR}/clang/install
CC="${CLANG_INSTALL_DIR}/bin/clang -g -march=armv7-a -ccc-host-triple arm -mfloat-abi=softfp -mfpu=neon -ccc-gcc-name none-linux-gnueabi-gcc -I /opt/arm-2011.03/arm-none-linux-gnueabi/libc/usr/include -I ${CLANG_INSTALL_DIR}/lib/clang/*/include"

export PATH=/opt/arm-2011.03/bin:$PATH

${CC} $*
