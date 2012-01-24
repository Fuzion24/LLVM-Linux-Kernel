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
SRCDIR=${CWD}/src
INSTALLDIR=${TOPDIR}/install
COMMON=${TOPDIR}/common
PATCH_FILES=${COMMON}/common.patch ${COMMON}/fix-warnings.patch \
	${COMMON}/fix-warnings-unused.patch

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

.PHONY: kernel-fetch kernel-patch kernel-configure kernel-build

all: kernel-build

kernel-fetch: state/kernel-fetch
state/kernel-fetch: 
	@mkdir -p ${SRCDIR}
	(cd ${SRCDIR} && git clone ${KERNEL_GIT})
	@mkdir -p state
	@touch $@

kernel-patch: state/kernel-patch
state/kernel-patch: state/kernel-fetch
	(cd ${KERNELDIR} && for patch in ${PATCH_FILES}; do \
		patch -p1 < $$patch;\
		done)
	@mkdir -p state
	@touch $@

kernel-clean: 
	(cd ${KERNELDIR} && git status | grep "modified:" | cut -d":" -f 2 | xargs git checkout)
	@rm -f ${CWD}/state/kernel-patch
	@rm -f ${CWD}/state/kernel-configure

kernel-configure: state/kernel-configure
state/kernel-configure: state/kernel-patch
	@cp ${KERNEL_CFG} ${KERNELDIR}/.config
	(cd ${KERNELDIR} && make ${MAKE_FLAGS} oldconfig)
	@mkdir -p state
	@touch $@

kernel-build: state/kernel-build
state/kernel-build: state/kernel-configure
	@echo "Writing to ${CWD}/log..."
	(cd ${KERNELDIR} && ${MAKE_KERNEL} ${INSTALLDIR} > ${CWD}/log 2>&1)
	@mkdir -p state
	@touch $@

kernel-sync: state/kernel-fetch
	make kernel-clean
	(cd ${KERNELDIR} && git pull)
