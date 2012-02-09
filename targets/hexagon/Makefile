##############################################################################
# Copyright (c) 2012 Mark Charlebois
# 					 Jan-Simon Möller
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

CWD=${CURDIR}
TOPDIR=${CWD}/../..
KERNEL_GIT=git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
KERNELDIR=${SRCDIR}/linux
KERNEL_CFG=${KERNELDIR}/arch/hexagon/configs/comet_defconfig
PATCH_FILES=
MAKE_DEVKERNEL=${CWD}/make_kernel.sh

# Only the development version of clang supoprts hexagon
all: kernel-devbuild
.PHONY: clean mrproper

include ${TOPDIR}/common/common.mk


clean: 
	( ( test -e ${KERNELDIR} && make kernel-clean ) || exit 0 )
	@make clang-clean

# do a real wipe
mrproper: clean
	( ( test -e ${KERNELDIR} && cd ${KERNELDIR} && make mrproper ) || exit 0 )
