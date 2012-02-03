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
LLVMINSTALLDIR=${LLVMTOP}/install
LLVMBUILDDIR=${LLVMTOP}/build/llvm
LLVMSTATE=${LLVMTOP}/state

LLVMDEVSRC=`basename ${LLVMDEVBUILDDIR}`

DEVLLVMINSTALLDIR=${LLVMTOP}/install-dev
LLVMDEVBUILDDIR=${LLVMTOP}/build/llvm-dev
LLVMDEVDIR=${LLVMSRCDIR}/${LLVMDEVSRC}
CLANGDEVDIR=${LLVMDEVDIR}/tools/clang

.PHONY: clang-fetch clang-configure clang-build \
	clangdev-fetch clangdev-configure clangdev-build

LLVM_GIT="http://llvm.org/git/llvm.git"
CLANG_GIT="http://llvm.org/git/clang.git"
LLVM_BRANCH="release_30"
LLVM_MASTER="master"

clang-fetch: ${LLVMSTATE}/clang-fetch
${LLVMSTATE}/clang-fetch:
	@mkdir -p ${LLVMSRCDIR}
	(cd ${LLVMSRCDIR} && git clone ${LLVM_GIT} -b ${LLVM_BRANCH})
	(cd ${LLVMSRCDIR}/llvm/tools && git clone ${CLANG_GIT} -b ${LLVM_BRANCH})
	@mkdir -p ${LLVMSTATE}
	@touch $@

clang-configure: ${LLVMSTATE}/clang-configure
${LLVMSTATE}/clang-configure: ${LLVMSTATE}/clang-fetch
	@mkdir -p ${LLVMBUILDDIR}
	(cd ${LLVMBUILDDIR} && CC=gcc CXX=g++ ${LLVMSRCDIR}/llvm/configure \
		--enable-targets=arm,hexagon,mips --disable-shared \
		--enable-languages=c,c++ --enable-bindings=none \
		--prefix=${LLVMINSTALLDIR} target_alias=arm-linux)
	@mkdir -p ${LLVMSTATE}
	@touch $@

clang-build:  ${LLVMSTATE}/clang-build
${LLVMSTATE}/clang-build: ${LLVMSTATE}/clang-configure
	@mkdir -p ${LLVMINSTALLDIR}
	(cd ${LLVMBUILDDIR} && make -j2 install)
	@mkdir -p ${LLVMSTATE}
	@touch $@

clangdev-fetch: ${LLVMSTATE}/clang-fetch ${LLVMSTATE}/clangdev-fetch 
${LLVMSTATE}/clangdev-fetch:
	@mkdir -p ${LLVMSRCDIR}
	(cd ${LLVMSRCDIR} && git clone ${LLVMSRCDIR}/llvm -b ${LLVM_MASTER} ${LLVMDEVSRC})
	(cd ${LLVMDEVDIR}/tools && git clone ${LLVMSRCDIR}/llvm/tools/clang -b ${LLVM_MASTER})
	@mkdir -p ${LLVMSTATE}
	@touch $@

clangdev-configure: ${LLVMSTATE}/clangdev-configure
${LLVMSTATE}/clangdev-configure: ${LLVMSTATE}/clangdev-fetch
	@mkdir -p ${LLVMDEVBUILDDIR}
	(cd ${LLVMDEVBUILDDIR} && CC=gcc CXX=g++ ${LLVMDEVDIR}/configure \
		--enable-targets=arm,hexagon,mips --disable-shared \
		--enable-languages=c,c++ --enable-bindings=none \
		--prefix=${DEVLLVMINSTALLDIR})
	@mkdir -p ${LLVMSTATE}
	@touch $@

clangdev-build:  ${LLVMSTATE}/clangdev-build
${LLVMSTATE}/clangdev-build: ${LLVMSTATE}/clangdev-configure
	@mkdir -p ${DEVLLVMINSTALLDIR}
	(cd ${LLVMDEVBUILDDIR} && make -j2 install)
	@mkdir -p ${LLVMSTATE}
	@touch $@

clang-clean:
	@rm -rf ${LLVMINSTALLDIR} ${LLVMBUILDDIR}
	@rm -f ${LLVMSTATE}/clang-configure ${LLVMSTATE}/clang-build

clang-sync:
	(cd ${LLVMSRCDIR}/llvm && git checkout ${LLVM_BRANCH} && git pull)
	(cd ${LLVMSRCDIR}/llvm/tools/clang && git checkout ${LLVM_BRANCH} && git pull)
	(test -d ${LLVMDEVDIR} && cd ${LLVMDEVDIR} && git checkout ${LLVM_MASTER} && git pull)
	(test -d ${CLANGDEVDIR} && cd ${CLANGDEVDIR} && git checkout ${LLVM_MASTER} && git pull)
