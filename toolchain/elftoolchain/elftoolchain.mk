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

ETCSRCDIR	= ${ETCTOP}/src
ETCBUILD	= $(subst ${TOPDIR},${BUILDROOT},${ETCTOP}/build)
ETCINSTALLDIR	= ${ETCTOP}/install
ETCPATCHES	= ${ETCTOP}/patches
ETCSTATE	= ${ETCTOP}/state
ETCTMP		= ${ETCTOP}/tmp

DEBDEP		+= bison fakeroot flex gcc libarchive-dev m4 pmake libexpat1-dev python-yaml sharutils subversion
RPMDEP		+= bison flex gcc m4 pmake subversion

CLEAN_TARGETS		+= elftoolchain-clean
FETCH_TARGETS		+= elftoolchain-fetch
HELP_TARGETS		+= elftoolchain-help
MRPROPER_TARGETS	+= elftoolchain-mrproper
PATCH_APPLIED_TARGETS	+= ${ETC_TARGETS_APPLIED}
RAZE_TARGETS		+= elftoolchain-raze
SETTINGS_TARGETS	+= elftoolchain-settings
SYNC_TARGETS		+= elftoolchain-sync
TARGETS_TOOLCHAIN	+= ${ETC_TARGETS}
TMPDIRS			+= ${ETCTMP}
VERSION_TARGETS		+= ${ETC_VERSION_TARGETS}

.PHONY:			${ETC_TARGETS} ${ETC_TARGETS_APPLIED} ${ETC_VERSION_TARGETS}

ETC_SVN		= http://elftoolchain.svn.sourceforge.net/svnroot/elftoolchain/trunk
ETC_SVN_REV	= HEAD

ETC_DIR		= ${ETCSRCDIR}/elftoolchain

TET_URL		= http://tetworks.opengroup.org/downloads/38/software/Sources/3.8/tet3.8-src.tar.gz
TET_FILE	= ${ETCTMP}/$(notdir ${TET_URL})
TET_DIR		= ${ETC_DIR}/test/tet/tet3.8

# Add elftoolchain to the path
PATH		:= ${ETCINSTALLDIR}/usr/bin:${PATH}

##############################################################################
elftoolchain-help:
	@echo
	@echo "These are the make targets for building Elf toolchain:"
	@echo "* make elftoolchain-[fetch,patch,build,sync,clean]"

##############################################################################
elftoolchain-settings:
	@echo "# ELFTOOLCHAIN settings"
	@$(call prsetting,ETC_SVN,${ETC_SVN})
	@$(call prsetting,ETC_SVN_REV,${ETC_SVN_REV})
	@$(call prsetting,TET_URL,${TET_URL})

##############################################################################
elftoolchain-fetch: ${ETCSTATE}/elftoolchain-fetch
${ETCSTATE}/elftoolchain-fetch:
	@$(call banner,Fetch Elf Toolchain)
	@$(call svncheckout,${ETC_SVN},${ETC_DIR},${ETC_SVN_REV})
	$(call state,$@,elftoolchain-patch)

##############################################################################
tet-fetch: ${ETCSTATE}/tet-fetch
${ETCSTATE}/tet-fetch: ${ETCSTATE}/elftoolchain-fetch
	@$(call banner,Fetch Test Environment Toolkit)
	@$(call wget,${TET_URL},$(dir ${TET_FILE}))
	@$(call untgz,${TET_FILE},$(dir ${TET_DIR}))
	$(call state,$@,elftoolchain-patch)

##############################################################################
elftoolchain-patch: ${ETCSTATE}/elftoolchain-patch
${ETCSTATE}/elftoolchain-patch: ${ETCSTATE}/tet-fetch
	@$(call banner,Patch ElfToolChain)
	@$(call patches_dir,${ETCPATCHES},${ETC_DIR}/patches)
	@$(call patch,${ETC_DIR})
	$(call state,$@,elftoolchain-build)

##############################################################################
elftoolchain-patch-applied: ${ETCSTATE}/elftoolchain-patch
	@$(call banner,Patches applied for ElfToolChain)
	@$(call applied,${ETCSRCDIR}/$*)

##############################################################################
elftoolchain elftoolchain-build: ${ETCSTATE}/elftoolchain-build
${ETCSTATE}/elftoolchain-build: ${ETCSTATE}/elftoolchain-patch
	@make -s build-dep-check
	@[ -d ${ETCBUILDDIR} ] || ${MAKE} elftoolchain-clean $^ # build in tmpfs
	@$(call banner,Building ElfToolChain)
	@(cd ${ETC_DIR} && pmake)
	@$(call banner,Installing ElfToolChain)
	@mkdir -p $(addprefix ${ETCINSTALLDIR}/,usr/bin usr/include usr/lib/x86_64-linux-gnu usr/share/man/man1 usr/share/man/man3 usr/share/man/man5)
	@(cd ${ETC_DIR} && fakeroot pmake DESTDIR=${ETCINSTALLDIR} install)
	$(call state,$@,elftoolchain-build)

##############################################################################
elftoolchain-clean:
	-@(cd ${ETC_DIR} && pmake clean)
	@$(call unpatch,${ETC_DIR})
	@$(call leavestate,${ETCSTATE},elftoolchain-patch elftoolchain-build)

##############################################################################
elftoolchain-mrproper:
	-@$(MAKE) elftoolchain-clean
	@rm -rf ${ETCBUILDDIR} ${ETCINSTALLDIR}

##############################################################################
elftoolchain-raze:
	-@$(MAKE) elftoolchain-mrproper
	@$(call banner,Razing Elf toolchain...)
	@rm -rf ${ETCSRCDIR} ${ETCSTATE} ${ETCTMP}

##############################################################################
elftoolchain-sync: elftoolchain-clean
	@$(call banner,Syncing Elf toolchain...)
	@$(call check_llvmlinux_commit,${CONFIG})
	@$(call svnupdate,${ETC_DIR})

##############################################################################
elftoolchain-version:
	@(cd ${ETC_DIR} && [ -f "${ETCINSTALLDIR}/bin/llc" ] \
		&& echo "`${ETCINSTALLDIR}/bin/llc --version | grep version | xargs echo` commit `git rev-parse HEAD`" \
		|| echo "LLVM version ? commit `git rev-parse HEAD`")
