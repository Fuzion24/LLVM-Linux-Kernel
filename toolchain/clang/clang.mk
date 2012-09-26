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

LLVMSRCDIR	= ${LLVMTOP}/src
LLVMINSTALLDIR	:= ${LLVMTOP}/install
LLVMSTATE	= ${LLVMTOP}/state
LLVMPATCHES	= ${LLVMTOP}/patches

# The following export is needed by clang_wrap.sh
export LLVMINSTALLDIR

CLANG		= ${LLVMINSTALLDIR}/bin/clang

LLVMDIR		= ${LLVMSRCDIR}/llvm
CLANGDIR	= ${LLVMSRCDIR}/clang
COMPILERRTDIR	= ${LLVMSRCDIR}/llvm/projects/compiler-rt

LLVMBUILDDIR	= ${LLVMTOP}/build/llvm
CLANGBUILDDIR	= ${LLVMTOP}/build/clang
COMPILERRTBUILDDIR	= ${LLVMTOP}/build/compiler-rt

LLVM_TARGETS 		= llvm llvm-fetch llvm-patch llvm-configure llvm-build
CLANG_TARGETS 		= clang clang-fetch clang-patch clang-configure clang-build clang-update-all
COMPILERRT_TARGETS 	= compilerrt-fetch compilerrt-patch
LLVM_TARGETS_APPLIED	= llvm-patch-applied clang-patch-applied
LLVM_CLEAN_TARGETS	= llvm-clean clang-clean
LLVM_SYNC_TARGETS	= llvm-sync clang-sync
LLVM_VERSION_TARGETS	= llvm-version clang-version

TARGETS			+= ${LLVM_TARGETS} ${CLANG_TARGETS} ${COMPILERRT_TARGETS} ${LLVM_SYNC_TARGETS} ${LLVM_CLEAN_TARGETS}
FETCH_TARGETS		+= llvm-fetch compilerrt-fetch clang-fetch
SYNC_TARGETS		+= ${LLVM_SYNC_TARGETS}
CLEAN_TARGETS		+= llvm-clean
MRPROPER_TARGETS	+= llvm-mrproper
RAZE_TARGETS		+= llvm-raze
PATCH_APPLIED_TARGETS	+= ${LLVM_TARGETS_APPLIED}
VERSION_TARGETS		+= ${LLVM_VERSION_TARGETS}
.PHONY:			${LLVM_TARGETS} ${CLANG_TARGETS} ${LLVM_SYNC_TARGETS} ${LLVM_CLEAN_TARGETS} ${LLVM_TARGETS_APPLIED} ${LLVM_VERSION_TARGETS}

LLVM_GIT	= "http://llvm.org/git/llvm.git"
CLANG_GIT	= "http://llvm.org/git/clang.git"
COMPILERRT_GIT	= "http://llvm.org/git/compiler-rt.git"
CMAKE_VERSION	= "2.8.9"
CMAKE_TGZ	= "http://www.cmake.org/files/v2.8/cmake-${CMAKE_VERSION}.tar.gz"

#LLVM_BRANCH	= "release_30"
LLVM_BRANCH	= "master"
CLANG_BRANCH	= "master"
COMPILERRT_BRANCH = "master"
# The buildbot takes quite long to build the debug-version of clang (debug+asserts).
# Introducing this option to switch between debug and optimized. 
#LLVM_OPTIMIZED	= ""
LLVM_OPTIMIZED	= --enable-optimized --enable-assertions

HELP_TARGETS	+= llvm-help
SETTINGS_TARGETS+= llvm-settings

# A locally build version of cmake may be required
PATH		:= ${LLVMINSTALLDIR}/bin:${PATH}

llvm-help:
	@echo
	@echo "* make llvm-[fetch,configure,build,sync,clean]"
	@echo "* make clang-[fetch,configure,build,sync,clean]"

llvm-settings:
	@echo "# LLVM settings"
	@echo "LLVM_GIT		= ${LLVM_GIT}"
	@echo "LLVM_BRANCH		= ${LLVM_BRANCH}"
	@echo "LLVM_OPTIMIZED		= ${LLVM_OPTIMIZED}"
	@echo "# Clang settings"
	@echo "CLANG_GIT		= ${CLANG_GIT}"
	@echo "CLANG_BRANCH		= ${CLANG_BRANCH}"
	@echo "COMPILERRT_GIT		= ${COMPILERRT_GIT}"
	@echo "COMPILERRT_BRANCH	= ${COMPILERRT_BRANCH}"

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
${LLVMSTATE}/llvm-patch: ${LLVMSTATE}/llvm-fetch
	@$(call banner, "Patching LLVM...")
	@ln -sf ${LLVMPATCHES}/llvm ${LLVMDIR}/patches
	@$(call patch,${LLVMDIR})
	$(call state,$@,llvm-configure)

clang-patch: ${LLVMSTATE}/clang-patch
${LLVMSTATE}/clang-patch: ${LLVMSTATE}/clang-fetch
	@$(call banner, "Patching Clang...")
	@ln -sf ${LLVMPATCHES}/clang ${CLANGDIR}/patches
	@$(call patch,${CLANGDIR})
	$(call state,$@,clang-configure)

compilerrt-patch: ${LLVMSTATE}/compilerrt-patch
${LLVMSTATE}/compilerrt-patch: ${LLVMSTATE}/compilerrt-fetch
	@$(call banner, "Patching Compiler-rt...")
	@ln -sf ${LLVMPATCHES}/compiler-rt ${COMPILERRTDIR}/patches
	@$(call patch,${COMPILERRTDIR})
	$(call state,$@)

