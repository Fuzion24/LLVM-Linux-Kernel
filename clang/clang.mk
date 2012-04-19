##############################################################################
# Copyright (c) 2012 Mark Charlebois
#               2012 Jan-Simon Möller
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

# NOTE: TOPDIR must be defined by the calling Makefile

LLVMTOP=${TOPDIR}/clang

LLVMSRCDIR=${LLVMTOP}/src
LLVMDIR=${LLVMSRCDIR}/llvm
LLVMINSTALLDIR=${LLVMTOP}/install
LLVMBUILDDIR=${LLVMTOP}/build/llvm
LLVMSTATE=${LLVMTOP}/state
SYNC_TARGETS=clang-sync

JOBS:=${shell getconf _NPROCESSORS_ONLN}
ifeq "${JOBS}" ""
JOBS:=2
endif

TARGETS+= clang-fetch clang-configure clang-build clang-clean clang-sync clang-update-all

.PHONY: clang-fetch clang-configure clang-build clang-clean clang-sync clang-update-all

LLVM_GIT="http://llvm.org/git/llvm.git"
CLANG_GIT="http://llvm.org/git/clang.git"
#LLVM_BRANCH="release_30"
LLVM_BRANCH="master"

clang-fetch: ${LLVMSTATE}/clang-fetch ${LLVMSTATE}/clang-fetch 
${LLVMSTATE}/clang-fetch:
	@mkdir -p ${LLVMSRCDIR}
	(cd ${LLVMSRCDIR} && git clone ${LLVM_GIT} -b ${LLVM_BRANCH} ${LLVMSRC})
	(cd ${LLVMDIR}/tools && git clone ${CLANG_GIT} -b ${LLVM_BRANCH})
	@mkdir -p ${LLVMSTATE}
	@touch $@

clang-patch: ${LLVMSTATE}/clang-patch
${LLVMSTATE}/clang-patch: ${LLVMSTATE}/clang-fetch
	(cd ${LLVMDIR} && patch -p1 -i ${LLVMTOP}/inline-64-bit-asm.patch)
	(cd ${LLVMDIR}/tools/clang && patch -p1 -i ${LLVMTOP}/64-bit-ABI.patch)
	@mkdir -p ${LLVMSTATE}
	@touch $@

clang-configure: ${LLVMSTATE}/clang-configure
${LLVMSTATE}/clang-configure: ${LLVMSTATE}/clang-patch
	@mkdir -p ${LLVMBUILDDIR}
	(cd ${LLVMBUILDDIR} && CC=gcc CXX=g++ ${LLVMDIR}/configure \
		--enable-targets=arm,mips,x86_64 --disable-shared \
		--enable-languages=c,c++ --enable-bindings=none \
		--prefix=${LLVMINSTALLDIR})
	@mkdir -p ${LLVMSTATE}
	@touch $@

clang-build:  ${LLVMSTATE}/clang-build
${LLVMSTATE}/clang-build: ${LLVMSTATE}/clang-configure
	@mkdir -p ${LLVMINSTALLDIR}
	(cd ${LLVMBUILDDIR} && make -j${JOBS} install)
	ln -s ${LLVMSRCDIR}/llvm/tools/clang/tools/scan-build/scan-build ${LLVMINSTALLDIR}/bin/scan-build
	ln -s ${LLVMSRCDIR}/llvm/tools/clang/tools/scan-view/scan-view ${LLVMINSTALLDIR}/bin/scan-view
	@mkdir -p ${LLVMSTATE}
	@touch $@

clang-clean:
	(cd ${LLVMDIR}/tools/clang && git reset --hard HEAD)
	(cd ${LLVMDIR} && git reset --hard HEAD)
	@rm -rf ${LLVMINSTALLDIR} ${LLVMBUILDDIR}
	@rm -f ${LLVMSTATE}/clang-configure ${LLVMSTATE}/clang-patch ${LLVMSTATE}/clang-build

clang-sync: ${LLVMSTATE}/clang-fetch clang-clean
	(cd ${LLVMSRCDIR}/llvm && git checkout ${LLVM_BRANCH} && git pull)
	(cd ${LLVMSRCDIR}/llvm/tools/clang && git checkout ${LLVM_BRANCH} && git pull)

clang-update-all: ${LLVMSTATE}/clang-fetch clang-clean clang-sync clang-build
