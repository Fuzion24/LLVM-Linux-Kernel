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

TARGETS		+= linaro-gcc

export LINARO_CC_DIR
export LINARO_CC_BINDIR
export COMPILER_PATH=${LINARO_CC_DIR}
export HOST_TYPE=${HOST}
export HOST_TRIPLE
#export GCC_TOOLCHAIN_CFG=${ARCH_ARM_DIR}/toolchain/config/linaro.cfg

HOST		= arm-linux-gnueabihf
HOST_TRIPLE	= arm-none-gnueabi
CROSS_COMPILE	= ${HOST}-

LINARO_VER_MONTH=2012.07
LINARO_VERSION=${LINARO_VER_MONTH}-20120720
LINARO_CC_URL	= https://launchpad.net/linaro-toolchain-binaries/trunk/${LINARO_VER_MONTH}/+download/gcc-linaro-arm-linux-gnueabihf-${LINARO_VERSION}_linux.tar.bz2
LINARO_CC_NAME	= gcc-linaro-arm-linux-gnueabihf-${LINARO_VERSION}_linux

LINARO_CC_TAR	= ${notdir ${LINARO_CC_URL}}
export LINARO_CC_DIR=${ARCH_ARM_DIR}/toolchain/${LINARO_CC_NAME}
export LINARO_CC_BINDIR= ${LINARO_CC_DIR}/bin

# Add path so that ${CROSS_COMPILE}${CC} is resolved
PATH:=${LINARO_CC_BINDIR}:${ARCH_ARM_BINDIR}:${PATH}

export HOST_TYPE=arm-linux-gnueabihf
export HOST_TRIPLE=arm-none-gnueabi
export COMPILER_PATH=${LINARO_CC_DIR}
export CROSS_COMPILE=${HOST_TYPE}-
export CC_FOR_BUILD=${LINARO_CC_BINDIR}/${HOST_TYPE-gcc}

# Get arm cross compiler
${ARCH_ARM_TMPDIR}/${LINARO_CC_TAR}:
	@mkdir -p ${ARCH_ARM_TMPDIR}
	wget -c -P ${ARCH_ARM_TMPDIR} "${LINARO_CC_URL}"

LINARO_GCC=${LINARO_CC_BINDIR}/${CROSS_COMPILE}gcc
CC_FOR_BUILD	= ${LINARO_GCC}

arm-cc: ${ARCH_ARM_DIR}/toolchain/state/linaro-gcc
linaro-gcc: ${ARCH_ARM_DIR}/toolchain/state/linaro-gcc
${ARCH_ARM_DIR}/toolchain/state/linaro-gcc: ${ARCH_ARM_TMPDIR}/${LINARO_CC_TAR}
	rm -rf ${LINARO_CC_DIR}
	tar -x -j -C ${ARCH_ARM_DIR}/toolchain -f $<
	$(call state,$@)

state/cross-gcc: ${ARCH_ARM_DIR}/toolchain/state/linaro-gcc
	$(call state,$@)

arm-cc-version: ${ARCH_ARM_DIR}/toolchain/state/linaro-gcc
	@${LINARO_GCC} --version | head -1

${ARCH_ARM_TMPDIR}:
	@mkdir -p $@
