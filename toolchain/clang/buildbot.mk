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

# Should be included from clang-from-source.mk

BB_TOOLCHAIN_CFG	= ${BUILDBOTDIR}/clang-${ARCH}.cfg

#############################################################################
list-buildbot-artifacts::
	@$(call ini_file_entry,TOOLCHAIN\t,${BB_TOOLCHAIN_CFG})

#############################################################################
.PHONY: ${BB_TOOLCHAIN_CFG}
bb_toolchain::
	@$(call banner,Building ${BB_TOOLCHAIN_CFG})
	@mkdir -p $(dir ${BB_TOOLCHAIN_CFG})
	@$(MAKE) -s llvm-settings | grep -v ^make > ${BB_TOOLCHAIN_CFG}

############################################################################
# Kernel is tested after this
buildbot-llvm-ci-build::
	$(MAKE) GIT_HARD_RESET=1 llvm-clean
	$(MAKE) clang
buildbot-clang-ci-build::
	$(MAKE) GIT_HARD_RESET=1 clang-clean
	$(MAKE) clang

############################################################################
# Kernel is tested after this
buildbot-kernel-ci-build::
	$(MAKE) clang-rebuild-known-good
