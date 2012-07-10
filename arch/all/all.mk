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

# NOTE: MAKE_KERNEL and/or MAKE_DEVKERNEL must also be defined in the calling 
#       Makefile

ARCHALLDIR	= ${ARCHDIR}/all
ARCHALLBINDIR	= ${ARCHALLDIR}/bin
ARCHALLPATCHES	= ${ARCHALLDIR}/patches

PATH		+= :${ARCHALLBINDIR}:

MAINLINEURI	= git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
LOCALKERNEL	= ${ARCHALLDIR}/kernel

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

add_patches	= $(addprefix ${1}/,$(shell [ -f ${1}/series ] && cat ${1}/series))
KERNEL_PATCHES	+= $(call add_patches,${ARCHALLPATCHES})

FILTERFILE	= ${TARGETDIR}/kernel-filter
TMPFILTERFILE	= ${TARGETDIR}/tmp/kernel-filter
SYNC_TARGETS	+= kernel-sync
LOG_OUTPUT	= 2>&1 | tee ${LOGDIR}/build.log

KERNEL_SIZE_ARTIFACTS	= arch/arm/boot/zImage vmlinux*

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

TARGETS	+= kernel-fetch kernel-patch kernel-configure kernel-build kernel-sync
TARGETS	+= kernel-gcc-fetch kernel-gcc-patch kernel-gcc-configure kernel-gcc-build kernel-gcc-sync

.PHONY: kernel-fetch kernel-patch kernel-configure kernel-build
.PHONY: kernel-gcc-fetch kernel-gcc-patch kernel-gcc-configure kernel-gcc-build

state	= @mkdir -p $(dir ${1}) && touch ${1};

${LOCALKERNEL}:
	git clone ${MAINLINEURI} $@

kernel-fetch: state/kernel-fetch
state/kernel-fetch: ${LOCALKERNEL}
	@mkdir -p ${SRCDIR}
	[ -d ${KERNELDIR}/.git ] || git clone --reference $< ${KERNEL_GIT} -b ${KERNEL_BRANCH} ${KERNELDIR}
	$(call state,$@)

kernel-copy: state/kernel-copy
state/kernel-copy: state/kernel-fetch
	[ -d ${KERNELCOPY}/.git ] || git clone ${KERNELDIR} -b ${KERNEL_BRANCH} ${KERNELCOPY}
	$(call state,$@)

kernel-gcc-fetch: state/kernel-gcc-fetch
state/kernel-gcc-fetch: state/kernel-fetch
	[ -d ${KERNELGCC}/.git ] || git clone ${KERNELDIR} -b ${KERNEL_BRANCH} ${KERNELGCC}
	$(call state,$@)

kernel-patch: state/kernel-patch
state/kernel-patch: state/kernel-fetch
	@mkdir -p ${LOGDIR} ${TMPDIR}
	@${TOOLSDIR}/banner.sh "Checking for duplicated patches:"
	@${TOOLSDIR}/checkduplicates.py ${KERNEL_PATCHES}
	@echo "Testing upstream patches: see ${LOGDIR}/testpatch.log"
	@rm -f ${TMPDIR}/test.patch ${TMPFILTERFILE}-1 ${TMPFILTERFILE}-2 ${FILTERFILE}
	@for patch in ${KERNEL_PATCHES}; do cat $$patch >> ${TMPDIR}/test.patch; done
	(cd ${KERNELDIR} && git reset --hard HEAD)
	@make -i patch-dry-run1
	@${TOOLSDIR}/banner.sh "Creating patch filter: see ${LOGDIR}/filteredpatch.log"
	@${TOOLSDIR}/genfilter.py ${LOGDIR}/testpatch.log ${TMPFILTERFILE}-1
	@${TOOLSDIR}/applyfilter.py ${TMPDIR}/test.patch ${TMPDIR}/filtered.patch ${TMPFILTERFILE}-1
	@${TOOLSDIR}/banner.sh "Testing for missed, unapplied patches: see ${LOGDIR}/filteredpatch.log"
	@make -i patch-dry-run2
	@${TOOLSDIR}/genfilter.py ${LOGDIR}/filteredpatch.log ${TMPFILTERFILE}-2
	@${TOOLSDIR}/banner.sh "Creating final patch: see ${LOGDIR}/filteredpatch.log"
	@cat ${TMPFILTERFILE}-1 ${TMPFILTERFILE}-2 > ${FILTERFILE}
	@${TOOLSDIR}/applyfilter.py ${TMPDIR}/test.patch ${TMPDIR}/final.patch ${FILTERFILE}
	@${TOOLSDIR}/banner.sh "Patching kernel source: see patch.log"
	(cd ${KERNELDIR} && patch -p1 -i ${TMPDIR}/final.patch > ${LOGDIR}/patch.log)
	$(call state,$@)

