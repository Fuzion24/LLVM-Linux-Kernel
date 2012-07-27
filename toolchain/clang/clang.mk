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

LLVM_TARGETS 		= llvm llvm-fetch llvm-patch llvm-configure llvm-build
CLANG_TARGETS 		= clang clang-fetch clang-patch clang-configure clang-build clang-update-all
LLVM_TARGETS_APPLIED	= llvm-patch-applied clang-patch-applied
LLVM_CLEAN_TARGETS	= llvm-clean clang-clean
LLVM_SYNC_TARGETS	= llvm-sync clang-sync
LLVM_VERSION_TARGETS	= llvm-version clang-version

TARGETS			+= ${LLVM_TARGETS} ${CLANG_TARGETS} ${LLVM_SYNC_TARGETS} ${LLVM_CLEAN_TARGETS}
SYNC_TARGETS		+= ${LLVM_SYNC_TARGETS}
CLEAN_TARGETS		+= ${LLVM_CLEAN_TARGETS}
PATCH_APPLIED_TARGETS	+= ${LLVM_TARGETS_APPLIED}
VERSION_TARGETS		+= ${LLVM_VERSION_TARGETS}
.PHONY:			${LLVM_TARGETS} ${CLANG_TARGETS} ${LLVM_SYNC_TARGETS} ${LLVM_CLEAN_TARGETS} ${LLVM_TARGETS_APPLIED} ${LLVM_VERSION_TARGETS}

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
	@$(call banner, "Fetching LLVM...")
	@mkdir -p $(dir ${LLVMDIR})
	[ -d ${LLVMDIR}/.git ] || (rm -rf ${LLVMDIR} && git clone ${LLVM_GIT} -b ${LLVM_BRANCH} ${LLVMDIR})
	$(call state,$@,llvm-patch)

compilerrt-fetch: ${LLVMSTATE}/compilerrt-fetch
${LLVMSTATE}/compilerrt-fetch: ${LLVMSTATE}/llvm-fetch
	@$(call banner, "Fetching Compilerrt...")
	( [ -d ${LLVMSRCDIR}/llvm/projects/compiler-rt/.git ] || (cd ${LLVMDIR}/projects && git clone ${COMPILERRT_GIT} -b ${COMPILERRT_BRANCH}))
	$(call state,$@)

clang-fetch: ${LLVMSTATE}/clang-fetch
${LLVMSTATE}/clang-fetch:
	@$(call banner, "Fetching Clang...")
	@mkdir -p ${LLVMSRCDIR}
	( [ -d ${LLVMSRCDIR}/clang/.git ] || (cd ${LLVMSRCDIR} && git clone ${CLANG_GIT} -b ${CLANG_BRANCH}))
	$(call state,$@,clang-patch)

llvm-patch: ${LLVMSTATE}/llvm-patch
${LLVMSTATE}/llvm-patch: ${LLVMSTATE}/llvm-fetch ${LLVMSTATE}/compilerrt-fetch
	@$(call banner, "Patching LLVM...")
	@ln -sf ${LLVMPATCHES}/llvm ${LLVMDIR}/patches
	(cd ${LLVMDIR} && quilt push -a)
	$(call state,$@,llvm-configure)

clang-patch: ${LLVMSTATE}/clang-patch
${LLVMSTATE}/clang-patch: ${LLVMSTATE}/clang-fetch
	@$(call banner, "Patching Clang...")
	@ln -sf ${LLVMPATCHES}/clang ${CLANGDIR}/patches
	(cd ${CLANGDIR} && quilt push -a)
	$(call state,$@,clang-configure)

${LLVM_TARGETS_APPLIED}: %-patch-applied:
	@$(call banner,"Patches applied for $*")
	@(cd ${LLVMSRCDIR}/$* && quilt applied || echo "No patches applied" )

llvm-configure: ${LLVMSTATE}/llvm-configure
${LLVMSTATE}/llvm-configure: ${LLVMSTATE}/llvm-patch
	@$(call banner, "Configure LLVM...")
	@mkdir -p ${LLVMBUILDDIR}
	(cd ${LLVMBUILDDIR} && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${LLVMINSTALLDIR} ${LLVMDIR})
	$(call state,$@,llvm-build)

