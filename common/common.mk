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

kernel-test-patch: state/kernel-fetch
	@echo "patching source: see patch.log"
	@rm -f ${CWD}/testpatch.log
	(cd ${KERNELDIR} && for patch in ${PATCH_FILES}; do \
		patch -p1 < $$patch >> ${CWD}/testpatch.log;\
		done)

kernel-test-filter: ${FILTERFILE}
	@echo "Testing filtered patch: see ${FILTERFILE}"
	@rm -f ${CWD}/testfilter.log
	@rm -f ${CWD}/patch.unfiltered-test
	@rm -f ${CWD}/patch.filtered-test
	@for patch in ${PATCH_FILES}; do cat $$patch >> ${CWD}/patch.unfiltered-test; done
	@${TOOLSDIR}/tidy.py ${CWD}/patch.unfiltered-test
	@${TOOLSDIR}/applyfilter.py ${CWD}/patch.unfiltered-test ${CWD}/patch.filtered-test ${FILTERFILE}
	(cd ${KERNELDIR} && patch -p1 < ${CWD}/patch.filtered-test >> ${CWD}/testfilter.log)

kernel-patch: state/kernel-patch
state/kernel-patch: ${FILTERFILE}
	@echo "Generating filtered patch: see ${FILTERFILE}"
	@rm -f ${CWD}/patch.log
	@rm -f ${CWD}/patch.unfiltered
	@rm -f ${CWD}/patch.filtered
	@for patch in ${PATCH_FILES}; do cat $$patch >> ${CWD}/patch.unfiltered; done
	@${TOOLSDIR}/tidy.py ${CWD}/patch.unfiltered
	@${TOOLSDIR}/applyfilter.py ${CWD}/patch.unfiltered ${CWD}/patch.filtered ${FILTERFILE}
	(cd ${KERNELDIR} && patch -p1 < ${CWD}/patch.filtered > ${CWD}/patch.log)
	@mkdir -p state
	@touch $@

kernel-prepare: 
	
	(cd ${KERNELDIR} && git status | grep "modified:" | cut -d":" -f 2 | xargs git checkout)
	@git reset --hard HEAD
	@rm -f ${CWD}/state/kernel-patch
	@rm -f ${CWD}/state/kernel-configure
	@rm -f ${CWD}/state/kernel-build
	@find ${KERNELDIR} -name "*.rej" | xargs rm -f

kernel-clean: 
	make kernel-prepare
	@rm -f ${FILTERFILE}
	@rm -f ${FILTERFILE}-1
	@rm -f ${CWD}/testpatch.log
	@rm -f ${CWD}/testfilter.log
	@rm -f ${CWD}/patch.unfiltered-test
	@rm -f ${CWD}/patch.filtered-test
	@rm -f ${CWD}/patch.filtered
	@rm -f ${CWD}/patch.unfiltered
	@rm -f ${CWD}/patch.log
	@rm -f ${CWD}/build.log

kernel-configure: state/kernel-configure
state/kernel-configure: state/kernel-patch
	@cp ${KERNEL_CFG} ${KERNELDIR}/.config
	(cd ${KERNELDIR} && make ${MAKE_FLAGS} oldconfig)
	@mkdir -p state
	@touch $@

kernel-build: state/kernel-build
state/kernel-build: state/kernel-configure
	@echo "Writing to ${CWD}/build.log..."
	(cd ${KERNELDIR} && ${MAKE_KERNEL} ${INSTALLDIR} > ${CWD}/build.log 2>&1)
	@mkdir -p state
	@touch $@

kernel-sync: state/kernel-fetch
	make kernel-clean
	(cd ${KERNELDIR} && git pull)

gen-patch: ${FILTERFILE}
${FILTERFILE}: state/kernel-fetch
	make kernel-prepare
	make -i kernel-test-patch
	@${TOOLSDIR}/genfilter.py ${CWD}/testpatch.log ${KERNELDIR} > ${FILTERFILE}
	make kernel-prepare
	make -i kernel-test-filter
	@${TOOLSDIR}/genfilter.py ${CWD}/testfilter.log ${KERNELDIR} > ${FILTERFILE}-1
	@cat ${FILTERFILE}-1 >> ${FILTERFILE}
	make kernel-prepare
