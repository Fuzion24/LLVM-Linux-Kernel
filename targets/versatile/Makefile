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

CWD=${CURDIR}
TOPDIR=${CWD}/../..
SRCDIR:=${CWD}/src
INSTALLDIR:=${TOPDIR}/install
KERNELDIR=${SRCDIR}/linux
CFGDIR=${TOPDIR}/config
COMMON=${TOPDIR}/common

.PHONY: kernel-fetch kernel-patch kernel-configure kernel-build test

all: kernel-build

LINUS_KERNEL=git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git)

kernel-fetch: state/kernel-fetch
state/kernel-fetch:
	@mkdir -p ${SRCDIR}
	(cd ${SRCDIR} &&  git clone ${LINUS_KERNEL}
	@mkdir -p state
	@touch $@

kernel-patch: state/kernel-patch
state/kernel-patch: state/kernel-fetch
	(cd ${KERNELDIR} && patch -p1 < ${COMMON}/common.patch)
	(cd ${KERNELDIR} && patch -p1 < ${COMMON}/arm/common-arm.patch)
	@mkdir -p state
	@touch $@

kernel-configure: state/kernel-configure
state/kernel-configure: state/kernel-patch
	@cp ${CWD}/config_vexpress ${KERNELDIR}/.config
	(cd ${KERNELDIR} && make ARCH=arm oldconfig)
	@mkdir -p state
	@touch $@

kernel-build: state/kernel-build 
state/kernel-build: state/kernel-configure 
	(cd ${KERNELDIR} && ${CFGDIR}/make-kernel.sh ${INSTALLDIR})
	@mkdir -p state
	@touch $@

test: state/kernel-build 
	@${INSTALLDIR}/bin/qemu-system-arm -kernel ${KERNELDIR}/arch/arm/boot/zImage \
		-initrd myinitrd -M vexpress-a9 -append 'console=earlycon \
		console=ttyAMA0,38400n8 earlyprintk init=/init' -nographic

