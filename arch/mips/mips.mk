##############################################################################
# Copyright (c) 2012 Mark Charlebois
#               2012 Behan Webster
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

export HOSTTYPE=${HOST}
export HOSTTRIPLE

ARCHMIPSDIR	= ${ARCHDIR}/mips
ARCHMIPSBINDIR	= ${ARCHMIPSDIR}/bin
ARCHMIPSPATCHES	= ${ARCHMIPSDIR}/patches

#KERNEL_PATCHES	+= ${COMMON}/mips/common-mips.patch ${COMMON}/mips/fix-warnings-mips.patch \
#	${COMMON}/mips/fix-warnings-mips-unused.patch
KERNEL_PATCHES	+= $(call add_patches,${ARCHMIPSPATCHES})

ARCH		= mips
MAKE_FLAGS	= ARCH=${ARCH}
MAKE_KERNEL	= ${ARCHMIPSBINDIR}/make-kernel.sh ${LLVMINSTALLDIR} ${EXTRAFLAGS}
HOST		= arm-none-linux-mips
HOSTTRIPLE	= arm-none-mips
CROSS_COMPILE	= ${HOST}-
CC		= clang-wrap.sh
CPP		= ${CC} -E

# Add path so that ${CROSS_COMPILE}${CC} is resolved
PATH		+= :${ARCHARMBINDIR}:

