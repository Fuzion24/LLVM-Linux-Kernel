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

# Need to add EXT4 support to vexpress_defconfig
KERNEL_CFG	= ${TARGETDIR}/config_vexpress
#KERNEL_CFG	= ${KERNELDIR}/arch/arm/configs/vexpress_defconfig
KERNEL_DTB	= arch/arm/boot/dts/vexpress-v2p-ca9.dtb
ZIMAGE		= arch/arm/boot/zImage

BUILDROOT_ARCH	= qemu_arm_vexpress
BUILDROOT_CONFIG= config_vexpress_buildroot
TOOLCHAINDIR	= $(ARM_CROSS_GCC_TOOLCHAIN)

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
TARGETS_BUILD		+= test test[23] test[-gcc]-boot-poweroff clean mrproper
CLEAN_TARGETS		+= vexpress-clean
HELP_TARGETS		+= vexpress-help
FETCH_TARGETS		+= ${INITRAMIMG} ${VEXPRESS_IMG_GZ}
MRPROPER_TARGETS	+= vexpress-mrproper
RAZE_TARGETS		+= vexpress-raze
.PHONY:			${VEXPRESS_TARGETS}

include ${TOPDIR}/common.mk
include ${ARCHDIR}/arm/arm.mk
include ${TARGETDIR}/vexpress-linaro.mk
include ${TARGETDIR}/vexpress-ltp.mk
include ${CONFIG}

KERNEL_PATCH_DIR+= ${TARGETDIR}/patches

vexpress-help:
	@echo "targets/vexpress has these options:"
	@echo
	@echo "* make test-boot-poweroff	- test boot clang built kernel, then power off after init runs"
	@echo "* make test-gcc-boot-poweroff	- test boot gcc built kernel, then power off after init runs"
	@echo
	@echo "* make test		- simple boot to rootfs (make test-[gcc-]boot-poweroff *1)"
	@echo "* make test2		- busybox based initramfs"
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
state/prep: ${TMPDIR}
	@mkdir -p ${LOGDIR}
	$(call state,$@)

#fetch-initrd: state/fetch-initrd
#state/fetch-initrd:
#	rm -f arm-test-0.2.tar.gz
#	wget -nd -c "http://wiki.qemu.org/download/arm-test-0.2.tar.gz"
#	tar -xzvf arm-test-0.2.tar.gz
#	$(call state,$@)

INITRAMIMG	= ${TMPDIR}/initramfs.img
${INITRAMIMG}:
	$(call get_prebuilt, $@)

KERNELDTB_IMG = ${TMPDIR}/kernel_dtb.img
KERNELGCCDTB_IMG = ${TMPDIR}/kernelgcc_dtb.img
${KERNELDTB_IMG}: state/kernel-build
	@$(call check-tmpfs,${KERNELDIR},${KERNEL_BUILD},kernel-mrproper $^)
	cat ${KERNEL_BUILD}/${ZIMAGE} ${KERNEL_BUILD}/${KERNEL_DTB} > $@
${KERNELGCCDTB_IMG}: state/kernel-gcc-build
	@$(call check-tmpfs,${KERNELGCC},${KERNELGCC_BUILD},kernel-gcc-mrproper $^)
	cat ${KERNELGCC_BUILD}/${ZIMAGE} ${KERNELGCC_BUILD}/${KERNEL_DTB} > $@

# state/fetch-initrd
test: state/prep ${QEMUSTATE}/qemu-build ${KERNELDTB_IMG} ${INITRAMIMG} buildroot-build
	$(call qemu_arm,${BOARD},${KERNELDTB_IMG},768,/dev/ram0,rw,-initrd ${INITRAMIMG} -net none -sd ${BUILDROOT_IMG})

# state/fetch-initrd
test-kill: test-boot-poweroff
test-boot-poweroff: state/prep ${KERNELDTB_IMG} ${QEMUSTATE}/qemu-build ${INITRAMIMG}
	( $(call qemu_arm,${BOARD},${KERNELDTB_IMG},256,/dev/ram0,rw,-initrd ${INITRAMIMG} -net none ) \
		| tee ${TMPDIR}/qemu_log ) &
	( sleep 10 && killall -s 9 qemu-system-arm ) || exit 0
	@grep -a "SUCCESS" ${TMPDIR}/qemu_log

