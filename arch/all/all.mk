#############################################################################
# Copyright (c) 2012 Mark Charlebois
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

# NOTE: MAKE_KERNEL must also be defined in the calling Makefile
#
# The ARCH makefile must provide the following:
#   - MAKE_FLAGS
#   - MAKE_KERNEL
#   - KERNEL_PATCH_DIR += ${ARCH_xxx_PATCHES} ${ARCH_xxx_PATCHES}/${KERNEL_REPO_PATCHES}
#   
# The target makefile must provide the following:
#   - KERNEL_CFG
#   - KERNEL_PATCH_DIR += ${PATCHDIR} ${PATCHDIR}/${KERNEL_REPO_PATCHES}

export V
export CHECKERDIR

ARCH_ALL_DIR	= ${ARCHDIR}/all
ARCH_ALL_BINDIR	= ${ARCH_ALL_DIR}/bin
ARCH_ALL_PATCHES= ${ARCH_ALL_DIR}/patches

PATH		:= ${PATH}:${ARCH_ALL_BINDIR}

MAINLINEURI	= git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
SHARED_KERNEL	= ${ARCH_ALL_DIR}/kernel.git

export TIME
TIME		= $(shell echo ${seperator})\n\
$(shell echo Build Time)\n\
$(shell echo ${seperator})\n\
	User time (seconds): %U\n\
	System time (seconds): %S\n\
	Percent of CPU this job got: %P\n\
	Elapsed (wall clock) time (h:mm:ss or m:ss): %E\n\
	Average shared text size (kbytes): %X\n\
	Average unshared data size (kbytes): %D\n\
	Average stack size (kbytes): %p\n\
	Average total size (kbytes): %K\n\
	Maximum resident set size (kbytes): %M\n\
	Average resident set size (kbytes): %t\n\
	Major (requiring I/O) page faults: %F\n\
	Minor (reclaiming a frame) page faults: %R\n\
	Voluntary context switches: %w\n\
	Involuntary context switches: %c\n\
	Socket messages received: %r\n\
	Command being timed: "%C"\n\
	Swaps: %W\n\
	File system inputs: %I\n\
	File system outputs: %O\n\
	Socket messages sent: %s\n\
	Signals delivered: %k\n\
	Page size (bytes): %Z\n\
	Exit status: %x

#############################################################################
ifeq "${KERNEL_GIT}" ""
KERNEL_GIT	= ${MAINLINEURI}
endif
ifeq "${KERNEL_BRANCH}" ""
KERNEL_BRANCH	= master
endif
ifeq "${KERNELDIR}" ""
KERNELDIR	= ${SRCDIR}/linux
endif
ifeq "${KERNELCOPY}" ""
KERNELCOPY	= ${KERNELDIR}-copy
endif
ifeq "${KERNELGCC}" ""
KERNELGCC	= ${KERNELDIR}-gcc
endif

TOPLOGDIR	= ${TOPDIR}/log

CHECKERDIR	= ${TARGETDIR}/checker
LOGDIR		= ${TARGETDIR}/log
PATCHDIR	= ${TARGETDIR}/patches
SRCDIR		= ${TARGETDIR}/src
STATEDIR	= ${TARGETDIR}/state
TMPDIR		= ${TARGETDIR}/tmp

TMPDIRS		+= ${TMPDIR}

#############################################################################
catfile		= ([ -f ${1} ] && cat ${1})
add_patches	= $(addprefix ${1}/,$(shell $(call catfile,${1}/series.target) || $(call catfile,${1}/series)))
KERNEL_PATCH_DIR+= ${ARCH_ALL_PATCHES} ${ARCH_ALL_PATCHES}/${KERNEL_REPO_PATCHES}

# ${1}=logdir ${2}=toolchain ${3}=testname
sizelog	= ${1}/${2}-${ARCH}-`date +%Y-%m-%d_%H:%M:%S`-kernel-size.log

