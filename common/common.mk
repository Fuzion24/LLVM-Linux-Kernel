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

# NOTE: TOPDIR, CWD must be defined in the calling Makefile
# NOTE: MAKE_KERNEL and/or MAKE_DEVKERNEL must also be defined in the calling 
#       Makefile

include ${TOPDIR}/clang/clang.mk

TOOLSDIR=${TOPDIR}/tools
COMMON=${TOPDIR}/common

SRCDIR=${CWD}/src
LOGDIR=${CWD}/log
TMPDIR=${CWD}/tmp
PATCH_FILES+=${COMMON}/common.patch ${COMMON}/fix-warnings.patch \
    ${COMMON}/lll-project.patch 
FILTERFILE=${CWD}/kernel-filter
TMPFILTERFILE=${CWD}/tmp/kernel-filter
SYNC_TARGETS+=kernel-sync
LOG_OUTPUT= > ${LOGDIR}/build.log 2>&1

# The ARCH makefile must provide the following:
#   - PATCH_FILES+=... Additional arch specific patch file(s)
#   - MAKE_FLAGS
#   - MAKE_KERNEL
#   
# The target makefile must provide the following:
#   - PATCH_FILES+=... Additional target specific patch file(s)
#   - KERNEL_GIT
#   - KERNEL_CFG
#   - KERNELDIR


TARGETS+=kernel-fetch kernel-patch kernel-configure kernel-build kernel-sync

.PHONY: kernel-fetch kernel-patch kernel-configure kernel-build

kernel-fetch: state/kernel-fetch
state/kernel-fetch: 
	@mkdir -p ${SRCDIR}
	(cd ${SRCDIR} && git clone ${KERNEL_GIT})
	@mkdir -p state
	@touch $@

kernel-patch: state/kernel-patch
state/kernel-patch: state/kernel-fetch
	@mkdir -p ${LOGDIR}
	@mkdir -p ${TMPDIR}
	@${TOOLSDIR}/banner.sh "Checking for duplicated patches:"
	@${TOOLSDIR}/checkduplicates.py ${PATCH_FILES}
	@echo "Testing upstream patches: see ${LOGDIR}/testpatch.log"
	@rm -f ${TMPDIR}/test.patch ${TMPFILTERFILE}-1 ${TMPFILTERFILE}-2 ${FILTERFILE}
	@for patch in ${PATCH_FILES}; do cat $$patch >> ${TMPDIR}/test.patch; done
	(cd ${KERNELDIR} && git reset --hard HEAD)
	@make -i patch-dry-run1
	@${TOOLSDIR}/banner.sh "Creating patch filter: see ${LOGDIR}/filteredpatch.log"
	@${TOOLSDIR}/genfilter.py ${LOGDIR}/testpatch.log ${TMPFILTERFILE}-1
	@${TOOLSDIR}/applyfilter.py ${TMPDIR}/test.patch ${TMPDIR}/filtered.patch ${TMPFILTERFILE}-1
	@${TOOLSDIR}/banner.sh "Testing for missed, unapplied patches: see ${LOGDIR}/filteredpatch.log"
	@make -i patch-dry-run2
	@${TOOLSDIR}/genfilter.py ${LOGDIR}/filteredpatch.log ${TMPFILTERFILE}-2
	@${TOOLSDIR}/banner.sh "Creating final patch: see ${LOGDIR}/filteredpatch.log"
	@cat ${TMPFILTERFILE}-1 ${TMPFILTERFILE}-2 > ${FILTERFILE}
	@${TOOLSDIR}/applyfilter.py ${TMPDIR}/test.patch ${TMPDIR}/final.patch ${FILTERFILE}
	@${TOOLSDIR}/banner.sh "Patching source: see patch.log"
	(cd ${KERNELDIR} && patch -p1 -i ${TMPDIR}/final.patch > ${LOGDIR}/patch.log)
	@mkdir -p state
	@touch $@

patch-dry-run1:
	@rm -f ${LOGDIR}/testpatch.log
	(cd ${KERNELDIR} && patch --dry-run -p1 -i ${TMPDIR}/test.patch > ${LOGDIR}/testpatch.log)

patch-dry-run2:
	@rm -f ${LOGDIR}/filteredpatch.log
	(cd ${KERNELDIR} && patch --dry-run -p1 -i ${TMPDIR}/filtered.patch > ${LOGDIR}/filteredpatch.log)

kernel-clean: state/kernel-fetch
	(cd ${KERNELDIR} && git reset --hard HEAD)
	@rm -f ${CWD}/state/kernel-patch
	@rm -f ${CWD}/state/kernel-configure
	@rm -f ${CWD}/state/kernel-build
	@rm -f ${FILTERFILE}
	@rm -f ${TMPFILTERFILE}-1
	@rm -f ${TMPFILTERFILE}-2
	@rm -f ${LOGDIR}/*.log
	@rm -f ${TMPDIR}/*.patch

kernel-clean-noreset: state/kernel-fetch
	(cd ${KERNELDIR} && make mrproper)
	@rm -f ${CWD}/state/kernel-patch
	@rm -f ${CWD}/state/kernel-configure
	@rm -f ${CWD}/state/kernel-build
	@rm -f ${FILTERFILE}
	@rm -f ${TMPFILTERFILE}-1
	@rm -f ${TMPFILTERFILE}-2
	@rm -f ${LOGDIR}/*.log
	@rm -f ${TMPDIR}/*.patch

kernel-reset: state/kernel-fetch
	(cd ${KERNELDIR} && git reset --hard HEAD)

kernel-configure: state/kernel-configure
state/kernel-configure: state/kernel-patch
	@cp ${KERNEL_CFG} ${KERNELDIR}/.config
	(cd ${KERNELDIR} && echo "" | make ${MAKE_FLAGS} oldconfig)
	@mkdir -p state
	@touch $@

kernel-build: state/kernel-build
state/kernel-build: ${LLVMSTATE}/clang-build state/kernel-configure
	@test -n "${MAKE_KERNEL}" || (echo "Error: MAKE_KERNEL undefined" && false)
	@${TOOLSDIR}/banner.sh "Building kernel..."
	(cd ${KERNELDIR} && ${MAKE_KERNEL} ${LOG_OUTPUT} )
	@mkdir -p state
	@touch $@

kernel-sync: state/kernel-fetch
	@make kernel-clean
	(cd ${KERNELDIR} && git pull)

sync-all:
	@for t in ${SYNC_TARGETS}; do make $$t; done

list-targets:
	@echo "List of available make targets:"
	@(for t in ${TARGETS}; do echo $$t; done)

