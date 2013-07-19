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

# The ARCH makefile must provide the following:
#   - KERNEL_PATCH_DIR += ${ARCH_xxx_PATCHES} ${ARCH_xxx_PATCHES}/${KERNEL_REPO_PATCHES}
#   
# The target makefile must provide the following:
#   - KERNEL_CFG
#   - KERNEL_PATCH_DIR += ${PATCHDIR} ${PATCHDIR}/${KERNEL_REPO_PATCHES}

export TMPDIR V

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
	Maximum resident set size (kbytes): %M\n\
	Major (requiring I/O) page faults: %F\n\
	Minor (reclaiming a frame) page faults: %R\n\
	Voluntary context switches: %w\n\
	Involuntary context switches: %c\n\
	Command being timed: "%C"\n\
	Swaps: %W\n\
	File system inputs: %I\n\
	File system outputs: %O\n\
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
ifeq "${KERNELGCC}" ""
KERNELGCC	= ${KERNELDIR}-gcc
endif

#############################################################################
KERNEL_BUILD	= $(subst ${TOPDIR},${BUILDROOT},${KERNELDIR})
KERNELGCC_BUILD	= $(subst ${TOPDIR},${BUILDROOT},${KERNELGCC})
ifneq (${TOPDIR},${BUILDROOT})
KERNEL_ENV	+= KBUILD_OUTPUT=${KERNEL_BUILD}
KERNELGCC_ENV	+= KBUILD_OUTPUT=${KERNELGCC_BUILD}
endif

#############################################################################
CLANGCC		= ${CLANG} ${CCOPTS}

ifneq ("${CROSS_COMPILE}", "")
MAKE_FLAGS	+= ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
endif
ifneq ("${JOBS}", "")
KERNEL_VAR	+= -j${JOBS}
endif
ifneq ("${CFLAGS}", "")
KERNEL_VAR	+= CFLAGS_KERNEL="${CFLAGS}" CFLAGS_MODULE="${CFLAGS}"
endif
KERNEL_VAR	+= CONFIG_DEBUG_INFO=1
KERNEL_VAR	+= CONFIG_DEBUG_SECTION_MISMATCH=y
KERNEL_VAR	+= CONFIG_NO_ERROR_ON_MISMATCH=y
#KERNEL_VAR	+= KALLSYMS_EXTRA_PASS=1
KERNEL_VAR	+= ${EXTRAFLAGS}

list-var: list-buildroot
	@which gcc clang
	@echo ${seperator}
	@echo "ARCH=${ARCH}"
	@echo "CC=${CC}"
	@echo "CFLAGS=${CFLAGS}"
	@echo "CLANGCC=${CLANGCC}"
	@echo "COMPILER_PATH='${COMPILER_PATH}'"
	@echo "CROSS_COMPILE=${CROSS_COMPILE}"
	@echo "CROSS_GCC=${CROSS_GCC}"
	@echo "HOST=${HOST}"
	@echo "HOST_TRIPLE=${HOST_TRIPLE}"
	@echo "JOBS=${JOBS}"
	@echo "KBUILD_OUTPUT=${KBUILD_OUTPUT}"
	@echo "KERNELDIR=${KERNELDIR}"
	@echo "KERNEL_BUILD=${KERNEL_BUILD}"
	@echo "KERNEL_ENV=${KERNEL_ENV}"
	@echo "KERNEL_VAR=${KERNEL_VAR}"
	@echo "MAKE_FLAGS=${MAKE_FLAGS}"
	@echo "MARCH=${MARCH}"
	@echo "MFLOAT=${MFLOAT}"
	@echo "PATH=${PATH}"
	@echo "TMPDIR=${TMPDIR}"
	@echo "USE_CCACHE=${USE_CCACHE}"
	@echo "V=${V}"
	@echo ${seperator}
	@echo "${CLANG} -print-file-name=include"
	@${CLANG} -print-file-name=include

	@echo '$(call make-kernel,${KERNELDIR},${KERNEL_ENV},CC="${CLANGCC}")'

#############################################################################
TOPLOGDIR	= ${TOPDIR}/log

