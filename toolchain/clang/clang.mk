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
COMPILERRTDIR	= ${LLVMDIR}/projects/compiler-rt

LLVMBUILDDIR	= ${LLVMTOP}/build/llvm
CLANGBUILDDIR	= ${LLVMTOP}/build/clang

LLVM_TARGETS 		= llvm llvm-[fetch,patch,configure,build,clean,sync]
CLANG_TARGETS 		= clang clang-[fetch,patch,configure,build,sync] clang-update-all
COMPILERRT_TARGETS 	= compilerrt-fetch 
LLVM_TARGETS_APPLIED	= llvm-patch-applied clang-patch-applied
LLVM_VERSION_TARGETS	= llvm-version clang-version

TARGETS_TOOLCHAIN	+= ${LLVM_TARGETS} ${CLANG_TARGETS} ${COMPILERRT_TARGETS}
FETCH_TARGETS		+= llvm-fetch compilerrt-fetch clang-fetch
SYNC_TARGETS		+= llvm-sync clang-sync
CLEAN_TARGETS		+= llvm-clean
MRPROPER_TARGETS	+= llvm-mrproper
RAZE_TARGETS		+= llvm-raze
PATCH_APPLIED_TARGETS	+= ${LLVM_TARGETS_APPLIED}
VERSION_TARGETS		+= ${LLVM_VERSION_TARGETS}
.PHONY:			${LLVM_TARGETS} ${CLANG_TARGETS} ${LLVM_TARGETS_APPLIED} ${LLVM_VERSION_TARGETS}

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

HELP_TARGETS	+= llvm-help
SETTINGS_TARGETS+= llvm-settings

# Add clang to the path
PATH		:= ${LLVMINSTALLDIR}/bin:${PATH}

llvm-help:
	@echo
	@echo "These are the make targets for building LLVM and Clang:"
	@echo "* make llvm-[fetch,configure,build,sync,clean]"
	@echo "* make clang-[fetch,configure,build,sync,clean]"

llvm-settings:
	@echo "# LLVM settings"
	@echo "LLVM_GIT		= ${LLVM_GIT}"
	@echo "LLVM_BRANCH		= ${LLVM_BRANCH}"
	@$(call gitcommit,${LLVMDIR},LLVM_COMMIT)
	@echo "LLVM_OPTIMIZED		= ${LLVM_OPTIMIZED}"
	@echo "# Clang settings"
	@echo "CLANG_GIT		= ${CLANG_GIT}"
	@echo "CLANG_BRANCH		= ${CLANG_BRANCH}"
	@$(call gitcommit,${CLANGDIR},CLANG_COMMIT)
	@echo "COMPILERRT_GIT		= ${COMPILERRT_GIT}"
	@echo "COMPILERRT_BRANCH	= ${COMPILERRT_BRANCH}"
	@$(call gitcommit,${COMPILERRTDIR},COMPILERRT_COMMIT)

llvm-fetch: ${LLVMSTATE}/llvm-fetch
${LLVMSTATE}/llvm-fetch:
	@$(call banner, "Fetching LLVM...")
	@mkdir -p $(dir ${LLVMDIR})
	$(call gitclone,${LLVM_GIT} -b ${LLVM_BRANCH},${LLVMDIR})
	@if [ -n "${LLVM_COMMIT}" ] ; then \
		$(call banner, "Fetching commit-ish LLVM...") ; \
		(cd ${LLVMDIR} && git checkout -f ${LLVM_COMMIT}) ; \
	fi
	$(call state,$@,llvm-patch)

compilerrt-fetch: ${LLVMSTATE}/compilerrt-fetch
${LLVMSTATE}/compilerrt-fetch: ${LLVMSTATE}/llvm-fetch 
	@$(call banner, "Fetching Compilerrt...")
	$(call gitclone,${COMPILERRT_GIT} -b ${COMPILERRT_BRANCH},${COMPILERRTDIR})
	$(call state,$@)

