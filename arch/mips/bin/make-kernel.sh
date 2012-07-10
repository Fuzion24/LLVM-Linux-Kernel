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

if [ -z "$GCCHOME" ]; then
	GCCHOME=${MIPSCC_DIR:-/opt}
fi

if [ -z "$CSVERSION" ]; then
	# Use Code Sourcery mips-2011.03 by default
	CSVERSION=2011.03
	#GCCVERSION=4.5.2
fi

export MIPSCC_DIR=${MIPSCC_DIR:-$GCCHOME/mips-$CSVERSION}
export MIPSCC_BINDIR=${MIPSCC_BINDIR:-$MIPSCC_DIR/bin}
export PATH=`echo $PATH | sed -E 's/(.*?) :(.*)/\2\1/g; s/(.*?) :(.*)/\2\1/g; s/(.*?) :(.*)/\2\1/g'`
export HOSTTYPE=${HOSTTYPE:-mips-none-eabi}
export HOSTTRIPLE=${HOSTTRIPLE:-mips}

JOBS=${JOBS:-`getconf _NPROCESSORS_ONLN`}
if [ -z "$JOBS" ]; then
  JOBS=2
fi
PARALLEL="-j$JOBS"

export INSTALLDIR=$1 ; shift
EXTRAFLAGS=$*

export LANG=C
export LC_ALL=C

if [ $USECLANG -eq "1" ]; then
	export PATH="$INSTALLDIR/bin:$PATH"
	export CROSS_COMPILE=$HOSTTYPE-
	#export CLANGFLAGS="-g -mfloat-abi=softfp -I ${INSTALLDIR}/lib/clang/*/include $EXTRAFLAGS"
	export CLANGFLAGS="-g -mfloat-abi=softfp $EXTRAFLAGS"
	export CC_FOR_BUILD="$INSTALLDIR/bin/clang -ccc-host-triple $HOSTTRIPLE -ccc-gcc-name $HOSTTYPE-gcc $CLANGFLAGS"

else


	#export PATH="$MIPSCC_BINDIR:$PATH"
	export COMPILER_PATH=$MIPSCC_DIR
	export CROSS_COMPILE=$HOSTTYPE-
	export CC_FOR_BUILD=$MIPSCC_BINDIR/$HOSTTYPE-gcc
fi

export HOSTCC_FOR_BUILD="gcc"
export MAKE="make V=1"
export LD=${CROSS_COMPILE}ld

$MAKE CONFIG_DEBUG_SECTION_MISMATCH=y ARCH=mips CONFIG_DEBUG_INFO=1 \
	CC="$CC_FOR_BUILD" HOSTCC=$HOSTCC_FOR_BUILD ${PARALLEL}

