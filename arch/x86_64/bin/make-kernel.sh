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

if [ $USECLANG -eq "1" ]; then
	export PATH="$INSTALLDIR/bin:$PATH"

	#export CLANGFLAGS="-I ${INSTALLDIR}/lib/clang/*/include"
	export CC_FOR_BUILD="$INSTALLDIR/bin/clang $EXTRAFLAGS $CLANGFLAGS"
else
	export CC_FOR_BUILD=gcc
fi

#if [ -n "$CHECKERDIR" ] ; then
#	mkdir -p "$CHECKERDIR"
#	CHECKER='scan-build -v -o "'$CHECKERDIR'" --use-cc="'${CC_FOR_BUILD/ */}'"'
#	V="V=1"
#fi

#RUNMAKE="make \
#	CONFIG_DEBUG_SECTION_MISMATCH=y CONFIG_DEBUG_INFO=1 HOSTCC=$HOSTCC_FOR_BUILD"

set -e
echo "export PATH=$PATH"
env
#[ -n "$DRYRUN" ] || set -x
#$DRYRUN $CHECKER $RUNMAKE $V CC="$CC_FOR_BUILD" $PARALLEL \
#	|| ( echo "********************************************************************************" \
#	&& $RUNMAKE V=1 CC="$CC_FOR_BUILD" )
#[ -z "$DRYRUN" ] || exit 1

make CONFIG_DEBUG_SECTION_MISMATCH=y CONFIG_DEBUG_INFO=1 \
    CC="${CC_FOR_BUILD}" HOSTCC="${HOSTCC_FOR_BUILD}" ${PARALLEL}