kernel-gcc-patch: state/kernel-gcc-patch
state/kernel-gcc-patch: state/kernel-gcc-fetch state/kernel-patch
	(cd ${KERNELGCC} && git reset --hard HEAD)
	@${TOOLSDIR}/banner.sh "Patching kernel source (gcc): see patch-gcc.log"
	(cd ${KERNELGCC} && patch -p1 -i ${TMPDIR}/final.patch > ${LOGDIR}/patch-gcc.log)
	$(call state,$@)

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
	@rm -f ${TARGETDIR}/state/kernel-patch
	@rm -f ${TARGETDIR}/state/kernel-configure
	@rm -f ${TARGETDIR}/state/kernel-build
	@rm -f ${FILTERFILE}
	@rm -f ${TMPFILTERFILE}-1
	@rm -f ${TMPFILTERFILE}-2
	@rm -f ${LOGDIR}/*.log
	@rm -f ${TMPDIR}/*.patch

kernel-gcc-clean-tmp:
	@rm -f ${TARGETDIR}/state/kernel-gcc-patch
	@rm -f ${TARGETDIR}/state/kernel-gcc-configure
	@rm -f ${TARGETDIR}/state/kernel-gcc-build

kernel-clean: kernel-reset kernel-clean-tmp
kernel-clean-noreset: kernel-mrproper kernel-clean-tmp

kernel-gcc-clean: kernel-gcc-reset kernel-gcc-clean-tmp
kernel-gcc-clean-noreset: kernel-gcc-mrproper kernel-gcc-clean-tmp

kernel-configure: state/kernel-configure
state/kernel-configure: state/kernel-patch
	@cp ${KERNEL_CFG} ${KERNELDIR}/.config
	(cd ${KERNELDIR} && echo "" | make ${MAKE_FLAGS} oldconfig)
	$(call state,$@)

kernel-gcc-configure: state/kernel-gcc-configure
state/kernel-gcc-configure: state/kernel-gcc-patch
	@cp ${KERNEL_CFG} ${KERNELGCC}/.config
	@echo "CONFIG_ARM_UNWIND=y" >> ${KERNELGCC}/.config
	(cd ${KERNELGCC} && echo "" | make ${MAKE_FLAGS} oldconfig)
	$(call state,$@)

kernel-build: state/kernel-build
state/kernel-build: ${LLVMSTATE}/clang-build state/kernel-configure
	@test -n "${MAKE_KERNEL}" || (echo "Error: MAKE_KERNEL undefined" && false)
	@${TOOLSDIR}/banner.sh "Building kernel with clang..."
	(cd ${KERNELDIR} && ${MAKE_KERNEL} ${LOG_OUTPUT} )
	@mkdir -p ${TOPLOGDIR}
	( ${CLANG} --version | head -1 ; \
		cd ${KERNELDIR} && wc -c ${KERNEL_SIZE_ARTIFACTS}) \
		| tee $(call sizelog,${TOPLOGDIR},clang)
	$(call state,$@)

kernel-gcc-build: state/cross-gcc state/kernel-gcc-build
state/kernel-gcc-build: ${CROSS_GCC} state/kernel-gcc-configure
	@${TOOLSDIR}/banner.sh "Building kernel with gcc..."
	(cd ${KERNELGCC} \
		&& export PATH=$(shell echo "${PATH}" | sed -e 's/ ://g') \
		&& make -j${JOBS} ${MAKE_FLAGS} CROSS_COMPILE=${CROSS_COMPILE} \
	)
	@mkdir -p ${TOPLOGDIR}
	( ${CROSS_GCC} --version | head -1 ; \
		cd ${KERNELGCC} && wc -c ${KERNEL_SIZE_ARTIFACTS}) \
		| tee $(call sizelog,${TOPLOGDIR},gcc)
	$(call state,$@)

kernels: kernel-build kernel-gcc-build
kernels-clean: kernel-clean kernel-gcc-clean

kernel-sync: state/kernel-fetch
	@make kernel-clean
	@[ -d ${LOCALKERNEL} ] && (cd ${LOCALKERNEL} && git pull)
	(cd ${KERNELDIR} && git pull)
	-(cd ${KERNELGCC} && git pull)

sync-all:
	@for t in ${SYNC_TARGETS}; do make $$t; done

list-targets:
	@echo "List of available make targets:"
	@(for t in ${TARGETS}; do echo $$t; done)

list-kernel-patches:
	@echo ${KERNEL_PATCHES} | sed 's/ /\n/g'

list-path:
	@echo ${PATH}
	
# ${1}=qemu_bin ${2}=Machine_type ${3}=kerneldir ${4}=RAM ${5}=rootfs ${6}=Kernel_opts ${7}=QEMU_opts
runqemu = ${1} -M ${2} -kernel ${3}/arch/arm/boot/zImage -m ${4} -append "mem=${4}M root=${5} ${6}" ${7}
