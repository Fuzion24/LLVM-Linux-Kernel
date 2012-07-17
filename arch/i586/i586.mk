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

ARCHX86_32DIR		= ${ARCHDIR}/i586
ARCHX86_32BINDIR	= ${ARCHX86_32DIR}/bin
ARCHX86_32PATCHES	= ${ARCHX86_32DIR}/patches

#KERNEL_PATCHES		+= ${COMMON}/x86_64/common-x86_64.patch ${COMMON}/x86_64/fix-warnings-x86_64.patch \
#	${COMMON}/x86_64/fix-warnings-x86_64-unused.patch
KERNEL_PATCHES		+= $(call add_patches,${ARCHX86_32PATCHES})

ARCH		= i386
#MAKE_FLAGS	= ARCH=${ARCH}
MAKE_KERNEL	= ${ARCHX86_32BINDIR}/make-kernel.sh ${LLVMINSTALLDIR} ${EXTRAFLAGS}
#HOST		= i386-none-linux-gnu
#HOSTTRIPLE	= i386-pc-linux-gnu
CROSS_COMPILE	=
#CC		= clang-wrap.sh
#CPP		= ${CC} -E

KERNEL_SIZE_ARTIFACTS	= arch/x86/boot/bzImage vmlinux*

# Add path so that ${CROSS_COMPILE}${CC} is resolved
PATH		+= :${ARCHX86_32BINDIR}:

gcc x86_64-cc: state/cross-gcc
state/cross-gcc:
	$(call state,$@)

BOARD	= pc

# ${1}=Machine_type ${2}=kerneldir ${3}=RAM ${4}=rootfs ${5}=Kernel_opts ${6}=QEMU_opts
qemu = $(call runqemu,${QEMUBINDIR}/qemu-system-i386,${1},${2}/arch/x86/boot/bzImage,${3},${4},${KERNELOPTS} ${5},${QEMUOPTS} ${6})
