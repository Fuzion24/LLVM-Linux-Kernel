#############################################################################
# Copyright (c) 2014 Behan Webster
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

BB_ARTIFACT_MANIFEST	= ${BUILDBOTDIR}/manifest.ini
BB_SETTINGS_CFG		= ${BUILDBOTDIR}/${TARGET}.cfg
BB_KERNEL_CFG		= ${BUILDBOTDIR}/kernel-${TARGET}.cfg

#############################################################################
.PHONY: ${BB_ARTIFACT_MANIFEST} ${BB_SETTINGS_CFG} ${BB_KERNEL_CFG}
bb_manifest: ${BB_ARTIFACT_MANIFEST}
${BB_ARTIFACT_MANIFEST}:
	@$(call banner,Building $@)
	@mkdir -p $(dir $@)
	@echo "# Buildbot manifest for ${TARGET} built on `date`" > $@
	@$(call ini_section,$@,[Versions],list-versions)
	@$(call ini_section,$@,[Config],list-settings)
	@$(call ini_section,$@,[Artifacts],list-buildbot-artifacts)

#############################################################################
list-buildbot-artifacts::
	@$(call ini_file_entry,CONFIG\t\t,${BB_SETTINGS_CFG})
	@$(call ini_file_entry,KERNEL\t\t,${BB_KERNEL_CFG})

#############################################################################
bb_settings: ${BB_SETTINGS_CFG}
${BB_SETTINGS_CFG}:
	@$(MAKE) -s list-settings > $@

#############################################################################
bb_kernel: ${BB_KERNEL_CFG}
${BB_KERNEL_CFG}:
	@$(MAKE) -s kernel-settings > $@

#############################################################################
# Updated in toolchain/clang/buildbot.mk
bb_toolchain::

############################################################################
# Clang is already built before this
buildbot-llvm-ci-build buildbot-clang-ci-build::
	$(MAKE) kernel-rebuild-known-good
	$(MAKE) kernel-test
	$(MAKE) bb_toolchain bb_manifest

############################################################################
# Clang is already built before this
buildbot-kernel-ci-build::
	$(MAKE) GIT_HARD_RESET=1 kernel-clean
	$(MAKE) kernel-build
	$(MAKE) kernel-test
	$(MAKE) bb_settings bb_kernel bb_manifest
