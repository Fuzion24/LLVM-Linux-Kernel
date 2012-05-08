##############################################################################
# Copyright (c) 2012 Mark Charlebois
#                    Jan-Simon Möller
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
KERNELCOPY=${SRCDIR}/linux-copy
PATCH_FILES=${CWD}/workaround.patch ${CWD}/vexpress.patch

#GDB_OPTS=-gdb tcp::1234 -s -S
GDB_OPTS=

# initramfs.mk settings
BUILDDIR=${CWD}/tmp

all: prep kernel-build qemu-build fetch-initrd

include ${TOPDIR}/common/common.mk
include ${TOPDIR}/qemu/qemu.mk
include ${TOPDIR}/common/arm/common-arm.mk
include ${TOPDIR}/initramfs/initramfs.mk

TARGETS+= clean mrproper test test2
.PHONY: test test2 fetch-initrd prep clean mrproper

prep: state/prep
state/prep:
	@mkdir -p tmp
	@mkdir -p log
	@mkdir -p state
	@touch $@


clean: qemu-clean kernel-clean clang-clean initramfs-clean

# do a real wipe
mrproper: clean
	rm -rRf arm-test-0.2.tar.gz arm-test
	rm -f state/fetch-initrd
	rm -f tmp/*
	rm -f log/*
	( cd ${KERNELDIR} && make mrproper )

fetch-initrd: state/fetch-initrd
state/fetch-initrd:
	rm -f arm-test-0.2.tar.gz
	wget -nd -c "http://wiki.qemu.org/download/arm-test-0.2.tar.gz"
	tar -xzvf arm-test-0.2.tar.gz
	@mkdir -p state
	@touch $@
  
test: ${QEMUSTATE}/qemu-build state/fetch-initrd state/kernel-build
	@${INSTALLDIR}/bin/qemu-system-arm -kernel ${KERNELDIR}/arch/arm/boot/zImage \
		-initrd arm-test/arm_root.img -M vexpress-a9 -append 'console=earlycon \
		console=ttyAMA0,38400n8 earlyprintk root=/dev/ram0 rdinit=/bin/sh init=/bin/sh' -nographic -net none ${GDB_OPTS}

test-kill: ${QEMUSTATE}/qemu-build state/fetch-initrd state/kernel-build
	( ${INSTALLDIR}/bin/qemu-system-arm -kernel ${KERNELDIR}/arch/arm/boot/zImage -initrd arm-test/arm_root.img -M vexpress-a9 -append 'console=earlycon console=ttyAMA0,38400n8 earlyprintk root=/dev/ram0 rdinit=/bin/sh init=/bin/sh' -nographic -net none ${GDB_OPTS} & )
	( ( sleep 300 && killall -s 9 qemu-system-arm ) || exit 0 )


test2: ${QEMUSTATE}/qemu-build initramfs state/kernel-build
	@${INSTALLDIR}/bin/qemu-system-arm -kernel ${KERNELDIR}/arch/arm/boot/zImage \
		-initrd initramfs.img.gz -M vexpress-a9 -append \
		'console=earlycon console=ttyAMA0,38400n8 earlyprintk init=/init' -nographic ${GDB_OPTS}

patch-update: state/kernel-patch
	@${TOPDIR}/tools/applyfilter.py ${TOPDIR}/common/common.patch ${TMPDIR}/common.patch ${CWD}/kernel-filter
	@${TOPDIR}/tools/applyfilter.py ${TOPDIR}/common/fix-warnings.patch ${TMPDIR}/fix-warnings.patch ${CWD}/kernel-filter
	@${TOPDIR}/tools/applyfilter.py ${TOPDIR}/common/fix-warnings-unused.patch ${TMPDIR}/fix-warnings-unused.patch ${CWD}/kernel-filter
	@${TOPDIR}/tools/applyfilter.py ${TOPDIR}/common/arm/common-arm.patch ${TMPDIR}/common-arm.patch ${CWD}/kernel-filter
	@${TOPDIR}/tools/applyfilter.py ${TOPDIR}/common/arm/fix-warnings-arm.patch ${TMPDIR}/fix-warnings-arm.patch ${CWD}/kernel-filter
	@${TOPDIR}/tools/applyfilter.py ${TOPDIR}/common/arm/fix-warnings-arm-unused.patch ${TMPDIR}/fix-warnings-arm-unused.patch ${CWD}/kernel-filter

kernel-copy: state/kernel-copy
state/kernel-copy: kernel-fetch
	(cd ${SRCDIR} && git clone ${KERNELDIR} linux-copy)
	@touch $@

kernel-autopatch: kernel-build state/kernel-copy
	(cd ${KERNELCOPY} && git reset --hard HEAD && git pull)
	(cd ${KERNELCOPY} &&  patch -p1 -i ${TMPDIR}/final.patch >> ${LOGDIR}/patchcopy.log)
	@${TOOLSDIR}/unusedfix.py ${LOGDIR}/build.log ${KERNELCOPY} 
	(cd ${KERNELCOPY} &&  patch -R -p1 -i ${TMPDIR}/final.patch >> ${LOGDIR}/patchcopy.log)
	(cd ${KERNELCOPY} && git diff > ${TMPDIR}/autopatch.patch)
	@${TOOLSDIR}/splitarch.py ${TMPDIR}/autopatch.patch ${CWD} autopatch
	@touch $@

