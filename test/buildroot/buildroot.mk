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

# Examples for ARM. Need to be set in your target Makefile before includes
BUILDROOT_ARCH		?= qemu_arm_vexpress
BUILDROOT_CONFIG	?= ${BUILDROOT_SRCDIR}/configs/${BUILDROOT_ARCH}_defconfig

BUILDROOT_SRCDIR	= ${BUILDROOTDIR}/src/buildroot
BUILDROOT_INSTALLDIR	= ${BUILDROOTDIR}/install
BUILDROOT_BUILDDIR	= $(subst ${TOPDIR},${BUILDROOT},${BUILDROOTDIR}/build/${BUILDROOT_ARCH})
BUILDROOT_STATE	= ${BUILDROOTDIR}/state
BUILDROOT_PATCHES	= ${BUILDROOTDIR}/patches

BUILDROOTBINDIR	= ${BUILDROOT_INSTALLDIR}/bin

BUILDROOT_TARGETS	= buildroot buildroot-[fetch,configure,build,clean,sync] buildroot-patch-applied buildroot-version

TARGETS_TEST		+= ${BUILDROOT_TARGETS}
CLEAN_TARGETS		+= buildroot-clean
FETCH_TARGETS		+= buildroot-fetch
HELP_TARGETS		+= buildroot-help
MRPROPER_TARGETS	+= buildroot-mrproper
PATCH_APPLIED_TARGETS	+= buildroot-patch-applied
RAZE_TARGETS		+= buildroot-raze
SETTINGS_TARGETS	+= buildroot-settings
SYNC_TARGETS		+= buildroot-sync
VERSION_TARGETS		+= buildroot-version

.PHONY:		${BUILDROOT_TARGETS}

BUILDROOT_GIT		= "http://git.buildroot.net/git/buildroot.git"
BUILDROOT_BRANCH	= "master"

buildroot-help:
	@echo
	@echo "These are the make targets for buildroot:"
	@echo "* make buildroot-[fetch,patch,configure,build,sync,clean]"

buildroot-settings:
	@echo "# buildroot settings"
	@$(call prsetting,BUILDROOT_BRANCH,${BUILDROOT_BRANCH})
	@$(call prsetting,BUILDROOT_TAG,${BUILDROOT_TAG})
	@$(call prsetting,BUILDROOT_GIT,${BUILDROOT_GIT})
	@$(call gitcommit,${BUILDROOT_SRCDIR},BUILDROOT_COMMIT)

buildroot-fetch: ${BUILDROOT_STATE}/buildroot-fetch
${BUILDROOT_STATE}/buildroot-fetch:
	@$(call banner, "Fetching buildroot...")
	@mkdir -p ${BUILDROOT_SRCDIR}
	$(call gitclone,${BUILDROOT_GIT} -b ${BUILDROOT_BRANCH},${BUILDROOT_SRCDIR})
	@[ -z "${BUILDROOT_COMMIT}" ] || $(call gitcheckout,${BUILDROOT_SRCDIR},${BUILDROOT_BRANCH},${BUILDROOT_COMMIT})
	$(call state,$@,buildroot-patch)

buildroot-patch: ${BUILDROOT_STATE}/buildroot-patch
${BUILDROOT_STATE}/buildroot-patch: ${BUILDROOT_STATE}/buildroot-fetch
	@$(call banner, "Patching buildroot...")
	@$(call patches_dir,${BUILDROOT_PATCHES},${BUILDROOT_SRCDIR}/patches)
	@$(call patch,${BUILDROOT_SRCDIR})
	$(call state,$@)
	@rm -f ${BUILDROOT_BUILDDIR}/buildroot-configure

buildroot-patch-applied: %-patch-applied:
	@$(call banner,"Patches applied for $*")
	@$(call applied,${BUILDROOT_SRCDIR})

buildroot-configure: ${BUILDROOT_BUILDDIR}/buildroot-configure
${BUILDROOT_BUILDDIR}/buildroot-configure: ${BUILDROOT_STATE}/buildroot-patch
	@$(call banner, "Configure buildroot...")
	@mkdir -p ${BUILDROOT_BUILDDIR}
	cp -v ${BUILDROOT_CONFIG} ${BUILDROOT_BUILDDIR}/.config
	echo "" | make -C ${BUILDROOT_SRCDIR} O=${BUILDROOT_BUILDDIR} oldconfig
	$(call state,$@,buildroot-build)

buildroot-menuconfig:
	make -C ${BUILDROOT_SRCDIR} O=${BUILDROOT_BUILDDIR} menuconfig

buildroot buildroot-build: ${BUILDROOT_BUILDDIR}/buildroot-build
${BUILDROOT_BUILDDIR}/buildroot-build: ${BUILDROOT_BUILDDIR}/buildroot-configure
	@[ -d ${BUILDROOT_BUILDDIR} ] || ($(call leavestate,${BUILDROOT_BUILDDIR},kernel-configure) && ${MAKE} kernel-configure)
	@$(call banner, "Building buildroot...")
	TOOLCHAINDIR=${TOOLCHAINDIR} make -C ${BUILDROOT_SRCDIR} O=${BUILDROOT_BUILDDIR} -j${JOBS}
	$(call state,$@)
	
buildroot-clean-all:
	@$(call banner, "Cleaning buildroot...")
	rm -rf ${BUILDROOT_BUILDDIR} ${BUILDROOT_INSTALLDIR}
	rm -f $(addprefix ${BUILDROOT_STATE}/,buildroot-patch)
	rm -f $(addprefix ${BUILDROOT_BUILDDIR}/,buildroot-configure buildroot-build)

buildroot-clean buildroot-mrproper: buildroot-clean-all ${BUILDROOT_STATE}/buildroot-fetch
	@$(call unpatch,${BUILDROOT_SRCDIR})
	@$(call optional_gitreset,${BUILDROOT_SRCDIR})
	
buildroot-raze: buildroot-clean-all
	@$(call banner, "Razing buildroot...")
	rm -rf ${BUILDROOT_SRCDIR}
	rm -f ${BUILDROOT_STATE}/buildroot-*
	rm -f ${BUILDROOT_BUILDDIR}/buildroot-*
	
buildroot-sync: ${BUILDROOT_STATE}/buildroot-fetch
	@$(call banner, "Updating buildroot...")
	@${MAKE} buildroot-clean
	@$(call check_llvmlinux_commit,${CONFIG})
	-@if [ -n "${BUILDROOT_COMMIT}" ] ; then \
		$(call banner, "Syncing commit-ish buildroot...") ; \
		$(call gitcheckout,${BUILDROOT_SRCDIR},${BUILDROOT_BRANCH},${BUILDROOT_COMMIT}) ; \
	else \
		$(call gitpull,${BUILDROOT_SRCDIR},${BUILDROOT_BRANCH}) ; \
	fi

buildroot-version: ${BUILDROOT_STATE}/buildroot-fetch
	@(cd ${BUILDROOT_SRCDIR} && echo "buildroot version `cat VERSION` commit `git rev-parse HEAD`")
