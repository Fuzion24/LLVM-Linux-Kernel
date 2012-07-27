##############################################################################
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

PATH		+= :${ARCH_ALL_BINDIR}:

MAINLINEURI	= git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
SHARED_KERNEL	= ${ARCH_ALL_DIR}/kernel.git

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

SRCDIR		= ${TARGETDIR}/src
LOGDIR		= ${TARGETDIR}/log
TMPDIR		= ${TARGETDIR}/tmp
STATEDIR	= ${TARGETDIR}/state
CHECKERDIR	= ${TARGETDIR}/checker

TMPDIRS		+= ${TMPDIR}

add_patches	= $(addprefix ${1}/,$(shell [ -f ${1}/series ] && cat ${1}/series))
KERNEL_PATCHES	+= $(call add_patches,${ARCH_ALL_PATCHES})

FILTERFILE	= ${TARGETDIR}/kernel-filter
TMPFILTERFILE	= ${TARGETDIR}/tmp/kernel-filter

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

TARGETS			+= ${KERNEL_TARGETS_CLANG} ${KERNEL_TARGETS_GCC} ${KERNEL_TARGETS_APPLIED} ${KERNEL_TARGETS_CLEAN}
SYNC_TARGETS		+= kernels-sync
PATCH_APPLIED_TARGETS	+= ${KERNEL_TARGETS_APPLIED}
CLEAN_TARGETS		+= ${KERNEL_TARGETS_CLEAN}
VERSION_TARGETS		+= ${KERNEL_TARGETS_VERSION}

.PHONY:			${KERNEL_TARGETS_CLANG} ${KERNEL_TARGETS_GCC} ${KERNEL_TARGETS_APPLIED} ${KERNEL_TARGETS_CLEAN} ${KERNEL_TARGETS_VERSION}

seperator = "---------------------------------------------------------------------"
banner	= ( echo ${seperator}; echo ${1}; echo ${seperator} )
state	= @mkdir -p $(dir ${1}) && touch ${1} \
	  && $(call banner,"Finished state $(notdir ${1})") \
	  && ( [ -d $(dir ${1})${2} ] || rm -f $(dir ${3})${2} )
error1	= ( echo Error: ${1}; false )
assert	= [ ${1} ] || $(call error1,${2})
#assert	= echo "${1} --> ${2}"

# The shared kernel is a bare repository of Linus' kernel.org kernel
# It serves as a git alternate for all the other target specific kernels
${SHARED_KERNEL}:
	git clone --bare ${MAINLINEURI} $@

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
	[ -d ${KERNELCOPY}/.git ] || git clone ${KERNELDIR} -b ${KERNEL_BRANCH} ${KERNELCOPY}
ifneq "${KERNEL_TAG}" ""
	( cd ${KERNELDIR} && git checkout ${KERNEL_TAG} )
endif
	$(call state,$@)

kernel-gcc-fetch: state/kernel-gcc-fetch
state/kernel-gcc-fetch: state/kernel-fetch
	@$(call banner, "Fetching kernel...")
	[ -d ${KERNELGCC}/.git ] || git clone ${KERNELDIR} -b ${KERNEL_BRANCH} ${KERNELGCC}
ifneq "${KERNEL_TAG}" ""
	( cd ${KERNELDIR} && git checkout ${KERNEL_TAG} )
endif
	$(call state,$@,kernel-gcc-patch)

kernel-patch: state/kernel-patch
state/kernel-patch: state/kernel-fetch
	@$(call banner, "Patching kernel...")
	@mkdir -p ${LOGDIR} ${TMPDIR}
	@$(call banner, "Checking for duplicated patches:")
	@${TOOLSDIR}/checkduplicates.py ${KERNEL_PATCHES}
	@echo "Testing upstream patches: see ${LOGDIR}/testpatch.log"
	@rm -f ${TMPDIR}/test.patch ${TMPFILTERFILE}-1 ${TMPFILTERFILE}-2 ${FILTERFILE}
	@for patch in ${KERNEL_PATCHES}; do cat $$patch >> ${TMPDIR}/test.patch; done
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

