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

export V
export CHECKERDIR

ARCH_ALL_DIR	= ${ARCHDIR}/all
ARCH_ALL_BINDIR	= ${ARCH_ALL_DIR}/bin
ARCH_ALL_PATCHES= ${ARCH_ALL_DIR}/patches

PATH		:= ${PATH}:${ARCH_ALL_BINDIR}

MAINLINEURI	= git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
SHARED_KERNEL	= ${ARCH_ALL_DIR}/kernel.git

ifeq "${KERNEL_GIT}" ""
KERNEL_GIT	= ${MAINLINEURI}
endif
ifeq "${KERNEL_BRANCH}" ""
KERNEL_BRANCH	= master
endif
ifeq "${KERNEL_REPO_PATCHES}" ""
KERNEL_REPO_PATCHES = ${KERNEL_BRANCH}
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

catfile		= ([ -f ${1} ] && cat ${1})
add_patches	= $(addprefix ${1}/,$(shell $(call catfile,${1}/series.target) || $(call catfile,${1}/series)))
KERNEL_PATCHES	+= $(call add_patches,${ARCH_ALL_PATCHES})
KERNEL_PATCH_DIR+= ${ARCH_ALL_PATCHES} ${ARCH_ALL_PATCHES}/${KERNEL_REPO_PATCHES}

FILTERFILE	= ${TARGETDIR}/kernel-filter
TMPFILTERFILE	= ${TMPDIR}/kernel-filter

# ${1}=logdir ${2}=toolchain ${3}=testname
sizelog	= ${1}/${2}-${ARCH}-`date +%Y-%m-%d_%H:%M:%S`-kernel-size.log

KERNEL_SIZE_CLANG_LOG	= clang-`date +%Y-%m-%d_%H:%M:%S`-kernel-size.log
KERNEL_SIZE_GCC_LOG	= gcc-`date +%Y-%m-%d_%H:%M:%S`-kernel-size.log

# The ARCH makefile must provide the following:
#   - KERNEL_PATCHES+=... Additional arch specific patch file(s)
#   - MAKE_FLAGS
#   - MAKE_KERNEL
#   
# The target makefile must provide the following:
#   - KERNEL_PATCHES+=... Additional target specific patch file(s)
#   - KERNEL_CFG

KERNEL_TARGETS_CLANG	= kernel-fetch kernel-patch kernel-configure kernel-build kernel-sync
KERNEL_TARGETS_GCC	= kernel-gcc-fetch kernel-gcc-patch kernel-gcc-configure kernel-gcc-build kernel-gcc-sync
KERNEL_TARGETS_APPLIED	= kernel-patch-applied kernel-gcc-patch-applied
KERNEL_TARGETS_CLEAN	= kernel-clean kernel-gcc-clean tmp-clean
KERNEL_TARGETS_VERSION	= kernel-version kernel-gcc-version
KERNEL_TARGETS_LIST	= list-kernel-patches list-kernel-maintainer

TARGETS			+= ${KERNEL_TARGETS_CLANG} ${KERNEL_TARGETS_GCC} ${KERNEL_TARGETS_APPLIED} ${KERNEL_TARGETS_CLEAN} ${KERNEL_TARGETS_LIST}
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

kernel-help:
	@echo
	@echo "* make kernel-[fetch,patch,configure,build,sync,clean]"
	@echo "* make kernel-gcc-[fetch,patch,configure,build,sync,clean]"
	@echo "* make kernels		- build kernel with both clang and gcc"
	@echo "* make list-kernel-patches"
	@echo "			- List which kernel patches will be applied"
	@echo "* make list-kernel-maintainer"
	@echo "			- List which kernel maintainers should be contacted for each patch"

kernel-settings:
	@echo "# Kernel settings"
	@echo "KERNEL_GIT		= ${KERNEL_GIT}"
	@echo "KERNEL_BRANCH		= ${KERNEL_BRANCH}"
	@echo "KERNELDIR		= ${KERNELDIR}"
	@echo "KERNELGCC		= ${KERNELGCC}"

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