KERNEL_SIZE_CLANG_LOG	= clang-`date +%Y-%m-%d_%H:%M:%S`-kernel-size.log
KERNEL_SIZE_GCC_LOG	= gcc-`date +%Y-%m-%d_%H:%M:%S`-kernel-size.log

get-kernel-version	= [ ! -d ${1} ] || (cd ${1} && echo "src/$(notdir ${1}) version `make kernelversion 2>/dev/null | grep -v ^make` commit `git rev-parse HEAD`")

#############################################################################
KERNEL_TARGETS_CLANG	= kernel-[fetch,patch,configure,build,clean,sync]
KERNEL_TARGETS_GCC	= kernel-gcc-[fetch,patch,configure,build,clean,sync] kernel-gcc-sparse 
KERNEL_TARGETS_APPLIED	= kernel-patch-applied kernel-gcc-patch-applied
KERNEL_TARGETS_CLEAN	= tmp-clean
KERNEL_TARGETS_VERSION	= kernel-version kernel-gcc-version

#############################################################################
TARGETS_BUILD		+= ${KERNEL_TARGETS_CLANG} ${KERNEL_TARGETS_GCC} ${KERNEL_TARGETS_APPLIED} ${KERNEL_TARGETS_CLEAN}
CLEAN_TARGETS		+= ${KERNEL_TARGETS_CLEAN}
FETCH_TARGETS		+= kernel-fetch kernel-gcc-fetch
HELP_TARGETS		+= kernel-help
MRPROPER_TARGETS	+= kernel-clean-noreset kernel-gcc-clean-noreset
PATCH_APPLIED_TARGETS	+= ${KERNEL_TARGETS_APPLIED}
RAZE_TARGETS		+= kernel-raze
SETTINGS_TARGETS	+= kernel-settings
SYNC_TARGETS		+= kernels-sync
VERSION_TARGETS		+= ${KERNEL_TARGETS_VERSION}

.PHONY:			${KERNEL_TARGETS_CLANG} ${KERNEL_TARGETS_GCC} ${KERNEL_TARGETS_APPLIED} ${KERNEL_TARGETS_CLEAN} ${KERNEL_TARGETS_VERSION}

#############################################################################
kernel-help:
	@echo
	@echo "These are the kernel make targets:"
	@echo "* make kernel-[fetch,patch,configure,build,sync,clean]"
	@echo "* make kernel-gcc-[fetch,patch,configure,build,sync,clean]"
	@echo "               fetch     - clone kernel code"
	@echo "               patch     - patch kernel code"
	@echo "               configure - configure kernel code (add .config file, etc)"
	@echo "               build     - build kernel code"
	@echo "               sync      - clean, unpatch, then git pull kernel code"
	@echo "               clean     - clean, unpatch kernel code"
	@echo "* make kernel-gcc-sparse - build gcc kernel with sparse"
	@echo "* make kernels		- build kernel with both clang and gcc"

#############################################################################
kernel-settings:
	@(echo "# Kernel settings" ; \
	echo "KERNEL_GIT		= ${KERNEL_GIT}" ; \
	echo "KERNEL_BRANCH		= ${KERNEL_BRANCH}" ; \
	echo "KERNEL_TAG		= ${KERNEL_TAG}" ; \
	$(call gitcommit,${KERNELDIR},KERNEL_COMMIT) ; \
	echo "KERNELDIR		= ${KERNELDIR}" ; \
	echo "KERNELGCC		= ${KERNELGCC}" ; \
	echo "KERNEL_CFG		= ${KERNEL_CFG}" ; \
	) | sed -e 's|${TARGETDIR}|$${TARGETDIR}|g'

include ${ARCHDIR}/all/quilt.mk