${LLVM_TARGETS_APPLIED}: %-patch-applied:
	@$(call banner,"Patches applied for $*")
	@$(call applied,${LLVMSRCDIR}/$*)

llvm-configure: ${LLVMSTATE}/llvm-configure
${LLVMSTATE}/llvm-configure: ${LLVMSTATE}/llvm-patch
	@$(call banner, "Configure LLVM...")
	@mkdir -p ${LLVMBUILDDIR}
	(cd ${LLVMBUILDDIR} && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${LLVMINSTALLDIR} ${LLVMDIR})
	$(call state,$@,llvm-build)

clang-configure: ${LLVMSTATE}/clang-configure
${LLVMSTATE}/clang-configure: ${LLVMSTATE}/clang-patch
	@$(call banner, "Configure Clang...")
	@mkdir -p ${CLANGBUILDDIR}
	(cd ${CLANGBUILDDIR} && cmake -DCMAKE_BUILD_TYPE=Release  -DCMAKE_INSTALL_PREFIX=${LLVMINSTALLDIR} -DCLANG_PATH_TO_LLVM_SOURCE=${LLVMDIR}   -DCLANG_PATH_TO_LLVM_BUILD=${LLVMBUILDDIR}   ${CLANGDIR} )
	$(call state,$@,clang-build)

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
	cp -a ${CLANGDIR}/tools/scan-build/* ${LLVMINSTALLDIR}/bin
	cp -a ${CLANGDIR}/tools/scan-view/* ${LLVMINSTALLDIR}/bin
	$(call state,$@)

llvm-reset: ${LLVMSTATE}/clang-fetch ${LLVMSTATE}/compilerrt-fetch
	@$(call banner,Removing LLVM patches...)
	@$(call unpatch,${LLVMDIR})
#	(cd ${LLVMDIR} && git reset --hard HEAD)
#	(cd ${LLVMDIR}/projects/compiler-rt && git reset --hard HEAD)
	@rm -f $(addprefix ${LLVMSTATE}/,llvm-patch llvm-configure llvm-build)

llvm-clean-noreset:
	@$(call banner,Cleaning LLVM...)
	@rm -rf ${LLVMINSTALLDIR} ${LLVMBUILDDIR}
	@rm -f $(addprefix ${LLVMSTATE}/,llvm-configure llvm-build)

llvm-clean: llvm-reset llvm-clean-noreset clang-clean

llvm-mrproper: llvm-clean clang-mrproper
	(cd ${LLVMDIR} && git clean -f)

llvm-raze: llvm-clean-noreset clang-raze
	@$(call banner,Razing LLVM...)
	@rm -rf ${LLVMDIR} ${LLVMSTATE}/llvm-* ${LLVMSTATE}/compilerrt-*

clang-reset: ${LLVMSTATE}/clang-fetch
	@$(call banner,Removing Clang patches...)
	@$(call unpatch,${CLANGDIR})
#	(cd ${CLANGDIR} && git reset --hard HEAD)
	@rm -f $(addprefix ${LLVMSTATE}/,clang-patch clang-configure clang-build)

clang-clean-noreset: llvm-clean-noreset
	@$(call banner,Cleaning Clang...)
	@rm -rf ${LLVMINSTALLDIR}/clang ${CLANGBUILDDIR}

clang-clean: clang-reset clang-clean-noreset

clang-mrproper: clang-clean
	(cd ${CLANGDIR} && git clean -f)

clang-raze: clang-clean-noreset
	@$(call banner,Razing Clang...)
	@rm -rf ${CLANGDIR} ${LLVMSTATE}/clang-*

llvm-sync: llvm-clean
	@$(call banner,Updating LLVM...)
	(cd ${LLVMDIR} && git checkout ${LLVM_BRANCH} && git pull)
	(cd ${LLVMDIR}/projects/compiler-rt && git checkout ${COMPILERRT_BRANCH} && git pull)

clang-sync: clang-clean
	@$(call banner,Updating Clang...)
	(cd ${CLANGDIR} && git checkout ${CLANG_BRANCH} && git pull)

llvm-version:
	@(cd ${LLVMDIR}/$* && echo "`${LLVMINSTALLDIR}/bin/llc --version | grep version | xargs echo` commit `git rev-parse HEAD`")
clang-version:
	@(cd ${CLANGDIR}/$* && echo "`${CLANG} --version | grep version | xargs echo` commit `git rev-parse HEAD`")

clang-update-all: llvm-sync clang-sync llvm-build clang-build

# cmake version 2.8.8 or newer is required to build compiler-rt
cmake-build: ${LLVMSTATE}/cmake-build
${LLVMSTATE}/cmake-build:
	@(cd ${LLVMSRCDIR} && [ -e cmake-${CMAKE_VERSION}.tar.gz ] || wget ${CMAKE_TGZ})
	@(cd ${LLVMSRCDIR} && tar -xvzf cmake-${CMAKE_VERSION}.tar.gz)
	@(mkdir -p ${LLVMINSTALLDIR})
	@(cd ${LLVMSRCDIR}/cmake-${CMAKE_VERSION} && ./configure --prefix=${LLVMINSTALLDIR} && make install)
	$(call state,$@)

cmake-clean:
	@rm -f ${LLVMINSTALLDIR}/bin/cmake
	@rm -f ${LLVMSRCDIR}/cmake-*.tar.gz
	@rm -rf ${LLVMSRCDIR}/cmake-*
	@rm -f ${LLVMSTATE}/cmake-build
