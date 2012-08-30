##############################################################################
# Copyright (c) 2012 Mark Charlebois
#               2012 Jan-Simon Möller
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

TARGETDIR	= ${CURDIR}
TOPDIR		= $(realpath ${TARGETDIR}/../..)

KERNEL_CFG	= ${TARGETDIR}/config_i586
KERNEL_PATCHES	= 
# override KERNEL_BRANCH to v3.3
KERNEL_TAG = v3.3

#GDB_OPTS	= -gdb tcp::1234 -s -S
GDB_OPTS	=

all: prep kernel-build

include ${TOPDIR}/common.mk
include ${ARCHDIR}/i586/i586.mk

TARGETS+= clean mrproper test test2
.PHONY: test test2 fetch-initrd prep clean mrproper

prep: state/prep
state/prep:
	@mkdir -p ${LOGDIR} ${TMPDIR}
	$(call state,$@)

clean: qemu-clean kernel-clean clang-clean llvm-clean initramfs-clean

# do a real wipe
mrproper: clean kernel-clean
	@rm -rf ${LOGDIR}/*
	( cd ${KERNELDIR} && make mrproper )
	rm -f state/kernel-build state/kernel-configure

test: ${QEMUSTATE}/qemu-build initramfs state/kernel-build
	@$(call qemu,${BOARD},${KERNELDIR},768,/dev/ram0,init=/init,-initrd initramfs.img)

