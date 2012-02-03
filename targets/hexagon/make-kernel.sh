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

USECLANG=1
GCCHOME=/opt
PARALLEL="-j8"
#PARALLEL=

export INSTALLDIR=$1

export LANG=C
export LC_ALL=C

if [ ${USECLANG} -eq "1" ]; then
export CC_FOR_BUILD="${INSTALLDIR}/bin/clang -g -march=hexagon \
	-ccc-host-triple hexagon -mfloat-abi=softfp \
	-ccc-gcc-name hexagon-none-linux-gnueabi-gcc \
	-I ${INSTALLDIR}/lib/clang/3.0/include"
export PATH=${GCCHOME}/hexagon-2011.03/bin:${INSTALLDIR}/bin:$PATH
export CROSS_COMPILE=hexagon-none-linux-gnueabi-

else

export CC_FOR_BUILD=${GCCHOME}/hexagon-2010.09/bin/hexagon-none-linux-gnueabi-gcc
export CROSS_COMPILE=hexagon-none-linux-gnueabi-
export PATH=${GCCHOME}/hexagon-2010.09/bin:$PATH
fi

export HOSTCC_FOR_BUILD="gcc"
export MAKE="make V=1"

export LD=${CROSS_COMPILE}ld

$MAKE CONFIG_DEBUG_SECTION_MISMATCH=y ARCH=arm CONFIG_DEBUG_INFO=1 \
	CC="$CC_FOR_BUILD" HOSTCC=$HOSTCC_FOR_BUILD ${PARALLEL}

