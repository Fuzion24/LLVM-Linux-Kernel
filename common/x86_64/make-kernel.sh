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
PARALLEL="-j8"
#PARALLEL=

export INSTALLDIR=$1

export LANG=C
export LC_ALL=C

if [ ${USECLANG} -eq "1" ]; then
export CC_FOR_BUILD="${INSTALLDIR}/bin/clang -ccc-host-triple x86_64-pc-linux-gnu \
	-ccc-gcc-name none-linux-gnueabi-gcc \
	-I ${INSTALLDIR}/lib/clang/3.1/include"
export PATH=${INSTALLDIR}/bin:$PATH

else

export CC_FOR_BUILD=gcc

fi

export HOSTCC_FOR_BUILD="gcc"
export MAKE="make V=1"

$MAKE CONFIG_DEBUG_SECTION_MISMATCH=y CONFIG_DEBUG_INFO=1 \
	CC="$CC_FOR_BUILD" HOSTCC=$HOSTCC_FOR_BUILD ${PARALLEL}

