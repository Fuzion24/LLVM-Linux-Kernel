#!/bin/bash
##############################################################################
# Copyright (c) 2012 Mark Charlebois
# Copyright (c) 2012 Behan Webster
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to 
# deal in the Software without restriction, including without limitation the 
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
# sell copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in 
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
##############################################################################

export LANG=C
export LC_ALL=C

EXTRAFLAGS=$*

# Use clang by default
if [ -z "$USEGCC" ]; then
	if [ -n "$COMPILER_PATH" ] ; then 
		CC="${CLANG} $COMPILER_PATH" # $CLANGFLAGS"
	else
		CC="${CLANG}" # $CLANGFLAGS"
	fi
else
	CC=${CROSS_COMPILE}gcc
fi

JOBS=${JOBS:-`getconf _NPROCESSORS_ONLN`}
[ -n "$JOBS" ] || JOBS=2

CCOPTS="CONFIG_DEBUG_SECTION_MISMATCH=y CONFIG_DEBUG_INFO=1 ${JOBS:+-j$JOBS} $MAKE_FLAGS $EXTRAFLAGS"
CCOPTS+=" CONFIG_NO_ERROR_ON_MISMATCH=y"
#CCOPTS+=" KALLSYMS_EXTRA_PASS=1"
CCOPTS+=" ${ARCH:+ARCH=$ARCH} ${CROSS_COMPILE:+CROSS_COMPILE=$CROSS_COMPILE}"

function build_env() {
	echo "---------------------------------------------------------------------"
	echo Build environment
	echo "---------------------------------------------------------------------"
	echo $0 $INSTALLDIR $*
	echo "---------------------------------------------------------------------"
	which gcc clang
	echo "export ARCH=$ARCH"
	echo "export ARM_CROSS_GCC_TOOLCHAIN=$ARM_CROSS_GCC_TOOLCHAIN"
	echo "export CC=$CC"
	echo "export CFLAGS=$CFLAGS"
	echo "export COMPILER_PATH='$COMPILER_PATH'"
	echo "export CROSS_COMPILE=$CROSS_COMPILE"
	echo "export HOST=$HOST"
	echo "export HOST_TRIPLE=$HOST_TRIPLE"
	echo "export JOBS=$JOBS"
	echo "export KBUILD_OUTPUT=$KBUILD_OUTPUT"
	echo "export LD=$LD"
	echo "export MARCH=$MARCH"
	echo "export MFLOAT=$MFLOAT"
	echo "export PATH=$PATH"
	echo "export TMPDIR=$TMPDIR"
	echo "export USE_CCACHE=$USE_CCACHE"
	echo "export V=$V"
	echo "---------------------------------------------------------------------"
	echo "$CC -print-file-name=include"
	$CC -print-file-name=include
	echo make $CCOPTS ${CC:+CC=\"$CC\"} ${CFLAGS:+CFLAGS_KERNEL=\"$CFLAGS\"} ${CFLAGS:+CFLAGS_MODULE=\"$CFLAGS\"} $KERNEL_MAKE_TARGETS
}
build_env
[ -z "$MAKE_KERNEL_STOP" ] || exit 1

make $CCOPTS ${CC:+CC="$CC"} ${CFLAGS:+CFLAGS_KERNEL="$CFLAGS"} ${CFLAGS:+CFLAGS_MODULE="$CFLAGS"} $KERNEL_MAKE_TARGETS
