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

TOPDIR=${CWD}/../..
TOOLSDIR=${TOPDIR}/tools
SRCDIR=${CWD}/src
LOGDIR=${CWD}/log
INSTALLDIR=${TOPDIR}/install
COMMON=${TOPDIR}/common
PATCH_FILES+=${COMMON}/common.patch ${COMMON}/fix-warnings.patch \
	${COMMON}/fix-warnings-unused.patch
FILTERFILE=${CWD}/state/kernel-filter

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

.PHONY: kernel-fetch gen-patch kernel-patch kernel-configure kernel-build

all: kernel-build

kernel-fetch: state/kernel-fetch
state/kernel-fetch: 
	@mkdir -p ${SRCDIR}
	(cd ${SRCDIR} && git clone ${KERNEL_GIT})
	@mkdir -p state
	@touch $@

kernel-patch: state/kernel-patch
state/kernel-patch: state/kernel-fetch
	@mkdir -p ${LOGDIR}
	@echo "Testing upstream patches: see ${LOGDIR}/testpatch.log"
	@${TOOLSDIR}/checkduplicates.py ${PATCH_FILES}
	@echo ${PATCH_FILES}
	@rm -f ${CWD}/test.patch ${FILTERFILE} ${FILTERFILE}-1
	@for patch in ${PATCH_FILES}; do cat $$patch >> ${CWD}/test.patch; done
	@make -i patch-dry-run1
	@echo "Creating patch filter: see ${LOGDIR}/filteredpatch.log"
	@${TOOLSDIR}/genfilter.py ${LOGDIR}/testpatch.log ${FILTERFILE}
	@${TOOLSDIR}/applyfilter.py ${CWD}/test.patch ${CWD}/filtered.patch ${FILTERFILE}
	@echo "Testing for missed, unapplied patches: see ${LOGDIR}/filteredpatch.log"
	@make -i patch-dry-run2
	@${TOOLSDIR}/genfilter.py ${LOGDIR}/filteredpatch.log ${FILTERFILE}-1
	@echo "Creating final patch: see ${LOGDIR}/filteredpatch.log"
	@cat ${FILTERFILE} ${FILTERFILE}-1 > ${FILTERFILE}-2
	@${TOOLSDIR}/applyfilter.py ${CWD}/test.patch ${CWD}/final.patch ${FILTERFILE}-2
	@echo "patching source: see patch.log"
	(cd ${KERNELDIR} && patch -p1 -i ${CWD}/final.patch > ${LOGDIR}/patch.log)
	@mkdir -p state
	@touch $@

patch-dry-run1:
	@rm -f ${LOGDIR}/testpatch.log
	(cd ${KERNELDIR} && patch --dry-run -p1 -i ${CWD}/test.patch > ${LOGDIR}/testpatch.log)

patch-dry-run2:
	@rm -f ${LOGDIR}/filteredpatch.log
	(cd ${KERNELDIR} && patch --dry-run -p1 -i ${CWD}/filtered.patch > ${LOGDIR}/filteredpatch.log)

kernel-clean: 
	(cd ${KERNELDIR} && git reset --hard HEAD)
	@rm -f ${CWD}/state/kernel-patch
	@rm -f ${CWD}/state/kernel-configure
	@rm -f ${CWD}/state/kernel-build
	@rm -f ${FILTERFILE}
	@rm -f ${FILTERFILE}-1
	@rm -f ${FILTERFILE}-2
	@rm -f ${LOGDIR}/*.log
	@rm -f ${CWD}/test.patch
	@rm -f ${CWD}/filtered.patch
	@rm -f ${CWD}/final.patch

kernel-configure: state/kernel-configure
state/kernel-configure: state/kernel-patch
	@cp ${KERNEL_CFG} ${KERNELDIR}/.config
	(cd ${KERNELDIR} && make ${MAKE_FLAGS} oldconfig)
	@mkdir -p state
	@touch $@

kernel-build: state/kernel-build
state/kernel-build: state/kernel-configure
	@echo "Writing to ${LOGDIR}/build.log..."
	(cd ${KERNELDIR} && ${MAKE_KERNEL} ${INSTALLDIR} > ${LOGDIR}/build.log 2>&1)
	@mkdir -p state
	@touch $@

kernel-sync: state/kernel-fetch
	make kernel-clean
	(cd ${KERNELDIR} && git pull)