kernel-gcc-patch: state/kernel-gcc-patch
state/kernel-gcc-patch: state/kernel-gcc-fetch state/kernel-patch
	@$(call banner, "Fetching kernel (for gcc build)...")
	(cd ${KERNELGCC} && git reset --hard HEAD)
	@$(call banner, "Patching kernel source (gcc): see patch-gcc.log")
	(cd ${KERNELGCC} && patch -p1 -i ${TMPDIR}/final.patch > ${LOGDIR}/patch-gcc.log)
	$(call state,$@,kernel-gcc-configure)

${KERNEL_TARGETS_APPLIED}: %-patch-applied:
	@$(call banner,"Patches applied for $*")
	@( [ -d ${SRCDIR}/$* ] && cd ${SRCDIR}/$* && git status || echo "No patches applied" )

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
	(cd ${KERNELDIR} && git reset --hard HEAD)

kernel-gcc-reset: state/kernel-gcc-fetch
	(cd ${KERNELGCC} && git reset --hard HEAD)

kernel-mrproper: state/kernel-fetch
	(cd ${KERNELDIR} && make mrproper)

kernel-gcc-mrproper: state/kernel-gcc-fetch
	(cd ${KERNELGCC} && make mrproper)

kernel-clean-tmp:
	@rm -f $(addprefix ${TARGETDIR}/state/,kernel-patch kernel-configure kernel-build)
	@rm -f ${FILTERFILE} ${TMPFILTERFILE}-[12]
	@rm -f ${LOGDIR}/*.log
	@rm -f ${TMPDIR}/*.patch
	@$(call banner,"Clang compiled Kernel is now clean")

kernel-gcc-clean-tmp:
	@rm -f $(addprefix ${TARGETDIR}/state/,kernel-gcc-patch kernel-gcc-configure kernel-gcc-build)
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
state/kernel-build: ${LLVMSTATE}/clang-build state/kernel-configure
	$(call assert,-n "${MAKE_KERNEL}",MAKE_KERNEL undefined)
	@$(call banner,"Building kernel with clang...")
	(cd ${KERNELDIR} && time ${MAKE_KERNEL})
	@$(call banner,"Successfully Built kernel with clang!")
	@mkdir -p ${TOPLOGDIR}
	@( ${CLANG} --version | head -1 ; \
		cd ${KERNELDIR} && wc -c ${KERNEL_SIZE_ARTIFACTS} ) \
		| tee $(call sizelog,${TOPLOGDIR},clang)
	$(call state,$@,done)

kernel-gcc-build: state/cross-gcc state/kernel-gcc-build
state/kernel-gcc-build: ${CROSS_GCC} state/kernel-gcc-configure
	@$(call banner, "Building kernel with gcc...")
	(cd ${KERNELGCC} \
		&& export PATH=$(shell echo "${PATH}" | sed -e 's/ ://g') \
		&& time make -j${JOBS} ${MAKE_FLAGS} CROSS_COMPILE=${CROSS_COMPILE} \
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

get-kernel-version = [ ! -d ${1} ] || (cd ${1} && echo "src/$(notdir ${1}) version `make kernelversion | grep -v ^make` commit `git rev-parse HEAD`")

kernel-version:
	@$(call get-kernel-version,${KERNELDIR})

kernel-gcc-version:
	@$(call get-kernel-version,${KERNELGCC})

list-kernel-patches:
	@echo ${KERNEL_PATCHES} | sed 's/ /\n/g'

${TMPDIR}:
	@mkdir -p $@

tmp-clean:
	rm -rf ${TMPDIR}/*

KERNELOPTS	= console=earlycon console=ttyAMA0,38400n8 earlyprintk
QEMUOPTS	= -nographic ${GDB_OPTS}

# ${1}=qemu_bin ${2}=Machine_type ${3}=kernel ${4}=RAM ${5}=rootfs ${6}=Kernel_opts ${7}=QEMU_opts
runqemu = ${1} -M ${2} -kernel ${3} -m ${4} -append "mem=${4}M root=${5} ${6}" ${7}

# The order of these includes is important
include ${TESTDIR}/test.mk
include ${TOOLSDIR}/tools.mk
