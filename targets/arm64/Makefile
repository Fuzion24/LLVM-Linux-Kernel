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

CLANG_TOOLCHAIN	= prebuilt
CROSS_ARM_TOOLCHAIN = native

LLVM_COMMIT = master
CLANG_COMMIT = master

# Need to add EXT4 support to vexpress_defconfig
KERNEL_CFG	= ${KERNELDIR}/arch/arm64/configs/defconfig
KERNEL_DTB	= arch/arm64/boot/dts/foundation-v8.dts
ZIMAGE		= arch/arm64/boot/zImage

all: prep kernel-build

NAME	= foundation-v8
BOARD	= ${NAME}

ARM64_TARGETS		= clean mrproper
TARGETS_BUILD		+= 
CLEAN_TARGETS		+= arm64-clean
HELP_TARGETS		+= arm64-help
FETCH_TARGETS		+= 
MRPROPER_TARGETS	+= arm64-mrproper
RAZE_TARGETS		+= arm64-raze
.PHONY:			${ARM64_TARGETS}

include ${TOPDIR}/common.mk
include ${ARCHDIR}/arm64/arm64.mk

KERNEL_PATCH_DIR+= ${TARGETDIR}/patches

include ${CONFIG}

arm64-help:
	@echo "targets/arm64 has these options:"
	@echo
	@echo "* make clean		- Remove most built files"
	@echo "* make mrproper		- Remove all downloaded and built files"

prep: state/prep
state/prep:
	$(MAKE) ${TMPDIR}
	@mkdir -p ${LOGDIR}
	$(call state,$@)

arm64-clean: kernel-clean kernel-gcc-clean
	@$(call banner,Cleaning Vexpress)

arm64-mrproper: arm64-clean kernel-mrproper kernel-gcc-mrproper
	@$(call banner,Scrubbing Vexpress)
	@rm -rf ${LOGDIR}/*

arm64-raze raze: kernel-raze
	@$(call banner,Razed Vexpress)

clean: arm64-clean
	@$(call banner,Clean)

mrproper: clean arm64-mrproper tmp-mrproper
	@$(call banner,Very Clean)
