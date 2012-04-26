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
KERNEL_CFG=${CWD}/config_x86_64
KERNEL_GIT=git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
KERNELDIR=${SRCDIR}/linux
KERNELCOPY=${SRCDIR}/linux-copy
PATCH_FILES=

#GDB_OPTS=-gdb tcp::1234 -s -S
GDB_OPTS=

# initramfs.mk settings
BUILDDIR=${CWD}/tmp

all: prep kernel-build qemu-build fetch-initrd

include ${TOPDIR}/common/common.mk
include ${TOPDIR}/qemu/qemu.mk
include ${TOPDIR}/common/x86_64/common-x86_64.mk
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
	rm -f tmp/*
	rm -f log/*
	( cd ${KERNELDIR} && make mrproper )

test: ${QEMUSTATE}/qemu-build initramfs state/kernel-build
	@${INSTALLDIR}/bin/qemu-system-i386 -kernel ${KERNELDIR}/arch/x86/boot/bzImage \
		-initrd initramfs.img.gz -append \
		'console=earlycon console=ttyAMA0,38400n8 earlyprintk init=/init' -nographic ${GDB_OPTS}

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

