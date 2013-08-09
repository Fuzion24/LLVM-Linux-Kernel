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

KERNEL_CFG	= ${KERNELDIR}/arch/x86/configs/x86_64_defconfig

GDB_OPTS	=

all: prep kernel-build

include ${TOPDIR}/common.mk
include ${ARCHDIR}/x86_64/x86_64.mk

ARCH_ARM_DIR	= ${ARCHDIR}/arm
ARCH_ARM_PATCHES= ${ARCH_ARM_DIR}/patches
KERNEL_PATCH_DIR+= ${ARCH_ARM_PATCHES} ${ARCH_ARM_PATCHES}/${KERNEL_REPO_PATCHES}

include ${CONFIG}

TARGETS+= clean mrproper
.PHONY: prep clean mrproper

#############################################################################
prep: state/prep
state/prep:
	$(MAKE) ${TMPDIR}
	@mkdir -p ${LOGDIR}
	$(call state,$@)

#############################################################################
clean: kernel-clean kernel-gcc-clean
	@$(call banner,Clean)

#############################################################################
mrproper: clean kernel-mrproper kernel-gcc-mrproper tmp-mrproper
	@rm -rf ${LOGDIR}
	@$(call banner,Very Clean)

#############################################################################
kernel-patch-required:
	@$(call banner,Patch status for the kernel)
	@$(call patch_status_extract,required,Y.*,${PATCHDIR})

#############################################################################
kernel-patch-required-series:
	@$(call banner,Patch status for the kernel)
	@$(call patch_status_extract,required,Y.*,${PATCHDIR}) | tee ${PATCHDIR}/series

#############################################################################
kernel-patch-for-linus:
	@$(call banner,Patch status for the kernel)
	@$(call patch_status_extract,finalpatchforlinus,Y.*,${PATCHDIR})

#############################################################################
kernel-patch-for-linus-series:
	@$(call banner,Patch status for the kernel)
	@$(call patch_status_extract,finalpatchforlinus,Y.*,${PATCHDIR}) | tee ${PATCHDIR}/series

