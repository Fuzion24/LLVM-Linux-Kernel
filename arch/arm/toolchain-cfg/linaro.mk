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

# Note: use CROSS_ARM_VERSION=linaro to include this file

export LINARO_CC_DIR
export LINARO_CC_BINDIR
export COMPILER_PATH=${LINARO_CC_DIR}
export HOST_TYPE=${HOST}
export HOST_TRIPLE

HOST		= arm-linux-gnueabihf
HOST_TRIPLE	= arm-none-gnueabi
CROSS_COMPILE	= ${HOST}-

LINARO_CC_URL	= https://launchpad.net/linaro-toolchain-binaries/trunk/2012.07/+download/gcc-linaro-arm-linux-gnueabihf-2012.07-20120720_linux.tar.bz2
LINARO_CC_NAME	= gcc-linaro-arm-linux-gnueabihf-2012.07-20120720_linux

LINARO_CC_TAR	= ${notdir ${LINARO_CC_URL}}
LINARO_CC_DIR	= ${TOOLCHAIN}/linaro-20120720
LINARO_CC_BINDIR= ${LINARO_CC_DIR}/bin

# Add path so that ${CROSS_COMPILE}${CC} is resolved
PATH		+= :${LINARO_CC_BINDIR}:${ARCH_ARM_BINDIR}:

# Get arm cross compiler
${ARCH_ARM_TMPDIR}/${LINARO_CC_TAR}:
	@mkdir -p ${ARCH_ARM_TMPDIR}
	[ -d ${LINARO_CC_DIR} ] || wget -c -P ${ARCH_ARM_TMPDIR} "${LINARO_CC_URL}"

CROSS_GCC=${LINARO_CC_BINDIR}/${CROSS_COMPILE}gcc
gcc arm-cc: state/cross-gcc
state/cross-gcc: ${ARCH_ARM_TMPDIR}/${LINARO_CC_TAR}
	[ -d ${LINARO_CC_DIR} ] || tar -x -j -C ${TOOLCHAIN} -f $<
	mv ${TOOLCHAIN}/${LINARO_CC_NAME} ${LINARO_CC_DIR}
	$(call state,$@)

${ARCH_ARM_TMPDIR}:
	@mkdir -p $@
