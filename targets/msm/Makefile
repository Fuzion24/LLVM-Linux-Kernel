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
CROSS_ARM_TOOLCHAIN = android

KERNEL_CFG	= ${SRCDIR}/msm/arch/arm/configs/msm8960_defconfig
KERNEL_BRANCH	= msm-3.4
KERNEL_GIT	= git://codeaurora.org/kernel/msm.git
KERNELDIR	= ${SRCDIR}/msm
KERNEL_TAG	= AU_LINUX_BASE_TARGET_ALL.01.00.461

#Use the branch name for the dir containing MSM specific patch overrides
KERNEL_REPO_PATCHES=${KERNEL_BRANCH}

EXTRAFLAGS	= 
#EXTRAFLAGS	= -Iarch/arm/mach-msm

all: prep kernel-build

include ${TOPDIR}/common.mk
include ${ARCHDIR}/arm/arm.mk
include ${CONFIG}

KERNEL_PATCHES	+= $(call add_patches,${TARGETDIR}/patches)
KERNEL_PATCH_DIR+= ${TARGETDIR}/patches ${TARGETDIR}/patches/${KERNEL_REPO_PATCHES}

TARGETS+= check-dups kernel-autopatch clean mrproper
.PHONY: kernel-copy clean mrproper

prep: state/prep
state/prep:
	@mkdir -p ${LOGDIR} ${TMPDIR}
	$(call state,$@)

check-dups:
	${TOOLSDIR}/checkduplicates.py ${KERNEL_PATCHES}

clean: 
	( ( test -e ${KERNELDIR} && make kernel-clean ) || exit 0 )
	@make llvm-clean clang-clean

# do a real wipe
mrproper: clean tmp-mrproper
	( ( test -e ${KERNELDIR} && cd ${KERNELDIR} && make mrproper ) || exit 0 )
	@rm -rf ${LOGDIR}/*

get-msm-tags:
