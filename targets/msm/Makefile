##############################################################################
# Copyright (c) 2012 Mark Charlebois
#                    Jan-Simon Möller
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
KERNEL_CFG=${CWD}/config_msm
MSM_BRANCH=msm-3.0
KERNEL_GIT=git://codeaurora.org/kernel/msm.git -b ${MSM_BRANCH}
KERNELDIR=${SRCDIR}/msm
KERNELCOPY=${SRCDIR}/msm-copy
PATCH_FILES=${CWD}/msm-3.0-llvm.patch ${CWD}/msm-3.0-llvm-arm.patch \
	${CWD}/fix-warnings.patch ${CWD}/fix-warnings-arm.patch \
#	${CWD}/autopatch.patch

all: prep kernel-build

include ../../common/common.mk
include ../../common/arm/common-arm.mk

.PHONY: kernel-copy clean mrproper

prep: state/prep
state/prep:
	@mkdir -p tmp
	@mkdir -p log
	@mkdir -p state
	@touch $@

kernel-copy: state/kernel-copy
state/kernel-copy: kernel-fetch
	(cd ${SRCDIR} && git clone ${KERNELDIR} -b ${MSM_BRANCH} msm-copy)
	@touch $@

kernel-autopatch: kernel-build
	(cd ${KERNELCOPY} && git reset --hard HEAD && git pull)
	(cd ${KERNELCOPY} &&  patch -p1 -i ${TMPDIR}/final.patch >> ${LOGDIR}/patchcopy.log)
	@${TOOLSDIR}/unusedfix.py ${LOGDIR}/build.log ${KERNELCOPY} 
	(cd ${KERNELCOPY} &&  patch -R -p1 -i ${TMPDIR}/final.patch >> ${LOGDIR}/patchcopy.log)
	(cd ${KERNELCOPY} && git diff > ${TMPDIR}/autopatch.patch)
	@${TOOLSDIR}/splitarch.py ${TMPDIR}/autopatch.patch ${CWD} autopatch
	@touch $@

check-dups:
	${TOOLSDIR}/checkduplicates.py ${PATCH_FILES}

clean: 
	( ( test -e ${KERNELDIR} && make kernel-clean ) || exit 0 )
	@make clang-clean

# do a real wipe
mrproper: clean
	( ( test -e ${KERNELDIR} && cd ${KERNELDIR} && make mrproper ) || exit 0 )
	@rm -rf tmp/*
	@rm -rf log/*