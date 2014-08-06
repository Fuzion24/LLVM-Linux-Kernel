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

CLANG_TOOLCHAIN	= from-source
#CLANG_TOOLCHAIN	= prebuilt
CROSS_AARCH64_TOOLCHAIN = linaro

LLVM_BRANCH = master
CLANG_BRANCH = master

#KERNEL_BRANCH	= linaro-aarch64
#KERNEL_GIT	= git://git.linaro.org/kernel/linaro-aarch64.git
#KERNELDIR	= ${SRCDIR}/linaro-aarch64

KERNEL_REPO_PATCHES=${KERNEL_BRANCH}

# Need to add EXT4 support to vexpress_defconfig
#KERNEL_CFG	= ${KERNELDIR}/arch/arm64/configs/defconfig
KERNEL_CFG	= ${TARGETDIR}/aarch64-kernel.config
IMAGE		= ${KERNEL_BUILD}/arch/arm64/boot/Image

BUILDROOT_ARCH	= aarch64
BUILDROOT_CONFIG= config_vexpress64_buildroot
TOOLCHAINDIR	= $(ARM_CROSS_GCC_TOOLCHAIN)

all: prep kernel-build

NAME	= foundation-v8
BOARD	= ${NAME}

AARCH64_TARGETS		= clean mrproper
TARGETS_BUILD		+= 
CLEAN_TARGETS		+= aarch64-clean
HELP_TARGETS		+= aarch64-help
FETCH_TARGETS		+= 
MRPROPER_TARGETS	+= aarch64-mrproper
RAZE_TARGETS		+= aarch64-raze
.PHONY:			${AARCH64_TARGETS}

include ${TOPDIR}/common.mk
include ${ARCHDIR}/aarch64/aarch64.mk
#include ${TOPDIR}/toolchain/mclinker/mclinker.mk

KERNEL_PATCH_DIR	+= ${TARGETDIR}/patches

include ${CONFIG}

#export CFLAGS_KERNEL += -mllvm -print-call-graph

prep: state/prep
state/prep:
	$(MAKE) ${TMPDIR}
	@mkdir -p ${LOGDIR}
	$(call state,$@)

aarch64-clean: kernel-clean kernel-gcc-clean
	@$(call banner,Cleaning Vexpress)

aarch64-mrproper: aarch64-clean kernel-mrproper kernel-gcc-mrproper
	@$(call banner,Scrubbing Vexpress)
	@rm -rf ${LOGDIR}/*

aarch64-raze raze: kernel-raze
	@$(call banner,Razed Vexpress)

clean: aarch64-clean
	@$(call banner,Clean)

mrproper: clean aarch64-mrproper tmp-mrproper
	@$(call banner,Very Clean)

testlibgcc:
	echo $(shell $(CLANGCC) $(KBUILD_CFLAGS) -print-libgcc-file-name)

test: state/prep ${QEMUSTATE}/qemu-build kernel-build 
	${TOPDIR}/test/qemu/install/bin/qemu-system-aarch64 -machine virt -cpu cortex-a57 -machine type=virt -nographic -smp 1 -m 2048 -kernel ${IMAGE} --append "rdinit=/sbin/init console=ttyAMA0"

