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

KERNEL_CFG	= ${TARGETDIR}/config_template

KERNEL_PATCHES     += $(call add_patches,${TARGETDIR}/patches)

all: bailout_remove prep kernel-build
.PHONY: clean mrproper

include ${TOPDIR}/common.mk
#include ${ARCHDIR}/arm/arm.mk

bailout_remove:
	@exit 1

prep: state/prep
state/prep:
	@mkdir -p ${LOGDIR} ${TMPDIR}
	$(call state,$@)

clean: tmp-clean
	( ( test -e ${KERNELDIR} && make kernel-clean ) || exit 0 )
	@make clang-clean llvm-clean

# do a real wipe
mrproper: clean
	( ( test -e ${KERNELDIR} && cd ${KERNELDIR} && make mrproper ) || exit 0 )
	@rm -rf ${LOGDIR}/* ${TMPDIR}/*

