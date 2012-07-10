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

# Assumes has been included from ../toolchain.mk

export LLVMINSTALLDIR

LLVMSRCDIR	= ${LLVMTOP}/src
LLVMINSTALLDIR	= ${LLVMTOP}/install
LLVMSTATE	= ${LLVMTOP}/state
LLVMPATCHES	= ${LLVMTOP}/patches

CLANG		= ${LLVMINSTALLDIR}/bin/clang

LLVMDIR		= ${LLVMSRCDIR}/llvm
CLANGDIR	= ${LLVMSRCDIR}/clang

LLVMBUILDDIR	= ${LLVMTOP}/build/llvm
CLANGBUILDDIR	= ${LLVMTOP}/build/clang

SYNC_TARGETS	= llvm-sync clang-sync

TARGETS		+= llvm-fetch clang-fetch llvm-configure clang-configure llvm-build clang-build llvm-clean clang-clean llvm-sync clang-sync clang-update-all

.PHONY: llvm-fetch clang-fetch llvm-configure clang-configure llvm-build clang-build llvm-clean clang-clean clang-sync clang-update-all

LLVM_GIT	= "http://llvm.org/git/llvm.git"
CLANG_GIT	= "http://llvm.org/git/clang.git"
COMPILERRT_GIT	= "http://llvm.org/git/compiler-rt.git"

#LLVM_BRANCH	= "release_30"
LLVM_BRANCH	= "master"
CLANG_BRANCH	= "master"
COMPILERRT_BRANCH = "master"
# The buildbot takes quite long to build the debug-version of clang (debug+asserts).
# Introducing this option to switch between debug and optimized. 
#LLVM_OPTIMIZED	= ""
LLVM_OPTIMIZED	= --enable-optimized --enable-assertions

llvm-fetch: ${LLVMSTATE}/llvm-fetch
${LLVMSTATE}/llvm-fetch:
	@mkdir -p ${LLVMSRCDIR}
	@rm -f ${LLVMSTATE}/clang-fetch
	@rm -rf ${LLVMSRCDIR}/clang
	( [ -d ${LLVMSRCDIR}/llvm/.git ] || (rm -rf ${LLVMDIR} && cd ${LLVMSRCDIR} && git clone ${LLVM_GIT} -b ${LLVM_BRANCH}))
	$(call state, $@)

clang-fetch: ${LLVMSTATE}/clang-fetch
${LLVMSTATE}/clang-fetch:
	@mkdir -p ${LLVMSRCDIR}
	( [ -d ${LLVMSRCDIR}/clang/.git ] || (cd ${LLVMSRCDIR} && git clone ${CLANG_GIT} -b ${CLANG_BRANCH}))
	$(call state, $@)

compilerrt-fetch: ${LLVMSTATE}/compilerrt-fetch
${LLVMSTATE}/compilerrt-fetch: ${LLVMSTATE}/llvm-fetch
	( [ -d ${LLVMSRCDIR}/llvm/projects/compiler-rt/.git ] || (cd ${LLVMDIR}/projects && git clone ${COMPILERRT_GIT} -b ${COMPILERRT_BRANCH}))
	$(call state, $@)

llvm-patch: ${LLVMSTATE}/llvm-patch
${LLVMSTATE}/llvm-patch: ${LLVMSTATE}/llvm-fetch ${LLVMSTATE}/compilerrt-fetch
	(cd ${LLVMDIR} && patch -p1 -i ${LLVMPATCHES}/inline-64-bit-asm.patch)
	$(call state, $@)

clang-patch: ${LLVMSTATE}/clang-patch
${LLVMSTATE}/clang-patch: ${LLVMSTATE}/clang-fetch
	(cd ${CLANGDIR} && patch -p1 -i ${LLVMPATCHES}/64-bit-ABI.patch)
	(cd ${CLANGDIR} && patch -p1 -i ${LLVMPATCHES}/pending.patch)
	$(call state, $@)

llvm-configure: ${LLVMSTATE}/llvm-configure
${LLVMSTATE}/llvm-configure: ${LLVMSTATE}/llvm-patch
	@mkdir -p ${LLVMBUILDDIR}
	(cd ${LLVMBUILDDIR} && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${LLVMINSTALLDIR} ${LLVMDIR})
	$(call state, $@)

#	(cd ${LLVMBUILDDIR} && CC=gcc CXX=g++ ${LLVMDIR}/configure \
#		--enable-targets=arm,mips,x86_64 --disable-shared \
#		--enable-languages=c,c++ --enable-bindings=none \
#		${LLVM_OPTIMIZED} --prefix=${LLVMINSTALLDIR} ) 