LOGDIR		= ${TARGETDIR}/log
PATCHDIR	= ${TARGETDIR}/patches
SRCDIR		= ${TARGETDIR}/src
STATEDIR	= ${TARGETDIR}/state
TMPDIR		= $(subst ${TOPDIR},${BUILDROOT},${TARGETDIR}/tmp)

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
get-kernel-size		= mkdir -p ${TOPLOGDIR} ; \
			( ${2} --version | head -1 ; \
			cd ${3} && wc -c ${KERNEL_SIZE_ARTIFACTS} ) \
			| tee $(call sizelog,${TOPLOGDIR},{1})
make-kernel		= (cd ${1} && ${2} time make ${MAKE_FLAGS} ${KERNEL_VAR} ${3} ${KERNEL_MAKE_TARGETS} ${4})

#############################################################################
KERNEL_TARGETS_CLANG	= kernel-[fetch,patch,configure,build,clean,sync]
KERNEL_TARGETS_GCC	= kernel-gcc-[fetch,patch,configure,build,clean,sync] kernel-gcc-sparse
KERNEL_TARGETS_APPLIED	= kernel-patch-applied kernel-gcc-patch-applied
KERNEL_TARGETS_CLEAN	= tmp-clean
KERNEL_TARGETS_VERSION	= kernel-version kernel-gcc-version

#############################################################################

KERNEL_BISECT_START_DATE := 2012-11-01

#############################################################################
TARGETS_BUILD		+= ${KERNEL_TARGETS_CLANG} ${KERNEL_TARGETS_GCC} ${KERNEL_TARGETS_APPLIED} ${KERNEL_TARGETS_CLEAN}
CLEAN_TARGETS		+= ${KERNEL_TARGETS_CLEAN}
FETCH_TARGETS		+= kernel-fetch kernel-gcc-fetch
HELP_TARGETS		+= kernel-help
MRPROPER_TARGETS	+= kernel-clean kernel-gcc-clean
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
	@echo "* make kernel-bisect-start KERNEL_BISECT_START_DATE=2012-11-01"
	@echo "                          - start bisect process at date ^^^"
	@echo "* make kernel-bisect-good - mark as good"
	@echo "* make kernel-bisect-bad  - mark as bad"
	@echo "* make kernel-bisect-skip - skip revision"

##############################################################################
CHECKPOINT_TARGETS		+= kernel-checkpoint
CHECKPOINT_KERNEL_CONFIG	= ${CHECKPOINT_DIR}/kernel.config
CHECKPOINT_KERNEL_PATCHES	= ${CHECKPOINT_PATCHES}/kernel
kernel-checkpoint: kernel-quilt
	@$(call banner,Checkpointing kernel)
	@cp ${KERNEL_CFG} ${CHECKPOINT_KERNEL_CONFIG}
	@$(call checkpoint-patches,${PATCHDIR},${CHECKPOINT_KERNEL_PATCHES})

#############################################################################
kernel-settings:
	@(echo "# Kernel settings" ; \
	$(call prsetting,KERNEL_GIT,${KERNEL_GIT}) ; \
	$(call prsetting,KERNEL_BRANCH,${KERNEL_BRANCH}) ; \
	$(call prsetting,KERNEL_TAG,${KERNEL_TAG}) ; \
	$(call gitcommit,${KERNELDIR},KERNEL_COMMIT) ; \
	$(call prsetting,KERNELDIR,${KERNELDIR}) ; \
	$(call prsetting,KERNELGCC,${KERNELGCC}) ; \
	[ -n "${CHECKPOINT}" ] && $(call prsetting,KERNEL_CFG,${CHECKPOINT_KERNEL_CONFIG}) \
	|| $(call prsetting,KERNEL_CFG,${KERNEL_CFG}) ; \
	) | $(call configfilter)

include ${ARCHDIR}/all/quilt.mk

#############################################################################
# The shared kernel is a bare repository of Linus' kernel.org kernel
# It serves as a git alternate for all the other target specific kernels.
# This is purely meant as a disk space saving effort.
kernel-shared: ${SHARED_KERNEL}
${SHARED_KERNEL}:
	@$(call banner,Cloning shared kernel repo...)
	@[ -d ${@:.git=} ] && ( \
		$(call echo,Moving kernel/.git to kernel.git); \
		mv ${@:.git=}/.git $@; \
		echo -e "[core]\n\trepositoryformatversion = 0\n\tfilemode = true\n\tbare = true" > $@/config; \
		echo -e "[remote \"origin\"]\n\turl = ${MAINLINEURI}" >> $@/config; \
		rm -rf ${@:.git=} & \
		${MAKE} kernel-shared-sync; \
	) || $(call gitclone,--bare ${MAINLINEURI},$@)
	@grep -q '\[remote "origin"\]' $@/config \
		|| echo -e "[remote \"origin\"]\n\turl = ${MAINLINEURI}" >> $@/config;