clang-fetch: ${LLVMSTATE}/clang-fetch
${LLVMSTATE}/clang-fetch:
	@$(call banner, "Fetching Clang...")
	@mkdir -p ${LLVMSRCDIR}
	$(call gitclone,${CLANG_GIT} -b ${CLANG_BRANCH},${CLANGDIR})
	@if [ -n "${CLANG_COMMIT}" ] ; then \
		$(call banner, "Fetching commit-ish Clang...") ; \
		(cd ${CLANGDIR} && git checkout -f ${CLANG_COMMIT}) ; \
	fi
	$(call state,$@,clang-patch)

llvm-patch: ${LLVMSTATE}/llvm-patch
${LLVMSTATE}/llvm-patch: ${LLVMSTATE}/llvm-fetch
	@$(call banner, "Patching LLVM...")
	@$(call patches_dir,${LLVMPATCHES}/llvm,${LLVMDIR}/patches)
	@$(call patch,${LLVMDIR})
	$(call state,$@,llvm-configure)

clang-patch: ${LLVMSTATE}/clang-patch
${LLVMSTATE}/clang-patch: ${LLVMSTATE}/clang-fetch
	@$(call banner, "Patching Clang...")
	@$(call patches_dir,${LLVMPATCHES}/clang,${CLANGDIR}/patches)
	@$(call patch,${CLANGDIR})
	$(call state,$@,clang-configure)

compilerrt-patch: ${LLVMSTATE}/compilerrt-patch
${LLVMSTATE}/compilerrt-patch: ${LLVMSTATE}/compilerrt-fetch
	@$(call banner, "Patching Compiler-rt...")
	@$(call patches_dir,${LLVMPATCHES}/compiler-rt,${COMPILERRTDIR}/patches)
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
	@$(call optional_gitreset,${LLVMDIR})
	@$(call optional_gitreset,${COMPILERRTDIR})
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
	@$(call optional_gitreset,${CLANGDIR})
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
	@if [ -n "${LLVM_COMMIT}" ] ; then \
		$(call banner, "Syncing commit-ish Clang...") ; \
		(cd ${LLVMDIR} && git checkout -f ${LLVM_COMMIT}) ; \
	else \
		(cd ${LLVMDIR} && git checkout ${LLVM_BRANCH} && git pull) ; \
	fi

clang-sync: clang-clean
	@$(call banner,Updating Clang...)
	@if [ -n "${CLANG_COMMIT}" ] ; then \
		$(call banner, "Syncing commit-ish Clang...") ; \
		(cd ${CLANGDIR} && git checkout -f ${CLANG_COMMIT}) ; \
	else \
		(cd ${CLANGDIR} && git checkout ${CLANG_BRANCH} && git pull) ; \
	fi

compilerrt-sync: ${LLVMSTATE}/compilerrt-sync
${LLVMSTATE}/compilerrt-sync: ${LLVMSTATE}/llvm-fetch 
	@$(call banner, "Updating Compilerrt...")
	(cd ${COMPILERRTDIR} && git checkout ${COMPILERRT_BRANCH} && git pull)
	$(call state,$@)

llvm-version:
	@(cd ${LLVMDIR} && [ -f "${LLVMINSTALLDIR}/bin/llc" ] \
		&& echo "`${LLVMINSTALLDIR}/bin/llc --version | grep version | xargs echo` commit `git rev-parse HEAD`" \
		|| echo "LLVM version ? commit `git rev-parse HEAD`")
clang-version:
	@(cd ${CLANGDIR} && [ -f "${CLANG}" ] \
		&& echo "`${CLANG} --version | grep version | xargs echo` commit `git rev-parse HEAD`" \
		|| echo "clsng version ? commit `git rev-parse HEAD`")

clang-update-all: llvm-sync clang-sync compilerrt-sync llvm-build clang-build

