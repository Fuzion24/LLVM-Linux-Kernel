##############################################################################
# Copyright {c} 2012 Mark Charlebois
#               2012 Behan Webster
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files {the "Software"}, to 
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

# Note: This file must be included after ${TOPDIR}/common.mk

STATE_TOOLCHAIN	= state/arm-cc

include ${ARCHDIR}/all/all.mk

ARCH_ARM_DIR	= ${ARCHDIR}/arm
ARCH_ARM_BINDIR	= ${ARCH_ARM_DIR}/bin
ARCH_ARM_PATCHES= ${ARCH_ARM_DIR}/patches
ARCH_ARM_TMPDIR	= ${ARCH_ARM_DIR}/toolchain/tmp
TMPDIRS		+= ${ARCH_ARM_TMPDIR}

ARCH_ARM_TOOLCHAIN = ${ARCH_ARM_DIR}/toolchain
ARCH_ARM_TOOLCHAIN_STATE = ${ARCH_ARM_TOOLCHAIN}/state

FETCH_TARGETS	+= arm-cc

# Configure the requested ARM cross compiler
# Sets CROSS_GCC, PATH, HOST, HOST_TRIPLE
# and state/arm-cc
# This is required whether or not clang is the
# compiler being used. These files must define
# arm-cc which will be a build dep for ARM
ifeq (${CROSS_ARM_TOOLCHAIN},android)
include ${ARCH_ARM_TOOLCHAIN}/android/android.mk
else
ifeq (${CROSS_ARM_TOOLCHAIN},linaro)
include ${ARCH_ARM_TOOLCHAIN}/linaro/linaro.mk
else
include ${ARCH_ARM_TOOLCHAIN}/codesourcery/codesourcery.mk
endif
endif

KERNEL_PATCHES	+= $(call add_patches,${ARCH_ARM_PATCHES})

HELP_TARGETS	+= arm-help
SETTINGS_TARGETS+= arm-settings
VERSION_TARGETS	+= arm-cc-version

ARCH		= arm
MAKE_FLAGS	= ARCH=${ARCH}
MAKE_KERNEL	= ${ARCH_ARM_BINDIR}/make-kernel.sh ${LLVMINSTALLDIR} ${EXTRAFLAGS}
CROSS_COMPILE	= ${HOST}-
CC		= clang-wrap.sh
GCC_CC		= ${HOST}-gcc
CPP		= ${CC} -E

KERNEL_SIZE_ARTIFACTS	= arch/arm/boot/zImage vmlinux*

KERNELOPTS	= console=earlycon console=ttyAMA0,38400n8 earlyprintk

# ${1}=Machine_type ${2}=kerneldir ${3}=RAM ${4}=rootfs ${5}=Kernel_opts ${6}=QEMU_opts
qemu = $(call runqemu,${QEMUBINDIR}/qemu-system-arm,${1},${2}/arch/arm/boot/zImage,${3},${4},${KERNELOPTS} ${5},${QEMUOPTS} ${6})

arm-help:
	@echo
	@echo "* make CROSS_ARM_TOOLCHAIN=[codesourcery,linaro,android] ..."
	@echo "			- Choose the gcc cross toolchain you want to use"

arm-settings:
	@echo "# ARM settings"
	@echo "CROSS_ARM_TOOLCHAIN	= ${CROSS_ARM_TOOLCHAIN}"