#############################################################################
kernel-raze:
	@$(call banner,Razing kernel)
	@rm -rf ${SHARED_KERNEL} ${KERNELDIR} ${KERNELGCC}
	@rm -f $(addsuffix /*,${LOGDIR} ${TMPDIR})
	@$(call leavestate,${STATEDIR},*)

#############################################################################
kernel-fetch: state/kernel-fetch prep
state/kernel-fetch: ${SHARED_KERNEL}
	@$(call banner,Cloning kernel...)
	@mkdir -p ${SRCDIR}
	@[ -z "${KERNEL_BRANCH}" ] || $(call echo,Checking out kernel branch...)
	$(call gitclone,--reference $< ${KERNEL_GIT} -b ${KERNEL_BRANCH},${KERNELDIR})
	@if [ -n "${KERNEL_COMMIT}" ] ; then \
		$(call echo,Checking out commit-ish kernel...) ; \
		$(call gitcheckout,${KERNELDIR},${KERNEL_BRANCH},${KERNEL_COMMIT}) ; \
	elif [ -n "${KERNEL_TAG}" ] ; then \
		$(call echo,Checking out tagged kernel...) ; \
		$(call gitmove,${KERNELDIR},${KERNEL_TAG},tag-${KERNEL_TAG}) ; \
		$(call gitcheckout,${KERNELDIR},${KERNEL_TAG}) ; \
	fi
	$(call state,$@,kernel-patch)

#############################################################################
kernel-gcc-fetch: state/kernel-gcc-fetch
state/kernel-gcc-fetch: state/kernel-fetch
	@$(call banner,Cloning kernel for gcc...)
	$(call gitclone,${KERNELDIR},${KERNELGCC})
	@if [ -n "${KERNEL_COMMIT}" ] ; then \
		$(call echo,Checking out commit-ish kernel for gcc...) ; \
		$(call gitcheckout,${KERNELGCC},${KERNEL_BRANCH},${KERNEL_COMMIT}) ; \
	elif [ -n "${KERNEL_TAG}" ] ; then \
		$(call echo,Checking out tagged kernel for gcc...) ; \
		$(call gitmove,${KERNELGCC},${KERNEL_TAG},tag-${KERNEL_TAG}) ; \
		$(call gitcheckout,${KERNELGCC},${KERNEL_TAG}) ; \
	elif [ -n "${KERNEL_BRANCH}" ] ; then \
		$(call echo,Checking out kernel branch for gcc...) ; \
		$(call gitcheckout,${KERNELGCC},${KERNEL_BRANCH}) ; \
	fi
	$(call state,$@,kernel-gcc-patch)

#############################################################################
kernel-patch: state/kernel-patch
state/kernel-patch: state/kernel-fetch state/kernel-quilt
	@$(call banner,Patching kernel...)
	@echo ${PATCHDIR}
	$(call patches_dir,${PATCHDIR},${KERNELDIR}/patches)
	@$(call optional_gitreset,${KERNELDIR})
	@$(call patch,${KERNELDIR})
	$(call state,$@,kernel-configure)

#############################################################################
kernel-gcc-patch: state/kernel-gcc-patch
state/kernel-gcc-patch: state/kernel-gcc-fetch state/kernel-quilt
	@$(call banner,Patching kernel for gcc...)
	@$(call patches_dir,${PATCHDIR},${KERNELGCC}/patches)
	@$(call optional_gitreset,${KERNELGCC})
	@$(call patch,${KERNELGCC})
	$(call state,$@,kernel-gcc-configure)

#############################################################################
kernel-patch-applied:
	@$(call banner,Patches applied for Clang kernel)
	@$(call applied,${KERNELDIR})

#############################################################################
kernel-gcc-patch-applied:
	@$(call banner,Patches applied for gcc kernel)
	@$(call applied,${KERNELGCC})

#############################################################################
kernel-patch-status:
	@$(call banner,Patch status for the kernel)
	@$(call patchseriesstatus,${PATCHDIR})

#############################################################################
kernel-configure: state/kernel-configure
state/kernel-configure: state/kernel-patch
	@make -s build-dep-check
	@$(call banner,Configuring kernel...)
	@mkdir -p ${KERNEL_BUILD}
	@cp ${KERNEL_CFG} ${KERNEL_BUILD}/.config
	if [ -n "${CLANGDIR}" ] ; then \
		(cd ${CLANGDIR} ; xx=$$(git log -1 --oneline | cut -d" " -f1) ; sed -i -e "s#-llvmlinux#-llvmlinux-C.$$xx#g" ${KERNEL_BUILD}/.config) ; \
	fi
	if [ -n "${LLVMDIR}" ] ; then \
		(cd ${LLVMDIR} ; xx=$$(git log -1 --oneline | cut -d" " -f1) ; sed -i -e "s#-llvmlinux#-llvmlinux-L.$$xx#g" ${KERNEL_BUILD}/.config) ; \
	fi
	(cd ${KERNELDIR} && echo "" | ${KERNEL_ENV} make ${MAKE_FLAGS} oldconfig)
	$(call state,$@,kernel-build)

#############################################################################
kernel-menuconfig: state/kernel-configure
	${KERNEL_ENV} make -C ${KERNELDIR} ${MAKE_FLAGS} menuconfig
	@$(call leavestate,state,kernel-build)

kernel-cmpconfig: state/kernel-configure
	diff -Nau ${KERNEL_CFG} ${KERNEL_BUILD}/.config

kernel-cpconfig: state/kernel-configure
	@cp -v ${KERNEL_BUILD}/.config ${KERNEL_CFG}

#############################################################################
kernel-gcc-configure: state/kernel-gcc-configure
state/kernel-gcc-configure: state/kernel-gcc-patch
	@make -s build-dep-check
	@$(call banner,Configuring gcc kernel...)
	@mkdir -p ${KERNELGCC_BUILD}
	@cp ${KERNEL_CFG} ${KERNELGCC_BUILD}/.config
	@echo "CONFIG_ARM_UNWIND=y" >> ${KERNELGCC_BUILD}/.config
	(cd ${KERNELGCC} && echo "" | ${KERNELGCC_ENV} make ${MAKE_FLAGS} oldconfig)
	$(call state,$@,kernel-gcc-build)

#############################################################################
kernel-build: state/kernel-build
state/kernel-build: ${TMPDIR} ${STATE_CLANG_TOOLCHAIN} ${STATE_TOOLCHAIN} state/kernel-configure
	@[ -d ${KERNEL_BUILD} ] || ($(call leavestate,${STATEDIR},kernel-configure) && ${MAKE} kernel-configure)
	@$(MAKE) kernel-quilt-link-patches
	@$(call banner,Building kernel with clang...)
	$(call make-kernel,${KERNELDIR},${KERNEL_ENV},CC="${CLANGCC}")
	@$(call banner,Successfully Built kernel with clang!)
	@$(call get-kernel-size,clang,${CLANG},${KERNEL_BUILD})
	$(call state,$@,done)

#############################################################################
kernel-gcc-build: state/kernel-gcc-build
state/kernel-gcc-build: ${TMPDIR} ${STATE_TOOLCHAIN} state/kernel-gcc-configure
	@[ -d ${KERNELGCC_BUILD} ] || ($(call leavestate,${STATEDIR},kernel-gcc-configure) && ${MAKE} kernel-gcc-configure)
	@$(MAKE) kernel-quilt-link-patches
	@$(call banner,Building kernel with gcc...)
#	(cd ${KERNELGCC} ; sed -i -e "s#-Qunused-arguments##g" Makefile)
#	(cd ${KERNELGCC} ; for ix in `git grep integrated-as | cut -d":" -f1 ` ; do sed -i -e "s#-no-integrated-as##g" $$ix ; done )
	@$(call make-kernel,${KERNELGCC},${KERNELGCC_ENV} ${SPARSE})
	@$(call get-kernel-size,gcc,${CROSS_GCC},${KERNELGCC_BUILD})
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
	@$(call banner,Building unpatched gcc kernel for eventual analysis with sparse...)
	@$(call unpatch,${KERNELGCC})
	${MAKE} kernel-gcc-build-force
	@$(call banner,Rebuilding patched gcc kernel with sparse (changed files only)...)
	@$(call patch,${KERNELGCC})
	${MAKE} SPARSE=C=1 kernel-gcc-build-force

#############################################################################
kernels: kernel-build kernel-gcc-build
kernels-sync: kernel-sync kernel-gcc-sync
kernels-clean: kernel-clean kernel-gcc-clean

#############################################################################
kernel-shared-sync:
	@$(call banner,Syncing shared kernel.org kernel...)
	@(cd ${SHARED_KERNEL} && git fetch origin +refs/heads/*:refs/heads/*)

#############################################################################
kernel-sync: state/kernel-fetch kernel-shared-sync kernel-clean
	@$(call banner,Syncing kernel...)
	@$(call check_llvmlinux_commit,${CONFIG})
	@$(call gitsync,${KERNELDIR},${KERNEL_COMMIT},${KERNEL_BRANCH},${KERNEL_TAG})

#############################################################################
kernel-gcc-sync: state/kernel-gcc-fetch kernel-sync kernel-gcc-clean
	@$(call banner,Syncing gcc kernel...)
	@$(call check_llvmlinux_commit,${CONFIG})
	@$(call gitsync,${KERNELGCC},${KERNEL_COMMIT},${KERNEL_BRANCH},${KERNEL_TAG})

#############################################################################
kernel-clean kernel-mrproper:
	@$(call makemrproper,${KERNELDIR})
	@rm -f ${LOGDIR}/*.log
	@$(call unpatch,${KERNELDIR})
	@$(call optional_gitreset,${KERNELDIR})
	@$(call leavestate,${STATEDIR},kernel-quilt kernel-patch kernel-configure kernel-build)
	@$(call banner,Clang compiled Kernel is now clean)

#############################################################################
kernel-gcc-clean kernel-gcc-mrproper:
	@$(call makemrproper,${KERNELGCC})
	@$(call unpatch,${KERNELGCC})
	@$(call optional_gitreset,${KERNELGCC})
	@$(call leavestate,${STATEDIR},kernel-gcc-configure kernel-gcc-patch kernel-gcc-build)
	@$(call banner,Gcc compiled Kernel is now clean)

#############################################################################
kernel-rebuild kernel-gcc-rebuild: kernel-%rebuild:
	@$(call leavestate,${STATEDIR},kernel-$*build)
	@$(MAKE) kernel-$*build

#############################################################################
kernel-rebuild-verbose kernel-gcc-rebuild-verbose: kernel-%rebuild-verbose:
	@$(call leavestate,${STATEDIR},kernel-$*build)
	@$(MAKE) JOBS=1 V=1 kernel-$*build

#############################################################################
kernel-version:
	@$(call get-kernel-version,${KERNELDIR})
kernel-gcc-version:
	@$(call get-kernel-version,${KERNELGCC})

#############################################################################
kernel-bisect-start: kernel-clean kernel-mrproper
	@(cd ${KERNELDIR} ; git bisect reset ; git bisect start ; git bisect bad ; git bisect good `git log --pretty=format:'%ai §%H' | grep ${KERNEL_BISECT_START_DATE} | head -1 | cut -d"§" -f2` )

kernel-bisect-skip: kernel-clean
	@(cd ${KERNELDIR} ; git bisect skip )

kernel-bisect-good: kernel-clean
	@(cd ${KERNELDIR} ; git bisect good )

kernel-bisect-bad: kernel-clean
	@(cd ${KERNELDIR} ; git bisect bad)

kernel-gcc-bisect: kernel-clean kernel-mrproper
	@(cd ${KERNELGCC} ; git bisect reset ; git bisect start ; git bisect bad ; git bisect good `git log --pretty=format:'%ai §%H' |

kernel-gcc-bisect-skip: kernel-clean
	@(cd ${KERNELGCC} ; git bisect skip )

kernel-gcc-bisect-good: kernel-clean
	@(cd ${KERNELGCC} ; git bisect good )

kernel-gcc-bisect-bad: kernel-clean
	@(cd ${KERNELGCC} ; git bisect bad)
#############################################################################
${TMPDIR}:
	@mkdir -p $@
tmp-clean:
	rm -rf ${TMPDIR}/*

#############################################################################
# The order of these includes is important
include ${TESTDIR}/test.mk
include ${TOOLSDIR}/tools.mk