#############################################################################
# The shared kernel is a bare repository of Linus' kernel.org kernel
# It serves as a git alternate for all the other target specific kernels.
# This is purely meant as a disk space saving effort.
kernel-shared: ${SHARED_KERNEL}
${SHARED_KERNEL}:
	@$(call banner, "Cloning shared kernel repo...")
	@[ -d ${@:.git=} ] && ( \
		$(call banner, "Moving kernel/.git to kernel.git"); \
		mv ${@:.git=}/.git $@; \
		echo -e "[core]\n\trepositoryformatversion = 0\n\tfilemode = true\n\tbare = true" > $@/config; \
		echo -e "[remote \"origin\"]\n\turl = ${MAINLINEURI}" >> $@/config; \
		rm -rf ${@:.git=} & \
		${MAKE} kernel-shared-sync; \
	) || git clone --bare ${MAINLINEURI} $@
	@grep -q '\[remote "origin"\]' $@/config \
		|| echo -e "[remote \"origin\"]\n\turl = ${MAINLINEURI}" >> $@/config;

#############################################################################
kernel-raze:
	@$(call banner,Razing kernel)
	@rm -rf ${SHARED_KERNEL} ${KERNELDIR} ${KERNELCOPY} ${KERNELGCC}
	@rm -f $(addsuffix /*,${LOGDIR} ${TMPDIR})
	@$(call leavestate,${STATEDIR},*)

#############################################################################
kernel-fetch: state/kernel-fetch
state/kernel-fetch: ${SHARED_KERNEL}
	@$(call banner, "Cloning kernel...")
	@mkdir -p ${SRCDIR}
	@[ -z "${KERNEL_BRANCH}" ] || $(call banner, "Checking out kernel branch...")
	$(call gitclone,--reference $< ${KERNEL_GIT} -b ${KERNEL_BRANCH},${KERNELDIR})
	@if [ -n "${KERNEL_COMMIT}" ] ; then \
		$(call banner, "Checking out commit-ish kernel...") ; \
		$(call gitcheckout,${KERNELDIR},${KERNEL_BRANCH},${KERNEL_COMMIT}) ; \
	elif [ -n "${KERNEL_TAG}" ] ; then \
		$(call banner, "Checking out tagged kernel...") ; \
		( cd ${KERNELDIR} && ( [ -f ${KERNELDIR}/.git/refs/heads/${KERNEL_TAG} ] || git checkout -b ${KERNEL_TAG} ${KERNEL_TAG} )) ; \
		( cd ${KERNELDIR} && git checkout -f ${KERNEL_TAG} ) ; \
	fi
	$(call state,$@,kernel-patch)

#############################################################################
kernel-gcc-fetch: state/kernel-gcc-fetch
state/kernel-gcc-fetch: state/kernel-fetch
	@$(call banner, "Cloning kernel for gcc...")
	$(call gitclone,${KERNELDIR},${KERNELGCC})
	@if [ -n "${KERNEL_BRANCH}" ] ; then \
		$(call banner, "Checking out kernel branch for gcc...") ; \
		(cd ${KERNELGCC} && git checkout -B ${KERNEL_BRANCH}) ; \
	fi
	@if [ -n "${KERNEL_COMMIT}" ] ; then \
		$(call banner, "Checking out commit-ish kernel for gcc...") ; \
		$(call gitcheckout,${KERNELGCC},${KERNEL_BRANCH},${KERNEL_COMMIT}) ; \
	elif [ -n "${KERNEL_TAG}" ] ; then \
		$(call banner, "Checking out tagged kernel for gcc...") ; \
		(cd ${KERNELGCC} && git checkout ${KERNEL_TAG}) ; \
	fi
	$(call state,$@,kernel-gcc-patch)

#############################################################################
kernel-patch: state/kernel-patch
state/kernel-patch: state/kernel-fetch state/kernel-quilt
	@$(call banner, "Patching kernel...")
	@$(call patches_dir,${PATCHDIR},${KERNELDIR}/patches)
	@$(call patch,${KERNELDIR})
	$(call state,$@,kernel-configure)

#############################################################################
kernel-gcc-patch: state/kernel-gcc-patch
state/kernel-gcc-patch: state/kernel-gcc-fetch state/kernel-quilt
	@$(call banner, "Patching kernel for gcc...")
	@$(call patches_dir,${PATCHDIR},${KERNELGCC}/patches)
	@$(call patch,${KERNELGCC})
	$(call state,$@,kernel-gcc-configure)

#############################################################################
kernel-patch-applied:
	@$(call banner,"Patches applied for Clang kernel")
	@$(call applied,${KERNELDIR})

#############################################################################
kernel-gcc-patch-applied:
	@$(call banner,"Patches applied for gcc kernel")
	@$(call applied,${KERNELGCC})

#############################################################################
kernel-configure: state/kernel-configure
state/kernel-configure: state/kernel-patch
	@$(call banner, "Configuring kernel...")
	@cp ${KERNEL_CFG} ${KERNELDIR}/.config
	(cd ${KERNELDIR} && echo "" | make ${MAKE_FLAGS} oldconfig)
	$(call state,$@,kernel-build)

#############################################################################
kernel-gcc-configure: state/kernel-gcc-configure
state/kernel-gcc-configure: state/kernel-gcc-patch
	@$(call banner, "Configuring kernel (for gcc build)...")
	@cp ${KERNEL_CFG} ${KERNELGCC}/.config
	@echo "CONFIG_ARM_UNWIND=y" >> ${KERNELGCC}/.config
	(cd ${KERNELGCC} && echo "" | make ${MAKE_FLAGS} oldconfig)
	$(call state,$@,kernel-gcc-build)

#############################################################################
kernel-build: state/kernel-build
state/kernel-build: ${LLVMSTATE}/clang-build ${STATE_TOOLCHAIN} state/kernel-configure
	$(call assert,-n "${MAKE_KERNEL}",MAKE_KERNEL undefined)
	@$(MAKE) kernel-quilt-link-patches
	@$(call banner,"Building kernel with clang...")
	(cd ${KERNELDIR} && time ${MAKE_KERNEL})
	@$(call banner,"Successfully Built kernel with clang!")
	@mkdir -p ${TOPLOGDIR}
	@( ${CLANG} --version | head -1 ; \
		cd ${KERNELDIR} && wc -c ${KERNEL_SIZE_ARTIFACTS} ) \
		| tee $(call sizelog,${TOPLOGDIR},clang)
	$(call state,$@,done)

#############################################################################
kernel-gcc-build: ${STATE_TOOLCHAIN} state/kernel-gcc-build
state/kernel-gcc-build: ${CROSS_GCC} state/kernel-gcc-configure
	$(call assert,-n "${MAKE_KERNEL}",MAKE_KERNEL undefined)
	@$(MAKE) kernel-quilt-link-patches
	@$(call banner, "Building kernel with gcc...")
	(cd ${KERNELGCC} && time make -j${JOBS} ${MAKE_FLAGS} ${SPARSE} CROSS_COMPILE=${CROSS_COMPILE} CC=${GCC_CC})
	@mkdir -p ${TOPLOGDIR}
	( ${CROSS_GCC} --version | head -1 ; \
		cd ${KERNELGCC} && wc -c ${KERNEL_SIZE_ARTIFACTS}) \
		| tee $(call sizelog,${TOPLOGDIR},gcc)
	$(call state,$@,done)

#############################################################################
kernel-build-force kernel-gcc-build-force: %-force:
	@rm -f state/$*
	${MAKE} $*

#############################################################################
kernel-gcc-sparse:
	@$(call assert_found_in_path,sparse)
	${MAKE} kernel-gcc-configure
	@$(call patches_dir,${PATCHDIR},${KERNELGCC}/patches)
	@$(call banner, "Building unpatched gcc kernel for eventual analysis with sparse...")
	@$(call unpatch,${KERNELGCC})
	${MAKE} kernel-gcc-build-force
	@$(call banner, "Rebuilding patched gcc kernel with sparse (changed files only)...")
	@$(call patch,${KERNELGCC})
	${MAKE} SPARSE=C=1 kernel-gcc-build-force

#############################################################################
kernels: kernel-build kernel-gcc-build
kernels-sync: kernel-sync kernel-gcc-sync
kernels-clean: kernel-clean kernel-gcc-clean

#############################################################################
kernel-shared-sync:
	@$(call banner, "Syncing shared kernel.org kernel...")
	(cd ${SHARED_KERNEL} && git fetch origin +refs/heads/*:refs/heads/*)

#############################################################################
kernel-sync: state/kernel-fetch kernel-shared-sync kernel-clean
	@$(call banner, "Syncing kernel...")
	@if [ -n "${KERNEL_COMMIT}" ] ; then \
		$(call banner, "Syncing commit-ish kernel...") ; \
		$(call gitcheckout,${KERNELDIR},${KERNEL_BRANCH},${KERNEL_COMMIT}) ; \
	elif [ -n "${KERNEL_TAG}" ] ; then \
		(cd ${KERNELDIR} && git pull origin ${KERNEL_TAG}) ; \
	else \
		(cd ${KERNELDIR} && git checkout ${KERNEL_BRANCH} && git pull) ; \
	fi

#############################################################################
kernel-gcc-sync: state/kernel-gcc-fetch kernel-shared-sync kernel-gcc-clean
	@$(call banner, "Syncing gcc kernel...")
	@if [ -n "${KERNEL_COMMIT}" ] ; then \
		$(call banner, "Syncing commit-ish kernel-gcc...") ; \
		$(call gitcheckout,${KERNELGCC},${KERNEL_BRANCH},${KERNEL_COMMIT}) ; \
	elif [ -n "${KERNEL_TAG}" ] ; then \
		(cd ${KERNELGCC} && git pull origin ${KERNEL_TAG}) ; \
	else \
		(cd ${KERNELGCC} && git checkout ${KERNEL_BRANCH} && git pull) ; \
	fi

#############################################################################
kernel-reset: state/kernel-fetch
	@(cd ${KERNELDIR} && ${MAKE} clean)
	@$(call unpatch,${KERNELDIR})
	@$(call optional_gitreset,${KERNELDIR})
	@$(call leavestate,${STATEDIR},kernel-patch kernel-quilt kernel-configure kernel-build)

#############################################################################
kernel-gcc-reset: state/kernel-gcc-fetch
	@(cd ${KERNELGCC} && ${MAKE} clean)
	@$(call unpatch,${KERNELGCC})
	@$(call optional_gitreset,${KERNELGCC})
	@$(leavestate ${STATEDIR},kernel-gcc-configure kernel-gcc-patch kernel-gcc-build)

#############################################################################
kernel-mrproper: state/kernel-fetch kernel-clean-tmp
	(cd ${KERNELDIR} && make mrproper)
	@$(call leavestate,${STATEDIR},kernel-build)

#############################################################################
kernel-gcc-mrproper: state/kernel-gcc-fetch kernel-clean-tmp
	(cd ${KERNELGCC} && make mrproper)
	@$(call leavestate,${STATEDIR},kernel-gcc-build)

#############################################################################
kernel-clean-tmp:
	@rm -f ${LOGDIR}/*.log ${TMPDIR}/*.patch
	@$(call leavestate ${STATEDIR},kernel-quilt kernel-patch kernel-configure kernel-build)
	@$(call banner,"Clang compiled Kernel is now clean")

#############################################################################
kernel-gcc-clean-tmp:
	@$(call leavestate ${STATEDIR},kernel-gcc-patch kernel-gcc-configure kernel-gcc-build)
	@$(call banner,"Gcc compiled Kernel is now clean")

#############################################################################
kernel-clean kernel-gcc-clean: kernel-%clean: kernel-%reset kernel-%clean-tmp
kernel-clean-noreset kernel-gcc-clean-noreset: kernel-%clean-noreset: kernel-%mrproper

#############################################################################
kernel-version:
	@$(call get-kernel-version,${KERNELDIR})
kernel-gcc-version:
	@$(call get-kernel-version,${KERNELGCC})

#############################################################################
${TMPDIR}:
	@mkdir -p $@
tmp-clean:
	rm -rf ${TMPDIR}/*

time:
	(cd ${KERNELDIR} && time ls)

#############################################################################
# The order of these includes is important
include ${TESTDIR}/test.mk
include ${TOOLSDIR}/tools.mk
