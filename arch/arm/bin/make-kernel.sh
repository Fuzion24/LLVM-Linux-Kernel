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

TOPDIR=`dirname $0`/../../..

# Use clang by default
USECLANG=${USECLANG:-1}
DRYRUN=${DRYRUN:+echo}
MARCH=${MARCH:-armv7-a}
MFLOAT=${MFLOAT:-"-mfloat-abi=hard -mfpu=neon"}
V=${V:+V=1}
export PATH=`echo $PATH | sed -E 's/(.*?) :(.*)/\2\1/g; s/(.*?) :(.*)/\2\1/g; s/(.*?) :(.*)/\2\1/g'`

JOBS=${JOBS:-`getconf _NPROCESSORS_ONLN`}
if [ -z "$JOBS" ]; then
  JOBS=2
fi
PARALLEL="-j$JOBS"

export LANG=C
export LC_ALL=C
export HOSTCC_FOR_BUILD="gcc"

# The gcc toolchain for assembler and linker must be defined
# even if Clang is being used until LLVM has its own linker
if [ $USECLANG -eq "1" ]; then
	export INSTALLDIR=$1 ; shift
	export EXTRAFLAGS=$*

	export PATH="${INSTALLDIR}/bin:${PATH}"
	export CROSS_COMPILE=${HOST}-

	# Must pass -mllvm -use-new-sroa=false or Clang will segfault on
	export CLANGFLAGS="-march=$MARCH $MFLOAT -fno-builtin -Qunused-arguments -Wno-asm-operand-widths ${EXTRAFLAGS}"
	export CC_FOR_BUILD="${INSTALLDIR}/bin/clang -ccc-host-triple ${HOST_TRIPLE} -ccc-gcc-name ${HOST}-gcc ${CLANGFLAGS}"
fi

export LD=${CROSS_COMPILE}ld

#if [ -n "$CHECKERDIR" ] ; then
#	mkdir -p "$CHECKERDIR"
#	#CHECKER='scan-build -v -o "'$CHECKERDIR'" --use-cc="'${CC_FOR_BUILD/ */}'"'
#	CHECKER='scan-build -v -o "'$CHECKERDIR'" --use-cc="clang"'
#	V="V=1"
#fi

#RUNMAKE="make ARCH=arm KALLSYMS_EXTRA_PASS=1 \
#	CONFIG_DEBUG_SECTION_MISMATCH=y CONFIG_DEBUG_INFO=1 HOSTCC=${HOSTCC_FOR_BUILD}"

set -e
echo "export PATH=$PATH"
#[ -n "$DRYRUN" ] || set -x
#$DRYRUN $CHECKER $RUNMAKE $V CC="$CC_FOR_BUILD" $PARALLEL \
#	|| ( echo "********************************************************************************" \
#	&& $RUNMAKE V=1 CC="${CC_FOR_BUILD}" )
#[ -z "$DRYRUN" ] || exit 1

make KALLSYMS_EXTRA_PASS=1 CONFIG_DEBUG_SECTION_MISMATCH=y ARCH=arm CONFIG_DEBUG_INFO=1 \
	CC="${CC_FOR_BUILD}" HOSTCC="${HOSTCC_FOR_BUILD}" ${PARALLEL}

