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

KERNEL_CFG	= ${TARGETDIR}/config_x86_64
KERNEL_PATCHES	= 

#GDB_OPTS	= -gdb tcp::1234 -s -S
GDB_OPTS	=

all: prep kernel-build qemu-build fetch-initrd

include ${TOPDIR}/common.mk
include ${ARCHDIR}/x86_64/x86_64.mk

TARGETS+= clean mrproper test test2
.PHONY: test test2 fetch-initrd prep clean mrproper

prep: state/prep
state/prep:
	@mkdir -p tmp
	@mkdir -p log
	@mkdir -p state
	$(call state,$@)

clean: qemu-clean kernel-clean clang-clean llvm-clean initramfs-clean

# do a real wipe
mrproper: clean tmp-proper
	@rm -rf ${LOGDIR}/*
	( cd ${KERNELDIR} && make mrproper )

test: ${QEMUSTATE}/qemu-build initramfs state/kernel-build
	@${INSTALLDIR}/bin/qemu-system-i386 -kernel ${KERNELDIR}/arch/x86/boot/bzImage \
		-initrd initramfs.img.gz -append \
		'console=earlycon console=ttyAMA0,38400n8 earlyprintk init=/init' -nographic ${GDB_OPTS}