kernel-raze:
	@$(call banner,Razing kernel)
	@rm -rf ${SHARED_KERNEL} ${KERNELDIR} ${KERNELCOPY} ${KERNELGCC}
	@rm -f $(addsuffix /*,${LOGDIR} state ${TMPDIR})

kernel-fetch: state/kernel-fetch
state/kernel-fetch: ${SHARED_KERNEL}
	@mkdir -p ${SRCDIR}
	[ -d ${KERNELDIR}/.git ] || git clone --reference $< ${KERNEL_GIT} -b ${KERNEL_BRANCH} ${KERNELDIR}
ifneq "${KERNEL_TAG}" ""
	( cd ${KERNELDIR} && ( [ -f ${KERNELDIR}/.git/refs/heads/${KERNEL_TAG} ] || git checkout -b ${KERNEL_TAG} ${KERNEL_TAG} ))
	( cd ${KERNELDIR} && git checkout -f ${KERNEL_TAG} )
endif
	$(call state,$@,kernel-patch)

kernel-copy: state/kernel-copy
state/kernel-copy: state/kernel-fetch
	@$(call banner, "Copying kernel...")
	[ -d ${KERNELCOPY}/.git ] || git clone ${KERNELDIR} ${KERNELCOPY}
ifneq "${KERNEL_TAG}" ""
	( cd ${KERNELDIR} && git checkout ${KERNEL_TAG} )
endif
ifneq "${KERNEL_BRANCH}" ""
	( cd ${KERNELDIR} && git checkout -B ${KERNEL_BRANCH} )
endif
	$(call state,$@)

kernel-gcc-fetch: state/kernel-gcc-fetch
state/kernel-gcc-fetch: state/kernel-fetch
	@$(call banner, "Fetching kernel...")
	[ -d ${KERNELGCC}/.git ] || git clone ${KERNELDIR} ${KERNELGCC}
ifneq "${KERNEL_TAG}" ""
	( cd ${KERNELDIR} && git checkout ${KERNEL_TAG} )
endif
ifneq "${KERNEL_BRANCH}" ""
	( cd ${KERNELDIR} && git checkout -B ${KERNEL_BRANCH} )
endif
	$(call state,$@,kernel-gcc-patch)

kernel-patch-old: state/kernel-patch-old
state/kernel-patch-old: state/kernel-fetch
	@$(call banner, "Patching kernel...")
	@mkdir -p ${LOGDIR} ${TMPDIR}
	@$(call banner, "Checking for duplicated patches:")
	@${TOOLSDIR}/checkduplicates.py ${KERNEL_PATCHES}
	@echo "Testing upstream patches: see ${LOGDIR}/testpatch.log"
	@rm -f ${TMPDIR}/test.patch ${TMPFILTERFILE}-1 ${TMPFILTERFILE}-2 ${FILTERFILE}
	for patch in ${KERNEL_PATCHES}; do \
		perl -ne '$$notheader=1 if /^(diff|Index: )/; print if $$notheader;' $$patch >> ${TMPDIR}/test.patch ; \
	done
	(cd ${KERNELDIR} && git reset --hard HEAD)
	@make -i patch-dry-run1
	@$(call banner, "Creating patch filter: see ${LOGDIR}/filteredpatch.log")
	@${TOOLSDIR}/genfilter.py ${LOGDIR}/testpatch.log ${TMPFILTERFILE}-1
	@${TOOLSDIR}/applyfilter.py ${TMPDIR}/test.patch ${TMPDIR}/filtered.patch ${TMPFILTERFILE}-1
	@$(call banner,"Testing for missed and unapplied patches: see ${LOGDIR}/filteredpatch.log")
	@make -i patch-dry-run2
	@${TOOLSDIR}/genfilter.py ${LOGDIR}/filteredpatch.log ${TMPFILTERFILE}-2
	@$(call banner, "Creating final patch: see ${LOGDIR}/filteredpatch.log")
	@cat ${TMPFILTERFILE}-1 ${TMPFILTERFILE}-2 > ${FILTERFILE}
	@${TOOLSDIR}/applyfilter.py ${TMPDIR}/test.patch ${TMPDIR}/final.patch ${FILTERFILE}
	@$(call banner, "Patching kernel source: see patch.log")
	(cd ${KERNELDIR} && patch -p1 -i ${TMPDIR}/final.patch > ${LOGDIR}/patch.log)
	$(call state,$@,kernel-configure)

kernel-gcc-patch-old: state/kernel-gcc-patch-old
state/kernel-gcc-patch-old: state/kernel-gcc-fetch state/kernel-patch-old
	@$(call banner, "Fetching kernel (for gcc build)...")
	(cd ${KERNELGCC} && git reset --hard HEAD)
	@$(call banner, "Patching kernel source (gcc): see patch-gcc.log")
	(cd ${KERNELGCC} && patch -p1 -i ${TMPDIR}/final.patch > ${LOGDIR}/patch-gcc.log)
	$(call state,$@,kernel-gcc-configure)

kernel-quilt: state/kernel-quilt
state/kernel-quilt: state/kernel-fetch
	@$(call banner, "Quilting kernel...")
	@mkdir -p ${PATCHDIR}
# Update series file
	@[ -f ${PATCHDIR}/series ] || touch ${PATCHDIR}/series
	@[ -e ${PATCHDIR}/series.target ] || mv ${PATCHDIR}/series ${PATCHDIR}/series.target
# Append any new patches from the generated series file into series.target
	@diff ${PATCHDIR}/series ${PATCHDIR}/series.target \
		| perl -ne 'print "$$1\n" if $$hunk>1 && /^< (.*)$$/; $$hunk++ if /^[^<>]/' \
		>> ${PATCHDIR}/series.target
# Remove broken symbolic links to old patches
	@[ -d ${PATCHDIR} ] && file ${PATCHDIR}/* | awk -F: '/broken symbolic link to/ {print $$1}' | xargs --no-run-if-empty rm
# Have git ignore extra patch files
	@echo .gitignore > ${PATCHDIR}/.gitignore
	@echo series >> ${PATCHDIR}/.gitignore
# Collect patch files and build new series file
	@for DIR in ${KERNEL_PATCH_DIR} ; do \
		[ -f $$DIR/series.target ] && cat $$DIR/series.target \
			|| [ ! -f $$DIR/series ] || cat $$DIR/series ; \
	done > ${PATCHDIR}/series
# Move updated patches back to their proper place, and link patch files into target patch dir
	@REVDIRS=`for DIR in ${KERNEL_PATCH_DIR} ; do echo $$DIR; done | tac`; \
	for PATCH in `cat ${PATCHDIR}/series` ; do \
		egrep -q ^$$PATCH$$ ${PATCHDIR}/series.target && continue ; \
		echo $$PATCH >> ${PATCHDIR}/.gitignore ; \
		PATCHLINK="${PATCHDIR}/$$PATCH" ; \
		for DIR in $$REVDIRS ; do \
			if [ -f "$$DIR/$$PATCH" -a ! -L "$$DIR/$$PATCH" ] ; then \
				if [ -f "$$PATCHLINK" -a ! -L "$$PATCHLINK" ] ; then \
					mv -v "$$PATCHLINK" "$$DIR/$$PATCH" ; \
				fi ; \
				ln -fsv "$$DIR/$$PATCH" "$$PATCHLINK" ; \
				break; \
			fi ; \
		done ; \
	done | sed -e 's|${TARGETDIR}|.|g; s|${TOPDIR}|...|g'
# Add patches dir to kernel src
	@[ -e ${KERNELDIR}/patches ] || ln -s ${PATCHDIR} ${KERNELDIR}/patches
	$(call state,$@,kernel-patch)

list-kernel-patches: kernel-quilt
	@REVDIRS=`for DIR in ${KERNEL_PATCH_DIR} ; do echo $$DIR; done | tac`; \
	for PATCH in `cat ${PATCHDIR}/series` ; do \
		for DIR in $$REVDIRS ; do \
			if [ -f "$$DIR/$$PATCH" -a ! -L "$$DIR/$$PATCH" ] ; then \
				echo "$$DIR/$$PATCH" ; \
				break; \
			fi ; \
		done ; \
	done

kernel-quilt-clean:
	@rm -f state/kernel-quilt
	$(MAKE) kernel-quilt
	@for FILE in ${PATCHDIR}/* ; do \
		[ ! -L $$FILE ] || rm $$FILE; \
	done
	@[ ! -f ${PATCHDIR}/series.target ] || rm -f ${PATCHDIR}/series
	@rm -f ${PATCHDIR}/.gitignore
	@rm -f state/kernel-quilt
	@$(call banner,Quilting cleaned)

kernel-patch: state/kernel-patch
state/kernel-patch: state/kernel-fetch
	${MAKE} state/kernel-quilt
	@[ -e ${KERNELDIR}/patches ] || ln -s ${PATCHDIR} ${KERNELDIR}/patches
	@$(call banner, "Patching kernel...")
	@$(call patch,${KERNELDIR})
	$(call state,$@,kernel-configure)

kernel-gcc-patch: state/kernel-gcc-patch
state/kernel-gcc-patch: state/kernel-gcc-fetch
	${MAKE} state/kernel-quilt
	@[ -e ${KERNELGCC}/patches ] || ln -s ${PATCHDIR} ${KERNELGCC}/patches
	@$(call banner, "Patching gcc kernel...")
#	(cd ${KERNELGCC} && quilt unapplied && quilt push -a)
	@$(call patch,${KERNELGCC})
	$(call state,$@,kernel-gcc-configure)

kernel-patch-applied:
	@$(call banner,"Patches applied for Clang kernel")
	@$(call applied,${KERNELDIR})
#	@( [ -d ${KERNELDIR} ] && cd ${KERNELDIR} && git status || echo "No patches applied" )

kernel-gcc-patch-applied:
	@$(call banner,"Patches applied for gcc kernel")
	@$(call applied,${KERNELGCC})

kernel-autopatch: kernel-build state/kernel-copy
	(cd ${KERNELCOPY} && git reset --hard HEAD && git pull)
	(cd ${KERNELCOPY} &&  patch -p1 -i ${TMPDIR}/final.patch >> ${LOGDIR}/patchcopy.log)
	@${TOOLSDIR}/unusedfix.py ${LOGDIR}/build.log ${KERNELCOPY} 
	(cd ${KERNELCOPY} &&  patch -R -p1 -i ${TMPDIR}/final.patch >> ${LOGDIR}/patchcopy.log)
	(cd ${KERNELCOPY} && git diff > ${TMPDIR}/autopatch.patch)
	@${TOOLSDIR}/splitarch.py ${TMPDIR}/autopatch.patch ${TARGETDIR} autopatch
	$(call state,$@)

patch-dry-run1:
	@rm -f ${LOGDIR}/testpatch.log
	(cd ${KERNELDIR} && patch --dry-run -p1 -i ${TMPDIR}/test.patch > ${LOGDIR}/testpatch.log)

patch-dry-run2:
	@rm -f ${LOGDIR}/filteredpatch.log
	(cd ${KERNELDIR} && patch --dry-run -p1 -i ${TMPDIR}/filtered.patch > ${LOGDIR}/filteredpatch.log)

kernel-reset: state/kernel-fetch
	${MAKE} -C ${KERNELDIR} clean
	@$(call unpatch,${KERNELDIR})
	@(cd ${KERNELDIR} && git reset --hard HEAD && git clean -d -f) || true
	@rm -f $(addprefix ${STATEDIR}/,kernel-patch kernel-quilt kernel-configure kernel-build )

kernel-gcc-reset: state/kernel-gcc-fetch
	${MAKE} -C ${KERNELGCC} clean
	@$(call unpatch,${KERNELGCC})
	@(cd ${KERNELGCC} && [ ! -d patches ] && git reset --hard HEAD && git clean -d -f) || true
	@rm -f $(addprefix ${STATEDIR}/,kernel-gcc-configure kernel-gcc-patch kernel-gcc-build)

kernel-mrproper: state/kernel-fetch
	(cd ${KERNELDIR} && make mrproper)
	@rm -f $(addprefix ${STATEDIR}/,kernel-build)

kernel-gcc-mrproper: state/kernel-gcc-fetch
	(cd ${KERNELGCC} && make mrproper)
	@rm -f $(addprefix ${STATEDIR}/,kernel-gcc-build)

kernel-clean-tmp:
	@rm -f $(addprefix ${STATEDIR}/,kernel-quilt kernel-patch kernel-configure kernel-build)
	@rm -f ${FILTERFILE} ${TMPFILTERFILE}-[12]
	@rm -f ${LOGDIR}/*.log
	@rm -f ${TMPDIR}/*.patch
	@$(call banner,"Clang compiled Kernel is now clean")

kernel-gcc-clean-tmp:
	@rm -f $(addprefix ${STATEDIR}/,kernel-gcc-patch kernel-gcc-configure kernel-gcc-build)
	@$(call banner,"Gcc compiled Kernel is now clean")

kernel-clean: kernel-reset kernel-clean-tmp
kernel-clean-noreset: kernel-mrproper kernel-clean-tmp

kernel-gcc-clean: kernel-gcc-reset kernel-gcc-clean-tmp
kernel-gcc-clean-noreset: kernel-gcc-mrproper kernel-gcc-clean-tmp

kernel-configure: state/kernel-configure
state/kernel-configure: state/kernel-patch
	@$(call banner, "Configuring kernel...")
	@cp ${KERNEL_CFG} ${KERNELDIR}/.config
	(cd ${KERNELDIR} && echo "" | make ${MAKE_FLAGS} oldconfig)
	$(call state,$@,kernel-build)

kernel-gcc-configure: state/kernel-gcc-configure
state/kernel-gcc-configure: state/kernel-gcc-patch
	@$(call banner, "Configuring kernel (for gcc build)...")
	@cp ${KERNEL_CFG} ${KERNELGCC}/.config
	@echo "CONFIG_ARM_UNWIND=y" >> ${KERNELGCC}/.config
	(cd ${KERNELGCC} && echo "" | make ${MAKE_FLAGS} oldconfig)
	$(call state,$@,kernel-gcc-build)

kernel-build: state/kernel-build
state/kernel-build: ${LLVMSTATE}/clang-build ${STATE_TOOLCHAIN} state/kernel-configure
	$(call assert,-n "${MAKE_KERNEL}",MAKE_KERNEL undefined)
	@$(call banner,"Building kernel with clang...")
	(cd ${KERNELDIR} && time ${MAKE_KERNEL})
	@$(call banner,"Successfully Built kernel with clang!")
	@mkdir -p ${TOPLOGDIR}
	@( ${CLANG} --version | head -1 ; \
		cd ${KERNELDIR} && wc -c ${KERNEL_SIZE_ARTIFACTS} ) \
		| tee $(call sizelog,${TOPLOGDIR},clang)
	$(call state,$@,done)

kernel-gcc-build: ${STATE_TOOLCHAIN} state/kernel-gcc-build
state/kernel-gcc-build: ${CROSS_GCC} state/kernel-gcc-configure
	@$(call banner, "Building kernel with gcc...")
	(cd ${KERNELGCC} \
		&& export PATH=$(shell echo "${PATH}" | sed -e 's/ ://g') \
		&& time make -j${JOBS} ${MAKE_FLAGS} CROSS_COMPILE=${CROSS_COMPILE} CC=${GCC_CC} \
	)
	@mkdir -p ${TOPLOGDIR}
	( ${CROSS_GCC} --version | head -1 ; \
		cd ${KERNELGCC} && wc -c ${KERNEL_SIZE_ARTIFACTS}) \
		| tee $(call sizelog,${TOPLOGDIR},gcc)
	$(call state,$@,done)

kernels: kernel-build kernel-gcc-build
kernels-sync: kernel-sync kernel-gcc-sync
kernels-clean: kernel-clean kernel-gcc-clean

kernel-shared-sync:
	@$(call banner, "Syncing shared kernel.org kernel...")
	(cd ${SHARED_KERNEL} && git fetch origin +refs/heads/*:refs/heads/*)

kernel-sync: state/kernel-fetch kernel-shared-sync kernel-clean
	@$(call banner, "Syncing kernel...")
	(cd ${KERNELDIR} && git pull)

kernel-gcc-sync: state/kernel-gcc-fetch kernel-shared-sync kernel-gcc-clean
	@$(call banner, "Syncing gcc kernel...")
	@(cd ${KERNELGCC} && git pull)

get-kernel-version = [ ! -d ${1} ] || (cd ${1} && echo "src/$(notdir ${1}) version `make kernelversion 2>/dev/null | grep -v ^make` commit `git rev-parse HEAD`")

kernel-version:
	@$(call get-kernel-version,${KERNELDIR})

kernel-gcc-version:
	@$(call get-kernel-version,${KERNELGCC})

list-kernel-patches-old:
	@echo ${KERNEL_PATCHES} | sed 's/ /\n/g'

list-kernel-maintainer: state/kernel-quilt
	@$(call banner,Finding maintainers for patches)
	@(cd ${KERNELDIR} && for PATCH in ${KERNEL_PATCHES}; do \
		$(call banner,$$PATCH) ; \
		./scripts/get_maintainer.pl $$PATCH ; \
	done)

${TMPDIR}:
	@mkdir -p $@

tmp-clean:
	rm -rf ${TMPDIR}/*

# The order of these includes is important
include ${TESTDIR}/test.mk
include ${TOOLSDIR}/tools.mk
