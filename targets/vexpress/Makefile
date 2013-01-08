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

#KERNEL_CFG	= ${TARGETDIR}/config_vexpress
KERNEL_CFG	= ${KERNELDIR}/arch/arm/configs/vexpress_defconfig
KERNEL_DTB	= ${KERNELDIR}/arch/arm/boot/dts/vexpress-v2p-ca9.dtb

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
state/prep:
	@mkdir -p ${LOGDIR} ${TMPDIR}
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

# state/fetch-initrd
test: state/prep ${QEMUSTATE}/qemu-build state/kernel-build ${INITRAMIMG}
	$(cat ${KERNELDIR}/arch/arm/boot/zImage ${KERNEL_DTB} > ${TMPDIR}/kernel_dtb.img )
	$(call qemu_arm,${BOARD},${TMPDIR}/kernel_dtb.img,768,/dev/ram0,rw,-initrd ${INITRAMIMG} -net none)

# state/fetch-initrd
test-kill: test-boot-poweroff
test-boot-poweroff: state/prep state/kernel-build ${QEMUSTATE}/qemu-build ${INITRAMIMG}
	(cat ${KERNELDIR}/arch/arm/boot/zImage ${KERNEL_DTB} > ${TMPDIR}/kernel_dtb.img )
	( $(call qemu_arm,${BOARD},${TMPDIR}/kernel_dtb.img,256,/dev/ram0,rw,-initrd ${INITRAMIMG} -net none ) \
		| tee tmp/qemu_log ) &
	( sleep 10 && killall -s 9 qemu-system-arm ) || exit 0
	@grep -a "SUCCESS" tmp/qemu_log 

test-gcc-kill: test-gcc-boot-poweroff
test-gcc-boot-poweroff: state/prep state/kernel-gcc-build ${QEMUSTATE}/qemu-build ${INITRAMIMG}
	(cat ${KERNELGCC}/arch/arm/boot/zImage ${KERNEL_DTB} > ${TMPDIR}/kernelgcc_dtb.img )
	( $(call qemu_arm,${BOARD},${TMPDIR}/kernelgcc_dtb.img,256,/dev/ram0,ramdisk_size=65536 rw POWEROFF,-initrd ${INITRAMIMG} -net none) \
		| tee tmp/qemu_gcc_log ) &
	( sleep 10 && killall -s 9 qemu-system-arm ) || exit 0
	@grep -a "SUCCESS" tmp/qemu_gcc_log 

# Create the generic initramfs, add in the kernel modules, then create the cpio
test2: state/prep ${QEMUSTATE}/qemu-build state/kernel-build initramfs-unpacked
	@rm -rf ${INITBUILDFSDIR}/lib
	(cd ${KERNELDIR} && make INSTALL_MOD_PATH=${INITBUILDFSDIR} ARCH=arm modules_install)
	mkdir -p ${INITBUILDFSDIR}/usr/lib
	@rm -f ${INITRAMFS}
	@make ${INITRAMFS}
	@$(call qemu_arm,${BOARD},${KERNELDIR},256,/dev/ram0,rdinit=/bootstrap,-initrd ${INITRAMFS})

test2-gcc: state/prep ${QEMUSTATE}/qemu-build state/kernel-gcc-build initramfs-unpacked
	@rm -rf ${INITBUILDFSDIR}/lib
	(cd ${KERNELGCC} && make INSTALL_MOD_PATH=${INITBUILDFSDIR} ARCH=arm modules_install)
	mkdir -p ${INITBUILDFSDIR}/usr/lib
	@rm -f ${INITRAMFS}
	@make ${INITRAMFS}
	@$(call qemu_arm,${BOARD},${KERNELGCC},256,/dev/ram0,rdinit=/bootstrap,-initrd ${INITRAMFS})

# Get prebuilt vexpress image
VEXPRESS_IMG_GZ	= ${TMPDIR}/${NANOIMG}.gz
${VEXPRESS_IMG_GZ}:
	$(call get_linaro_prebuilt,$@)

VEXPRESS_IMG	= ${TMPDIR}/vexpress.img
${VEXPRESS_IMG}: ${VEXPRESS_IMG_GZ}
	gzip -dc $< > $@

test3: state/prep ${QEMUSTATE}/qemu-build state/kernel-gcc-build ${VEXPRESS_IMG}
	@$(call qemu_arm,${BOARD},${KERNELGCC},256,/dev/mmcblk0p2,rootfstype=ext4 init=/bin/bash,-sd ${VEXPRESS_IMG}) ${NET}

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

