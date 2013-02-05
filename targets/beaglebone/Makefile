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

# This is a template file with the kinds of settings and make targets filled in.
# Those settings with defaults are commented out.
# Delete make targets you don't need.

TARGETDIR	= ${CURDIR}
TOPDIR		= $(realpath ${TARGETDIR}/../..)

ARCH		= arm
BOARD		= beaglebone

# Kernel settings
BBONE_GIT		= https://github.com/beagleboard/kernel.git
BBONE_BRANCH		= 3.7
BBONE_DIR		= ${TARGETDIR}/src/bbone
#KERNEL_GIT		= git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
#KERNEL_BRANCH		= master
#KERNEL_TAG		= 
KERNELDIR		= ${BBONE_DIR}/kernel
KERNELGCC		= ${BBONE_DIR}-gcc/kernel
KERNEL_CFG		= ${BBONE_DIR}/configs/beaglebone
#KERNEL_REPO_PATCHES	= master
KERNEL_MAKE_TARGETS	= uImage dtbs
#EXTRAFLAGS		=

# Arm specific
#MARCH			= armv7-a
#MARCH			= armv6
#MFLOAT			= -mfloat-abi=hard -mfpu=vfp
# EXTRAFLAGS isn't used anymore
EXTRAFLAGS		= -mcpu=cortex-a8

BOARD_TARGETS		= beaglebone-clean beaglebone-help beaglebone-fetch \
				beaglebone-mrproper beaglebone-raze beaglebone-settings \
				beaglebone-sync clean mrproper
TARGETS			+= ${BOARD_TARGETS}
CLEAN_TARGETS		+= beaglebone-clean
HELP_TARGETS		+= beaglebone-help
FETCH_TARGETS		+= beaglebone-fetch
MRPROPER_TARGETS	+= beaglebone-mrproper
RAZE_TARGETS		+= beaglebone-raze
SETTINGS_TARGETS	+= beaglebone-settings
SYNC_TARGETS		+= beaglebone-sync
.PHONY:			${BOARD_TARGETS} clean mrproper

all: prep beaglebone-fetch kernel-build

include ${TOPDIR}/common.mk
include ${ARCHDIR}/${ARCH}/${ARCH}.mk
include ${CONFIG}

export REFREPO
REFREPO			= ${SHARED_KERNEL}

KERNEL_PATCH_DIR	+= ${PATCHDIR} ${PATCHDIR}/${KERNEL_REPO_PATCHES}
prep: state/prep
state/prep:
	@mkdir -p ${LOGDIR} ${TMPDIR}
	$(call state,$@)

beaglebone-help:
	@echo "targets/${BOARD} has these options:"
	@echo
	@echo "* make <your make target here>	- Description"

beaglebone-settings:
	@$(call prsetting,FOO,${FOO})

beaglebone-fetch: state/beaglebone-fetch
state/beaglebone-fetch:
	@$(call banner,Fetching beaglebone meta-repo)
	@$(call gitclone,${BBONE_GIT},${BBONE_DIR},${BBONE_BRANCH})
	@$(call banner,Checkout beaglebone ${BBONE_BRANCH})
	@$(call gitcheckout,${BBONE_DIR},${BBONE_BRANCH})
	@$(call banner,Patch beaglebone script)
	@$(call apply_patch,${BBONE_DIR},${PATCHDIR}/bbone/local_shared_kernel.patch)
	@$(call banner,Patch beaglebone kernel)
	@(cd ${BBONE_DIR} && ./patch.sh)
	@$(call state,$@)

beaglebone-sync: state/beaglebone-fetch beaglebone-clean
	@$(call banner, "Syncing beaglebone...")
	@$(call gitsync,${BBONE_DIR},${BBONE_COMMIT},${BBONE_BRANCH},${BBONE_TAG})

beaglebone-build: beaglebone-fetch kernel-build

beaglebone-clean:
	@$(call banner,Cleaning foo)

beaglebone-mrproper:
	@$(call banner,Really cleaning foo)

beaglebone-raze:
	@$(call banner,Getting rid of all downloaded files for foo)

clean: kernel-clean kernel-gcc-clean beaglebone-clean
	@$(call banner,Clean)

mrproper: clean kernel-mrproper kernel-gcc-mrproper beaglebone-mrproper tmp-mrproper
	@rm -rf ${LOGDIR}/*
	@$(call banner,Very Clean)