test-gcc-kill: test-gcc-boot-poweroff
test-gcc-boot-poweroff: state/prep ${KERNELGCCDTB_IMG} ${QEMUSTATE}/qemu-build ${INITRAMIMG}
	( $(call qemu_arm,${BOARD},${KERNELGCCDTB_IMG},256,/dev/ram0,ramdisk_size=65536 rw POWEROFF,-initrd ${INITRAMIMG} -net none) \
		| tee ${TMPDIR}/qemu_gcc_log ) &
	( sleep 10 && killall -s 9 qemu-system-arm ) || exit 0
	@grep -a "SUCCESS" ${TMPDIR}/qemu_gcc_log

# Create the generic initramfs, add in the kernel modules, then create the cpio
test2: state/prep ${QEMUSTATE}/qemu-build ${KERNELDTB_IMG} initramfs-unpacked
	@rm -rf ${INITBUILDFSDIR}/lib
	(cd ${KERNELDIR} && make INSTALL_MOD_PATH=${INITBUILDFSDIR} ARCH=arm modules_install)
	mkdir -p ${INITBUILDFSDIR}/usr/lib
	@rm -f ${INITRAMFS}
	@make ${INITRAMFS}
	@$(call qemu_arm,${BOARD},${KERNELDTB_IMG},256,/dev/ram0,rdinit=/init,-initrd ${INITRAMFS})

test2-gcc: state/prep ${QEMUSTATE}/qemu-build ${KERNELGCCDTB_IMG} initramfs-unpacked
	@rm -rf ${INITBUILDFSDIR}/lib
	(cd ${KERNELGCC} && make INSTALL_MOD_PATH=${INITBUILDFSDIR} ARCH=arm modules_install)
	mkdir -p ${INITBUILDFSDIR}/usr/lib
	@rm -f ${INITRAMFS}
	@make ${INITRAMFS}
	@$(call qemu_arm,${BOARD},${KERNELGCCDTB_IMG},256,/dev/ram0,rdinit=/init,-initrd ${INITRAMFS})

# Get prebuilt vexpress image
VEXPRESS_IMG_GZ	= ${TMPDIR}/${NANOIMG}.gz
${VEXPRESS_IMG_GZ}:
	$(call get_linaro_prebuilt,$@)

VEXPRESS_IMG	= ${TMPDIR}/vexpress.img
${VEXPRESS_IMG}: ${VEXPRESS_IMG_GZ}
	gzip -dc $< > $@

test3: state/prep ${QEMUSTATE}/qemu-build ${KERNELDTB_IMG} ${VEXPRESS_IMG}
	$(call qemu_arm,${BOARD},${KERNELDTB_IMG},256,/dev/mmcblk0p2,rootfstype=ext4 init=/bin/bash,-sd ${VEXPRESS_IMG}) ${NET}

test3-gcc: state/prep ${QEMUSTATE}/qemu-build ${KERNELGCCDTB_IMG} ${VEXPRESS_IMG}
	@$(call qemu_arm,${BOARD},${KERNELGCCDTB_IMG},256,/dev/mmcblk0p2,rootfstype=ext4 init=/bin/bash,-sd ${VEXPRESS_IMG}) ${NET}

BUILDROOT_IMG	= ${TMPDIR}/sd-rootfs-squashfs.img
${BUILDROOT_IMG}: buildroot-build
	@$(call banner,Building SD card for buildroot rootfs)
	$(call buildroot-sdcard,images/rootfs.squashfs,$@)

test4: state/prep ${QEMUSTATE}/qemu-build ${KERNELDTB_IMG} ${BUILDROOT_IMG}
	$(call qemu_arm,${BOARD},${KERNELDTB_IMG},256,/dev/ram0,ramdisk_size=64M rw POWEROFF,-initrd ${BUILDROOT_CPIO}) ${NET}
#	$(call qemu_arm,${BOARD},${KERNELDTB_IMG},256,/dev/mtdblock1,rootfstype=squashfs rootwait init=/bin/bash,-sd ${BUILDROOT_IMG}) ${NET}

vexpress-clean: kernel-clean kernel-gcc-clean
	@$(call banner,Cleaning Vexpress)
	rm -f ${VEXPRESS_IMG}

vexpress-mrproper: vexpress-clean kernel-mrproper kernel-gcc-mrproper
	@$(call banner,Scrubbing Vexpress)
	rm -f ${VEXPRESS_IMG} ${VEXPRESS_IMG_GZ}
#	-rm -rf arm-test-0.2.tar.gz arm-test
	@rm -rf ${LOGDIR}/*

vexpress-raze raze: kernel-raze
	@$(call banner,Razed Vexpress)

clean: vexpress-clean vexpress-linaro-clean vexpress-ltp-clean
	@$(call banner,Clean)

mrproper: clean vexpress-mrproper vexpress-linaro-mrproper vexpress-ltp-mrproper tmp-mrproper
	@$(call banner,Very Clean)