#	(cd ${LLVMBUILDDIR} && CC=gcc CXX=g++ ${LLVMDIR}/configure \
#		--enable-targets=arm,mips,x86_64 --disable-shared \
#		--enable-languages=c,c++ --enable-bindings=none \
#		${LLVM_OPTIMIZED} --prefix=${LLVMINSTALLDIR} ) 


clang-configure: ${LLVMSTATE}/clang-configure
${LLVMSTATE}/clang-configure: ${LLVMSTATE}/clang-patch
	@$(call banner, "Configure Clang...")
	@mkdir -p ${CLANGBUILDDIR}
	(cd ${CLANGBUILDDIR} && cmake -DCMAKE_BUILD_TYPE=Release  -DCMAKE_INSTALL_PREFIX=${LLVMINSTALLDIR} -DCLANG_PATH_TO_LLVM_SOURCE=${LLVMDIR}   -DCLANG_PATH_TO_LLVM_BUILD=${LLVMBUILDDIR}   ${CLANGDIR} )
	$(call state,$@,clang-build)

#	(cd ${CLANGBUILDDIR} && CC=gcc CXX=g++ ${LLVMDIR}/configure \
#		--enable-targets=arm,mips,x86_64 --disable-shared \
#		--enable-languages=c,c++ --enable-bindings=none \
#		${LLVM_OPTIMIZED} --prefix=${LLVMINSTALLDIR} ) 

llvm llvm-build: ${LLVMSTATE}/llvm-build
${LLVMSTATE}/llvm-build: ${LLVMSTATE}/llvm-configure
	@$(call banner, "Building LLVM...")
	@mkdir -p ${LLVMINSTALLDIR} ${LLVMBUILDDIR}
	(cd ${LLVMBUILDDIR} && make -j${JOBS} install)
	$(call state,$@,clang-build)

clang clang-build:  ${LLVMSTATE}/clang-build
${LLVMSTATE}/clang-build: ${LLVMSTATE}/llvm-build ${LLVMSTATE}/clang-configure
	@$(call banner, "Building Clang...")
	@mkdir -p ${LLVMINSTALLDIR} ${CLANGBUILDDIR}
	(cd ${CLANGBUILDDIR} && make -j${JOBS} install)
	cp -a ${CLANGDIR}/tools/scan-{build,view}/* ${LLVMINSTALLDIR}/bin
	$(call state,$@)

llvm-clean: ${LLVMSTATE}/llvm-fetch ${LLVMSTATE}/compilerrt-fetch clang-clean
	-(cd ${LLVMDIR} && [ ! -e patches ] || quilt pop -af)
	(cd ${LLVMDIR} && git reset --hard HEAD)
	(cd ${LLVMSRCDIR}/llvm/projects/compiler-rt && git reset --hard HEAD)
	@rm -rf ${LLVMINSTALLDIR} ${LLVMBUILDDIR}
	@rm -f $(addprefix ${LLVMSTATE}/,llvm-patch llvm-configure llvm-build)

clang-clean: ${LLVMSTATE}/clang-fetch 
	-(cd ${CLANGDIR} && [ ! -e patches ] || quilt pop -af)
	(cd ${CLANGDIR} && git reset --hard HEAD)
	@rm -rf ${LLVMINSTALLDIR} ${CLANGBUILDDIR}
	@rm -f $(addprefix ${LLVMSTATE}/,clang-patch clang-configure clang-build llvm-build)

llvm-clean-noreset:
	@rm -rf ${LLVMINSTALLDIR} ${LLVMBUILDDIR}
	@rm -f $(addprefix ${LLVMSTATE}/,llvm-configure llvm-build)

clang-clean-noreset:
	@rm -rf ${LLVMINSTALLDIR} ${LLVMBUILDDIR}
	@rm -f $(addprefix ${LLVMSTATE}/,clang-configure clang-build)

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

llvm-version:
	@(cd ${LLVMDIR}/$* && echo "`${LLVMINSTALLDIR}/bin/llc --version | grep version | xargs echo` commit `git rev-parse HEAD`")
clang-version:
	@(cd ${CLANGDIR}/$* && echo "`${CLANG} --version | grep version | xargs echo` commit `git rev-parse HEAD`")

clang-update-all: llvm-sync clang-sync llvm-build clang-build
