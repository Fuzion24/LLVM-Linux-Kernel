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
CROSS_ARM_TOOLCHAIN = codesourcery

KERNEL_CFG	= ${TARGETDIR}/config_vexpress

KERNEL_PATCHES	+= $(call add_patches,${TARGETDIR}/patches)

BUILDMODE	:= DEFAULT

ifeq ('${GDBON}','1')
GDB_OPTS=-gdb tcp::4321 -S
else
GDB_OPTS=
endif

all: prep kernel-build test-boot-poweroff

NAME	= vexpress
BOARD	= ${NAME}-a9

NET	= -net nic,macaddr=52:54:00:12:34:57

BUILDBOT_PREBUILT_URL	= http://buildbot.llvm.linuxfoundation.org/prebuilt/arm/${NAME}
get_prebuilt		= mkdir -p $(dir ${1}) && wget -P $(dir ${1}) -c ${BUILDBOT_PREBUILT_URL}/$(notdir ${1})

VEXPRESS_TARGETS	= test test2 test3 \
			test-boot-poweroff test-gcc-boot-poweroff \
			clean mrproper
TARGETS			+= ${VEXPRESS_TARGETS}
HELP_TARGETS		+= vexpress-help
.PHONY:			${VEXPRESS_TARGETS}

include ${TARGETDIR}/vexpress-linaro.mk
include ${TOPDIR}/common.mk
include ${ARCHDIR}/arm/arm.mk
include ${TARGETDIR}/vexpress-ltp.mk
include ${CONFIG}

vexpress-help:
	@echo "targets/vexpress has these options:"
	@echo
	@echo "* make test-boot-poweroff	- test boot clang built kernel, then power off after init runs"
	@echo "* make test-gcc-boot-poweroff	- test boot gcc built kernel, then power off after init runs"
	@echo
	@echo "* make test		- simple boot to rootfs (make test-[gcc-]boot-poweroff *1)"
	@echo "* make test2		- bsd userspace with toybox"
	@echo "* make test3		- linaro/ubuntu rootfs"
	@echo
	@echo " Note: You currently have to do a 'killall qemu-system-arm' from another terminal"
	@echo "       to exit from the above tests."
	@echo
	@echo "* make patch-update"
	@echo
	@echo "* make clean		- Remove most built files"
	@echo "* make mrproper		- Remove all downloaded and built files"

prep: state/prep
state/prep:
	@mkdir -p ${LOGDIR} ${TMPDIR}
	$(call state,$@)

#fetch-initrd: state/fetch-initrd
#state/fetch-initrd:
#	rm -f arm-test-0.2.tar.gz
#	wget -nd -c "http://wiki.qemu.org/download/arm-test-0.2.tar.gz"
#	tar -xzvf arm-test-0.2.tar.gz
#	$(call state,$@)

INITRAMFS	= ${TMPDIR}/initramfs.img
${INITRAMFS}:
	$(call get_prebuilt, $@)

# state/fetch-initrd
test: state/prep ${QEMUSTATE}/qemu-build state/kernel-build ${INITRAMFS}
	@$(call qemu,${BOARD},${KERNELDIR},768,/dev/ram0,ramdisk_size=65536 rw,-initrd ${INITRAMFS} -net none)

# state/fetch-initrd
test-kill: test-boot-poweroff
test-boot-poweroff: state/prep state/kernel-build ${QEMUSTATE}/qemu-build ${INITRAMFS}
	( $(call qemu,${BOARD},${KERNELDIR},256,/dev/ram0,ramdisk_size=65536 rw POWEROFF,-initrd ${INITRAMFS} -net none) \
		| tee tmp/qemu_log ) &
	( sleep 10 && killall -s 9 qemu-system-arm ) || exit 0
	@grep -a "SUCCESS" tmp/qemu_log 

test-gcc-kill: test-gcc-boot-poweroff
test-gcc-boot-poweroff: state/prep state/kernel-gcc-build ${QEMUSTATE}/qemu-build ${INITRAMFS}
	( $(call qemu,${BOARD},${KERNELGCC},256,/dev/ram0,ramdisk_size=65536 rw POWEROFF,-initrd ${INITRAMFS} -net none) \
		| tee tmp/qemu_gcc_log ) &
	( sleep 10 && killall -s 9 qemu-system-arm ) || exit 0
	@grep -a "SUCCESS" tmp/qemu_gcc_log 

test2: state/prep ${QEMUSTATE}/qemu-build state/kernel-build initramfs
	@$(call qemu,${BOARD},${KERNELDIR},256,/dev/ram0,init=/bin/init,-initrd initramfs.img.gz)

# Get prebuilt vexpress image
${TMPDIR}/${NANOIMG}.gz:
	$(call get_linaro_prebuilt,$@)

VEXPRESS_IMG	= ${TMPDIR}/vexpress.img
${VEXPRESS_IMG}: ${TMPDIR}/${NANOIMG}.gz
	gzip -dc $< > $@

test3: state/prep ${QEMUSTATE}/qemu-build state/kernel-build ${VEXPRESS_IMG}
	@$(call qemu,${BOARD},${KERNELDIR},256,/dev/mmcblk0p2,rootfstype=ext4 init=/bin/bash,-sd ${VEXPRESS_IMG}) ${NET}

patch-update: state/kernel-patch
	@${TOOLSDIR}/applyfilter.py ${ARCH_ALL_PATCHES}/common.patch ${TMPDIR}/common.patch ${FILTERFILE}
	@${TOOLSDIR}/applyfilter.py ${ARCH_ALL_PATCHES}/fix-warnings.patch ${TMPDIR}/fix-warnings.patch ${FILTERFILE}
	@${TOOLSDIR}/applyfilter.py ${ARCH_ALL_PATCHES}/fix-warnings-unused.patch ${TMPDIR}/fix-warnings-unused.patch ${FILTERFILE}
	@${TOOLSDIR}/applyfilter.py ${ARCH_ARM_PATCHES}/common-arm.patch ${TMPDIR}/common-arm.patch ${FILTERFILE}
	@${TOOLSDIR}/applyfilter.py ${ARCH_ARM_PATCHES}/fix-warnings-arm.patch ${TMPDIR}/fix-warnings-arm.patch ${FILTERFILE}
	@${TOOLSDIR}/applyfilter.py ${ARCH_ARM_PATCHES}/fix-warnings-arm-unused.patch ${TMPDIR}/fix-warnings-arm-unused.patch ${FILTERFILE}

clean-vexpress:
	rm -f ${VEXPRESS_IMG}
	rm -f state/kernel-patch

mrproper-vexpress:
	rm -f ${TMPDIR}/${NANOIMG}.gz
	-rm -rf arm-test-0.2.tar.gz arm-test
	@rm -rf ${LOGDIR}/*
	( cd ${KERNELDIR} && make mrproper )
	-( cd ${KERNELGCC} && make mrproper )

clean: clean-vexpress clean-vexpress-linaro clean-vexpress-ltp \
	qemu-clean kernel-clean clang-clean llvm-clean initramfs-clean

mrproper: clean mrproper-vexpress mrproper-vexpress-linaro mrproper-vexpress-ltp \
	ltp-mrproper tmp-mrproper

