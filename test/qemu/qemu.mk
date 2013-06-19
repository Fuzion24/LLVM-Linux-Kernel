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

# Assumes has been included from ../test.mk

QEMUSRCDIR	= ${QEMUDIR}/src/qemu
QEMUINSTALLDIR	= ${QEMUDIR}/install
QEMUBUILDDIR	= $(subst ${TOPDIR},${BUILDROOT},${QEMUDIR}/build/qemu)
QEMUSTATE	= ${QEMUDIR}/state
QEMUPATCHES	= ${QEMUDIR}/patches

QEMUBINDIR	= ${QEMUINSTALLDIR}/bin

QEMU_TARGETS	= qemu qemu-[fetch,configure,build,clean,sync] qemu-patch-applied qemu-version

DEBDEP		+= libfdt-dev libglib2.0-dev libpixman-1-dev
RPMDEP		+= 

TARGETS_TEST		+= ${QEMU_TARGETS}
CLEAN_TARGETS		+= qemu-clean
FETCH_TARGETS		+= qemu-fetch
HELP_TARGETS		+= qemu-help
MRPROPER_TARGETS	+= qemu-mrproper
PATCH_APPLIED_TARGETS	+= qemu-patch-applied
RAZE_TARGETS		+= qemu-raze
SETTINGS_TARGETS	+= qemu-settings
SYNC_TARGETS		+= qemu-sync
VERSION_TARGETS		+= qemu-version

.PHONY:		${QEMU_TARGETS}

#QEMU_GIT	= "git://git.linaro.org/qemu/qemu-linaro.git"
QEMU_GIT	= "git://git.qemu.org/qemu.git"
#QEMU_BRANCH	= "stable-1.1"
QEMU_BRANCH	= "master"
#QEMU_COMMIT	= 6d6c9f59ca1b1a76ade7ad868bef191818f58819

qemu-help:
	@echo
	@echo "These are the make targets for QEMU:"
	@echo "* make qemu-[fetch,patch,configure,build,sync,clean]"

qemu-settings:
	@echo "# QEMU settings"
	@$(call prsetting,QEMU_BRANCH,${QEMU_BRANCH})
	@$(call prsetting,QEMU_TAG,${QEMU_TAG})
	@$(call prsetting,QEMU_GIT,${QEMU_GIT})
	@$(call gitcommit,${QEMUSRCDIR},QEMU_COMMIT)

qemu-fetch: ${QEMUSTATE}/qemu-fetch
${QEMUSTATE}/qemu-fetch:
	@$(call banner,Fetching QEMU...)
	@mkdir -p ${QEMUSRCDIR}
	$(call gitclone,${QEMU_GIT} -b ${QEMU_BRANCH},${QEMUSRCDIR})
	@[ -z "${QEMU_COMMIT}" ] || $(call gitcheckout,${QEMUSRCDIR},${QEMU_BRANCH},${QEMU_COMMIT})
	@(cd ${QEMUSRCDIR} ; git submodule update --init dtc )
	$(call state,$@,qemu-patch)

qemu-patch: ${QEMUSTATE}/qemu-patch
${QEMUSTATE}/qemu-patch: ${QEMUSTATE}/qemu-fetch
	@$(call banner,Patching QEMU...)
	@$(call patches_dir,${QEMUPATCHES},${QEMUSRCDIR}/patches)
	@$(call patch,${QEMUSRCDIR})
	$(call state,$@,qemu-configure)

qemu-patch-applied: %-patch-applied:
	@$(call banner,"Patches applied for $*")
	@$(call applied,${QEMUSRCDIR})

qemu-configure: ${QEMUSTATE}/qemu-configure
${QEMUSTATE}/qemu-configure: ${QEMUSTATE}/qemu-patch
	@make -s build-dep-check
	@$(call banner,Configure QEMU...)
	@mkdir -p ${QEMUBUILDDIR}
	(cd ${QEMUBUILDDIR} && ${QEMUSRCDIR}/configure \
		--target-list=arm-softmmu,i386-softmmu,x86_64-softmmu --disable-kvm --disable-vnc \
		--audio-drv-list="" --enable-fdt \
		--disable-docs --prefix=${QEMUINSTALLDIR})
	$(call state,$@,qemu-build)

qemu qemu-build: ${QEMUSTATE}/qemu-build
${QEMUSTATE}/qemu-build: ${QEMUSTATE}/qemu-configure
	@[ -d ${QEMUBUILDDIR} ] || ${MAKE} qemu-clean $^ # build in tmpfs
	@$(call banner,Building QEMU...)
	@mkdir -p ${QEMUINSTALLDIR}
	make -C ${QEMUBUILDDIR} -j${JOBS} install
	$(call state,$@)
	
qemu-clean-all:
	@$(call banner,Cleaning QEMU...)
	rm -rf ${QEMUBUILDDIR} ${QEMUINSTALLDIR} 
	rm -f $(addprefix ${QEMUSTATE}/,qemu-patch qemu-configure qemu-build)

qemu-clean qemu-mrproper: qemu-clean-all ${QEMUSTATE}/qemu-fetch
	@$(call unpatch,${QEMUSRCDIR})
	@$(call optional_gitreset,${QEMUSRCDIR})
	
qemu-raze: qemu-clean-all
	@$(call banner,Razing QEMU...)
	rm -rf ${QEMUSRCDIR}
	rm -f ${QEMUSTATE}/qemu-*
	
qemu-sync: ${QEMUSTATE}/qemu-fetch
	@$(call banner,Updating QEMU...)
	@${MAKE} qemu-clean
	@$(call check_llvmlinux_commit,${CONFIG})
	-@if [ -n "${QEMU_COMMIT}" ] ; then \
		$(call banner,Syncing commit-ish QEMU...) ; \
		$(call gitcheckout,${QEMUSRCDIR},${QEMU_BRANCH},${QEMU_COMMIT}) ; \
	else \
		$(call gitpull,${QEMUSRCDIR},${QEMU_BRANCH}) ; \
	fi

qemu-version: ${QEMUSTATE}/qemu-fetch
	@(cd ${QEMUSRCDIR} && echo "QEMU version `cat VERSION` commit `git rev-parse HEAD`")

QEMUOPTS	= -nographic ${GDB_OPTS}

# The runqemu command is called from the the specific <arch>.mk file with the appropriate arch specific param
# ${1}=qemu-system-<arch> ${2}=Machine_type ${3}=kernel ${4}=RAM ${5}=rootfs ${6}=Kernel_opts ${7}=QEMU_opts
runqemu = ${DRYRUN} ${1} -M ${2} -kernel ${3} -m ${4} -append "mem=${4}M root=${5} ${6}" ${7} ${QEMUOPTS}

