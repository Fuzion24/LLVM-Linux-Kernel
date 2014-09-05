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

# Note: use CROSS_AARCH64_TOOLCHAIN=linaro to include this file

#https://launchpad.net/linaro-toolchain-binaries/trunk/2013.04/+download/gcc-linaro-aarch64-linux-gnu-4.7-2013.04-20130415_linux.tar.bz2
#https://launchpad.net/linaro-toolchain-binaries/trunk/2013.09/+download/gcc-linaro-aarch64-linux-gnu-4.8-2013.09_linux.tar.bz2
#https://launchpad.net/linaro-toolchain-binaries/trunk/2013.10/+download/gcc-linaro-aarch64-linux-gnu-4.8-2013.10_linux.tar.xz
LINARO_VER_MONTH	= 2013.10
LINARO_VERSION		= ${LINARO_VER_MONTH}
LINARO_CC_NAME		= gcc-linaro-aarch64-linux-gnu-4.8-${LINARO_VERSION}_linux
HOST			= aarch64-linux-gnu

# So we can just include the arm rules
LINARO_DIR		= ${ARCH_AARCH64_TOOLCHAIN}/linaro
ARCH_ARM_TOOLCHAIN_STATE = ${ARCH_AARCH64_TOOLCHAIN_STATE}

LINARO_CC_URL		?= https://launchpad.net/linaro-toolchain-binaries/trunk/${LINARO_VER_MONTH}/+download/${LINARO_CC_NAME}.tar.xz
LINARO_TMPDIR		= $(call shared,${LINARO_DIR}/tmp)
TMPDIRS			+= ${LINARO_TMPDIR}

LINARO_CC_TAR		= ${notdir ${LINARO_CC_URL}}
LINARO_CC_DIR		= ${LINARO_DIR}/${LINARO_CC_NAME}
LINARO_CC_BINDIR	= ${LINARO_CC_DIR}/bin

HOST_TRIPLE		?= ${HOST}
COMPILER_PATH		= ${LINARO_CC_DIR}
LINARO_GCC		= ${LINARO_CC_BINDIR}/${CROSS_COMPILE}gcc
CROSS_GCC		= ${LINARO_GCC}

AARCH64_CROSS_GCC_TOOLCHAIN = ${LINARO_CC_DIR}

# Add path so that ${CROSS_COMPILE}${CC} is resolved
PATH			:= ${LINARO_CC_BINDIR}:${PATH}

# Get Linaro cross compiler
${LINARO_TMPDIR}/${LINARO_CC_TAR}:
	@$(call wget,${LINARO_CC_URL},${LINARO_TMPDIR}/${LINARO_CC_TAR})

linaro-gcc aarch64-cc: ${ARCH_ARM_TOOLCHAIN_STATE}/linaro-gcc
${ARCH_AARCH64_TOOLCHAIN_STATE}/linaro-gcc: ${LINARO_TMPDIR}/${LINARO_CC_TAR}
	rm -rf ${LINARO_CC_DIR}
	$(call unxz,$<,${LINARO_DIR})
	$(call state,$@)

state/aarch64-cc: ${ARCH_AARCH64_TOOLCHAIN_STATE}/linaro-gcc
	$(call state,$@)

linaro-gcc-clean aarch64-cc-clean:
	@$(call banner,Removing Linaro compiler...)
	@rm -f state/aarch64-cc ${ARCH_AARCH64_TOOLCHAIN_STATE}/linaro-gcc
	@rm -rf ${LINARO_CC_DIR}

aarch64-cc-version: ${ARCH_AARCH64_TOOLCHAIN_STATE}/linaro-gcc
	@${LINARO_GCC} --version | head -1
