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

ARCHX86_64DIR		= ${ARCHDIR}/x86_64
ARCHX86_64BINDIR	= ${ARCHX86_64DIR}/bin
ARCHX86_64PATCHES	= ${ARCHX86_64DIR}/patches

#KERNEL_PATCHES		+= ${COMMON}/x86_64/common-x86_64.patch ${COMMON}/x86_64/fix-warnings-x86_64.patch \
#	${COMMON}/x86_64/fix-warnings-x86_64-unused.patch
KERNEL_PATCHES		+= $(call add_patches,${ARCHX86_64PATCHES})

MAKE_FLAGS=
MAKE_KERNEL=${COMMON}/x86_64/make-kernel.sh ${LLVMINSTALLDIR} ${EXTRAFLAGS}
