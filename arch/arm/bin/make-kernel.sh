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

# Use clang by default
USECLANG=${USECLANG:-1}
DRYRUN=${DRYRUN:+echo}
V=${V:+V=1}
export PATH=`echo $PATH | sed -E 's/(.*?) :(.*)/\2\1/g; s/(.*?) :(.*)/\2\1/g; s/(.*?) :(.*)/\2\1/g'`

if [ -z "$GCCHOME" ]; then
	GCCHOME=${CSCC_DIR:-/opt}
fi

if [ -z "$CSVERSION" ]; then
	# Use Code Sourcery arm-2011.03 by default
	CSVERSION=2011.03
	GCCVERSION=4.5.2
fi

export CSCC_DIR=${CSCC_DIR:-$GCCHOME/arm-$CSVERSION}
export CSCC_BINDIR=${CSCC_BINDIR:-$CSCC_DIR/bin}
export HOSTTYPE=${HOSTTYPE:-arm-none-linux-gnueabi}
export HOSTTRIPLE=${HOSTTRIPLE:-arm-none-gnueabi}

JOBS=${JOBS:-`getconf _NPROCESSORS_ONLN`}
if [ -z "$JOBS" ]; then
  JOBS=2
fi
PARALLEL="-j$JOBS"

export INSTALLDIR=$1 ; shift
EXTRAFLAGS=$*

export LANG=C
export LC_ALL=C
export HOSTCC_FOR_BUILD="gcc"
export LD=${CROSS_COMPILE}ld

if [ $USECLANG -eq "1" ]; then
	export PATH="$INSTALLDIR/bin:$PATH"
	export CROSS_COMPILE=$HOSTTYPE-

	export CLANGFLAGS="-march=armv7-a -mfloat-abi=softfp -mfpu=neon -fno-builtin $EXTRAFLAGS"
	export CC_FOR_BUILD="$INSTALLDIR/bin/clang -ccc-host-triple $HOSTTRIPLE -ccc-gcc-name $HOSTTYPE-gcc $CLANGFLAGS"
else
	if [ ! -d $CSCC_DIR ]; then
		echo "Compiler not found: $CSCC_DIR"
		exit 1
	fi

	export COMPILER_PATH=$CSCC_DIR
	export CROSS_COMPILE=$HOSTTYPE-
	export CC_FOR_BUILD=$CSCC_BINDIR/$HOSTTYPE-gcc
fi

if [ -n "$CHECKERDIR" ] ; then
	mkdir -p "$CHECKERDIR"
	CHECKER='scan-build -v -o "'$CHECKERDIR'" --use-cc="'${CC_FOR_BUILD/ */}'"'
	V="V=1"
fi

RUNMAKE="make ARCH=arm KALLSYMS_EXTRA_PASS=1 \
	CONFIG_DEBUG_SECTION_MISMATCH=y CONFIG_DEBUG_INFO=1 HOSTCC=$HOSTCC_FOR_BUILD"

set -e
echo "export PATH=$PATH"
[ -n "$DRYRUN" ] || set -x
$DRYRUN $CHECKER $RUNMAKE $V CC="$CC_FOR_BUILD" $PARALLEL \
	|| ( echo "********************************************************************************" \
	&& $RUNMAKE V=1 CC="$CC_FOR_BUILD" )
[ -z "$DRYRUN" ] || exit 1
