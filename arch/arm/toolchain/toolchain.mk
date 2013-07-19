##############################################################################
# Copyright {c} 2012 Mark Charlebois
#               2012 Behan Webster
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files {the "Software"}, to 
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

# The following exports are required for make_kernel.sh
export CFLAGS COMPILER_PATH HOST HOST_TRIPLE ARM_CROSS_GCC_TOOLCHAIN

ARCH_ARM_TMPDIR	= ${ARCH_ARM_DIR}/toolchain/tmp
TMPDIRS		+= ${ARCH_ARM_TMPDIR}

HELP_TARGETS	+= arm-gcc-toolchain-help
arm-gcc-toolchain-help:
	@echo
	@echo "You can choose your cross-gcc by setting the CROSS_ARM_TOOLCHAIN variable."
	@echo "  CROSS_ARM_TOOLCHAIN=android       Download and use Android gcc cross-toolchain"
	@echo "  CROSS_ARM_TOOLCHAIN=codesourcery  Download and use Code sourcery toolchain (Default)"
	@echo "  CROSS_ARM_TOOLCHAIN=linaro        Download and use Linaro gcc cross-toolchain"
	@echo "  CROSS_ARM_TOOLCHAIN=native        Use distro installed gcc cross-toolchain"

# Configure the requested ARM cross compiler
# Sets CROSS_GCC, PATH, HOST, HOST_TRIPLE
# and state/arm-cc
# This is required whether or not clang is the
# compiler being used. These files must define
# arm-cc which will be a build dep for ARM
ifeq (${CROSS_ARM_TOOLCHAIN},android)
  include ${ARCH_ARM_TOOLCHAIN}/android/android.mk
else
  ifeq (${CROSS_ARM_TOOLCHAIN},linaro)
    include ${ARCH_ARM_TOOLCHAIN}/linaro/linaro.mk
  else
    ifeq (${CROSS_ARM_TOOLCHAIN},native)
      include ${ARCH_ARM_TOOLCHAIN}/native.mk
    else
      include ${ARCH_ARM_TOOLCHAIN}/codesourcery/codesourcery.mk
    endif
  endif
endif

ifneq (${COMPILER_PATH}, "")
CCOPTS	= -gcc-toolchain ${COMPILER_PATH}
endif

include ${ARCHDIR}/arm/toolchain/compiler-rt/compiler-rt.mk

