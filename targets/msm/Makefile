##############################################################################
# Copyright (c) 2012 Mark Charlebois
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

CWD=${CURDIR}
TOPDIR=${CWD}/../..
SRCDIR=${CWD}/src
INSTALLDIR=${TOPDIR}/install
MSMDIR=${SRCDIR}/msm
COMMON=${TOPDIR}/common
CFGDIR=${TOPDIR}/config

.PHONY: kernel-fetch kernel-patch kernel-configure kernel-build

all: kernel-build

MSM_KERNEL="git://codeaurora.org/kernel/msm.git"
MSM_BRANCH="kernel-3.0"

kernel-fetch: state/kernel-fetch
state/kernel-fetch: 
	@mkdir -p ${SRCDIR}
	(cd ${SRCDIR} && git clone ${MSM_KERNEL} -b ${MSM_BRANCH})
	@mkdir -p state
	@touch $@

kernel-patch: state/kernel-patch
state/kernel-patch: state/kernel-fetch
	(cd ${MSMDIR} && patch -p1 < ${COMMON}/common.patch)
	(cd ${MSMDIR} && patch -p1 < ${COMMON}/fix-warnings.patch)
	(cd ${MSMDIR} && patch -p1 < ${COMMON}/arm/common-arm.patch)
	(cd ${MSMDIR} && patch -p1 < ${COMMON}/arm/fix-warnings-arm.patch)
	(cd ${MSMDIR} && patch -p1 < ${CWD}/kernel-3.0-llvm.patch)
	(cd ${MSMDIR} && patch -p1 < ${CWD}/fix-warnings.patch)
	@mkdir -p state
	@touch $@

kernel-clean: 
	(cd ${MSMDIR} && git status | grep "modified:" | cut -d":" -f 2 | xargs git checkout)
	@rm -f ${CWD}/state/kernel-patch
	@rm -f ${CWD}/state/kernel-configure

kernel-configure: state/kernel-configure
state/kernel-configure: state/kernel-patch
	@cp config_msm ${MSMDIR}/.config
	(cd ${MSMDIR} && make ARCH=arm oldconfig)
	@mkdir -p state
	@touch $@

kernel-build: state/kernel-build
state/kernel-build: state/kernel-configure
	(cd ${MSMDIR} && ${CFGDIR}/make-kernel.sh ${INSTALLDIR})
	@mkdir -p state
	@touch $@
