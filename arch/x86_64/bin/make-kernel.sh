#!/bin/bash
##############################################################################
# Copyright (c) 2012 Mark Charlebois
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

export PATH=`echo $PATH | sed -E 's/(.*?) :(.*)/\2\1/g; s/(.*?) :(.*)/\2\1/g; s/(.*?) :(.*)/\2\1/g'`
export HOSTTYPE=${HOSTTYPE:-none-linux-gnueabi}
export HOSTTRIPLE=${HOSTTRIPLE:-x86_64-pc-linux-gnu}

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

	#export CLANGFLAGS="-I ${INSTALLDIR}/lib/clang/*/include"
	export CC_FOR_BUILD="$INSTALLDIR/bin/clang -ccc-host-triple $HOSTTRIPLE -ccc-gcc-name $HOSTTYPE-gcc $CLANGFLAGS"

else
	export CC_FOR_BUILD=gcc
fi

export HOSTCC_FOR_BUILD="gcc"
export MAKE="make V=1"

$MAKE CONFIG_DEBUG_SECTION_MISMATCH=y CONFIG_DEBUG_INFO=1 \
	CC="$CC_FOR_BUILD" HOSTCC=$HOSTCC_FOR_BUILD $PARALLEL

