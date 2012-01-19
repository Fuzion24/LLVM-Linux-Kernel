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
TOPDIR=${CWD}/..
SRCDIR:=${CWD}/src
INSTALLDIR:=${CWD}/install
MSMDIR=${SRCDIR}/msm
CFGDIR=${TOPDIR}/config

.PHONY: msm-fetch msm-patch msm-configure msm-build

all: msm-build

MSM_KERNEL="git://codeaurora.org/kernel/msm.git"
MSM_BRANCH="msm-3.0"
MSM_PATCH=msm-3.0-llvm.patch

msm-fetch: state/msm-fetch
state/msm-fetch: 
	@mkdir -p ${SRCDIR}
	(cd ${SRCDIR} && git clone ${MSM_KERNEL} -b ${MSM_BRANCH})
	@mkdir -p state
	@touch $@

msm-patch: state/msm-patch
state/msm-patch: state/msm-fetch
	(cd ${MSMDIR} && patch -p1 < ${COMMON}/common.patch)
	(cd ${MSMDIR} && patch -p1 < ${COMMON}/arm/common-arm.patch)
	(cd ${MSMDIR} && patch -p1 < ${MSM_PATCH})
	@mkdir -p state
	@touch $@

msm-configure: state/msm-configure
state/msm-configure: state/msm-patch
	@cp config_msm ${MSMDIR}/.config
	(cd ${MSMDIR} && make ARCH=arm oldconfig)
	@mkdir -p state
	@touch $@

msm-build: state/msm-build
state/msm-build: state/msm-configure
	(cd ${MSMDIR} && ${CFGDIR}/make-kernel.sh ${INSTALLDIR})
	@mkdir -p state
	@touch $@
