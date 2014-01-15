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

VERSION_TARGETS	+= llvm-version clang-version

LLVMSTATE	= ${LLVMTOP}/state

# The following export is needed by make_kernel.sh and clang_wrap.sh
export CLANG

HELP_TARGETS	+= clang-toolchain-help
SETTINGS_TARGETS+= clang-toolchain-settings

clang-toolchain-help:
	@echo
	@echo "You can choose your clang by setting the CLANG_TOOLCHAIN variable."
	@echo "  CLANG_TOOLCHAIN=prebuilt     Download and use llvm.org clang"
	@echo "  CLANG_TOOLCHAIN=native       Use distro installed clang"
	@echo "  CLANG_TOOLCHAIN=from-source  Download and build from source (Default)"

clang-toolchain-settings:
	@$(call prsetting,CLANG_TOOLCHAIN,${CLANG_TOOLCHAIN})

CLANG_TOOLCHAIN ?= from-source

ifeq (${CLANG_TOOLCHAIN},prebuilt)
  include ${LLVMTOP}/clang-prebuilt.mk
else
  ifeq (${CLANG_TOOLCHAIN},native)
    include ${LLVMTOP}/clang-native.mk
  else
    include ${LLVMTOP}/clang-from-source.mk
  endif
endif

##############################################################################
llvm-version::
	@[ ! -e $(dir ${CLANG})llc ] || echo `$(dir ${CLANG})llc --version | grep version`

##############################################################################
clang-version::
	@[ ! -e ${CLANG} ] || echo "`${CLANG} --version | grep version`"

