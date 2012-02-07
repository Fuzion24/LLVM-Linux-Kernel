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

TOPDIR=${CWD}/../..
CWD=${CURDIR}
KERNEL_CFG=${CWD}/config_vexpress
KERNEL_GIT=git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
KERNELDIR=${SRCDIR}/linux
PATCH_FILES=${CWD}/workaround.patch

#GDB_OPTS=-gdb tcp::1234 -s -S
GDB_OPTS=

# initramfs.mk settings
BUILDDIR=${CWD}/tmp
MAKE_BINARY=/opt/arm-2011.03/bin/arm-none-linux-gnueabi-gcc


all: kernel-build 

include ${TOPDIR}/qemu/qemu.mk
include ${TOPDIR}/common/common.mk
include ${TOPDIR}/common/arm/common-arm.mk
include ${TOPDIR}/initramfs/initramfs.mk

.PHONY: test

fetch-initrd: state/fetch-initrd
state/fetch-initrd:
	rm -f arm-test-0.2.tar.gz
	wget -nd -c "http://wiki.qemu.org/download/arm-test-0.2.tar.gz"
	tar -xzvf arm-test-0.2.tar.gz
	@mkdir -p state
	@touch $@
  
test: ${QEMUSTATE}/qemu-build state/fetch-initrd
	test -f state/kernel-build || test -f state/kernel-devbuild || \
		(echo "Error: must have built either kernel-build or kernel-devbuild" && false)
	@${INSTALLDIR}/bin/qemu-system-arm -kernel ${KERNELDIR}/arch/arm/boot/zImage \
		-initrd arm-test/arm_root.img -M vexpress-a9 -append 'console=earlycon \
		console=ttyAMA0,38400n8 earlyprintk init=/init' -nographic ${GDB_OPTS}

test2: ${QEMUSTATE}/qemu-build initramfs.img.gz
	test -f state/kernel-build || test -f state/kernel-devbuild || \
		(echo "Error: must have built either kernel-build or kernel-devbuild" && false)
	@${INSTALLDIR}/bin/qemu-system-arm -kernel ${KERNELDIR}/arch/arm/boot/zImage \
		-initrd initramfs.img.gz -M vexpress-a9 -append 'console=earlycon \
		console=ttyAMA0,38400n8 earlyprintk init=/init' -nographic ${GDB_OPTS}

