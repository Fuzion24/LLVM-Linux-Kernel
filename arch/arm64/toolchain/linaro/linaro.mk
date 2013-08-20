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

# Note: use CROSS_ARM_TOOLCHAIN=linaro to include this file

#https://launchpad.net/linaro-toolchain-binaries/trunk/2013.04/+download/gcc-linaro-aarch64-linux-gnu-4.7-2013.04-20130415_linux.tar.bz2
LINARO_VER_MONTH	= 2013.04
LINARO_VERSION		= ${LINARO_VER_MONTH}-20130415
LINARO_CC_NAME		= gcc-linaro-aarch64-linux-gnu-4.7-${LINARO_VERSION}_linux
HOST			= aarch64-linux-gnu

# So we can just include the arm rules
LINARO_DIR		= ${ARCH_ARM64_TOOLCHAIN}/linaro
ARCH_ARM_TOOLCHAIN_STATE = ${ARCH_ARM64_TOOLCHAIN_STATE}

include ${ARCH_ARM_TOOLCHAIN}/linaro/linaro.mk

arm64-cc: arm-cc
state/arm64-cc: ${ARCH_ARM64_TOOLCHAIN_STATE}/linaro-gcc
	$(call state,$@)
