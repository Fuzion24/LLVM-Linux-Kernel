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

#KERNEL_CFG	= ${SRCDIR}/rpi/arch/arm/configs/bcmrpi_cutdown_defconfig
KERNEL_CFG	= ${TARGETDIR}/bcmrpi_cutdown_defconfig
KERNEL_BRANCH	= rpi-3.2.27
KERNEL_GIT	= https://github.com/raspberrypi/linux.git
KERNELDIR	= ${SRCDIR}/rpi

MARCH		= armv6
MFLOAT		= -mfloat-abi=hard -mfpu=vfp
EXTRAFLAGS	= -mcpu=arm1176jzf-s

all: prep kernel-build

.PHONY: clean mrproper


include ${TOPDIR}/common.mk
include ${ARCHDIR}/arm/arm.mk
include ${CONFIG}

KERNEL_PATCH_DIR+= ${PATCHDIR} ${PATCHDIR}/${KERNEL_REPO_PATCHES}
prep: state/prep
state/prep:
	@mkdir -p ${LOGDIR} ${TMPDIR}
	$(call state,$@)

clean: kernel-clean kernel-gcc-clean
	@$(call banner,Clean)

mrproper: clean kernel-mrproper kernel-gcc-mrproper tmp-mrproper
	@rm -rf ${LOGDIR}/*
	@$(call banner,Very Clean)
