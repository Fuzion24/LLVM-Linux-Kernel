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
BB_TARGET_CFG		= ${BUILDBOTDIR}/target-${TARGET}.cfg
BB_KERNEL_CFG		= ${BUILDBOTDIR}/kernel-${TARGET}.cfg

#############################################################################
.PHONY: ${BB_ARTIFACT_MANIFEST} ${BB_TARGET_CFG} ${BB_KERNEL_CFG}
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
	@$(call ini_file_entry,TARGET\t\t,${BB_TARGET_CFG})
	@$(call ini_file_entry,KERNEL\t\t,${BB_KERNEL_CFG})

#############################################################################
bb_target: ${BB_TARGET_CFG}
${BB_TARGET_CFG}:
	@$(call banner,Building $@)
	@mkdir -p $(dir $@)
	@$(MAKE) -s list-settings | grep -v ^make > $@

#############################################################################
bb_kernel: ${BB_KERNEL_CFG}
${BB_KERNEL_CFG}:
	@$(call banner,Building $@)
	@mkdir -p $(dir $@)
	@$(MAKE) -s kernel-settings | grep -v ^make > $@

#############################################################################
# Updated in toolchain/clang/buildbot.mk
bb_clang::

############################################################################
# Clang is already built before this
buildbot-llvm-ci-build buildbot-clang-ci-build::
	$(MAKE) kernel-rebuild-known-good
	$(MAKE) kernel-test
	$(MAKE) bb_clang bb_manifest

############################################################################
# Clang is already built before this
buildbot-kernel-ci-build::
	@$(call banner,Build/test kernel with gcc)
	$(MAKE) GIT_HARD_RESET=1 kernel-gcc-clean
	$(MAKE) kernel-gcc-build
	$(MAKE) kernel-gcc-test
	@$(call banner,Build/test kernel with clang)
	$(MAKE) GIT_HARD_RESET=1 kernel-clean
	$(MAKE) kernel-build
	$(MAKE) kernel-test
	$(MAKE) bb_target bb_kernel bb_manifest