clang-configure: ${LLVMSTATE}/clang-configure
${LLVMSTATE}/clang-configure: ${LLVMSTATE}/clang-patch
	@mkdir -p ${CLANGBUILDDIR}
	(cd ${CLANGBUILDDIR} && cmake -DCMAKE_BUILD_TYPE=Release  -DCMAKE_INSTALL_PREFIX=${LLVMINSTALLDIR} -DCLANG_PATH_TO_LLVM_SOURCE=${LLVMDIR}   -DCLANG_PATH_TO_LLVM_BUILD=${LLVMBUILDDIR}   ${CLANGDIR} )
	$(call state, $@)

#	(cd ${CLANGBUILDDIR} && CC=gcc CXX=g++ ${LLVMDIR}/configure \
#		--enable-targets=arm,mips,x86_64 --disable-shared \
#		--enable-languages=c,c++ --enable-bindings=none \
#		${LLVM_OPTIMIZED} --prefix=${LLVMINSTALLDIR} ) 

llvm-build:  ${LLVMSTATE}/llvm-build
${LLVMSTATE}/llvm-build: ${LLVMSTATE}/llvm-configure
	@mkdir -p ${LLVMINSTALLDIR}
	@mkdir -p ${LLVMBUILDDIR}
	(cd ${LLVMBUILDDIR} && make -j${JOBS} install)
	cp -a ${LLVMSRCDIR}/clang/tools/scan-view/* ${LLVMINSTALLDIR}/bin
	cp -a ${LLVMSRCDIR}/clang/tools/scan-build/* ${LLVMINSTALLDIR}/bin
	$(call state, $@)

clang-build:  ${LLVMSTATE}/clang-build
${LLVMSTATE}/clang-build: ${LLVMSTATE}/llvm-build ${LLVMSTATE}/clang-configure
	@mkdir -p ${LLVMINSTALLDIR}
	@mkdir -p ${CLANGBUILDDIR}
	(cd ${CLANGBUILDDIR} && make -j${JOBS} install)
	$(call state, $@)

llvm-clean: ${LLVMSTATE}/llvm-fetch ${LLVMSTATE}/compilerrt-fetch clang-clean
	(cd ${LLVMDIR} && git reset --hard HEAD)
	(cd ${LLVMSRCDIR}/llvm/projects/compiler-rt && git reset --hard HEAD)
	@rm -rf ${LLVMINSTALLDIR} ${LLVMBUILDDIR}
	@rm -f ${LLVMSTATE}/llvm-configure ${LLVMSTATE}/llvm-patch ${LLVMSTATE}/llvm-build

clang-clean: ${LLVMSTATE}/clang-fetch kernel-clean
	(cd ${CLANGDIR} && git reset --hard HEAD)
	@rm -rf ${LLVMINSTALLDIR} ${CLANGBUILDDIR}
	@rm -f ${LLVMSTATE}/clang-configure ${LLVMSTATE}/clang-patch ${LLVMSTATE}/clang-build ${LLVMSTATE}/llvm-build

llvm-clean-noreset:
	@rm -rf ${LLVMINSTALLDIR} ${LLVMBUILDDIR}
	@rm -f ${LLVMSTATE}/llvm-configure ${LLVMSTATE}/llvm-build

clang-clean-noreset:
	@rm -rf ${LLVMINSTALLDIR} ${LLVMBUILDDIR}
	@rm -f ${LLVMSTATE}/clang-configure ${LLVMSTATE}/clang-build

llvm-reset: ${LLVMSTATE}/clang-fetch ${LLVMSTATE}/compilerrt-fetch
	(cd ${LLVMDIR} && git reset --hard HEAD)
	(cd ${LLVMDIR}/projects/compiler-rt && git reset --hard HEAD)

clang-reset: ${LLVMSTATE}/clang-fetch ${LLVMSTATE}/compilerrt-fetch
	(cd ${CLANGDIR} && git reset --hard HEAD)


llvm-sync: llvm-clean
	(cd ${LLVMDIR} && git checkout ${LLVM_BRANCH} && git pull)
	(cd ${LLVMDIR}/projects/compiler-rt && git checkout ${COMPILERRT_BRANCH} && git pull)

clang-sync: clang-clean
	(cd ${CLANGDIR} && git checkout ${CLANG_BRANCH} && git pull)

clang-update-all: llvm-sync clang-sync llvm-build clang-build
