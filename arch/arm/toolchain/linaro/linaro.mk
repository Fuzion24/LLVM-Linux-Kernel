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

LINARO_VERSION		?= 13.12
LINARO_GCC_VERSION	?= 4.8
LINARO_CC_NAME		?= gcc-linaro-arm-linux-gnueabihf
LINARO_CC_URL		?= http://releases.linaro.org/${LINARO_VERSION}/components/toolchain/binaries/${LINARO_CC_NAME}-${LINARO_GCC_VERSION}-20${LINARO_VERSION}_linux.tar.bz2
LINARO_DIR		?= ${ARCH_ARM_TOOLCHAIN}/linaro
LINARO_TMPDIR		= ${LINARO_DIR}/tmp
TMPDIRS			+= ${LINARO_TMPDIR}

LINARO_CC_TAR		= ${notdir ${LINARO_CC_URL}}
LINARO_CC_DIR		= ${LINARO_DIR}/${LINARO_CC_NAME}
LINARO_CC_BINDIR	= ${LINARO_CC_DIR}/bin

HOST			?= arm-linux-gnueabihf
HOST_TRIPLE		?= ${HOST}
COMPILER_PATH		= ${LINARO_CC_DIR}
LINARO_GCC		= ${LINARO_CC_BINDIR}/${CROSS_COMPILE}gcc
CROSS_GCC		= ${LINARO_GCC}

ARM_CROSS_GCC_TOOLCHAIN = ${LINARO_CC_DIR}

# Add path so that ${CROSS_COMPILE}${CC} is resolved
PATH			:= ${LINARO_CC_BINDIR}:${PATH}

# Get Linaro cross compiler
${LINARO_TMPDIR}/${LINARO_CC_TAR}:
	@$(call wget,"${LINARO_CC_URL}",${LINARO_TMPDIR})

linaro-gcc arm-cc: ${ARCH_ARM_TOOLCHAIN_STATE}/linaro-gcc
${ARCH_ARM_TOOLCHAIN_STATE}/linaro-gcc: ${LINARO_TMPDIR}/${LINARO_CC_TAR}
	rm -rf ${LINARO_CC_DIR}
	tar -x -j -C ${LINARO_DIR} -f $<
	$(call state,$@)

state/arm-cc: ${ARCH_ARM_TOOLCHAIN_STATE}/linaro-gcc
	$(call state,$@)

linaro-gcc-clean arm-cc-clean:
	@$(call banner,Removing Linaro compiler...)
	@rm -f state/arm-cc ${ARCH_ARM_TOOLCHAIN_STATE}/linaro-gcc
	@rm -rf ${LINARO_CC_DIR}

arm-cc-version: ${ARCH_ARM_TOOLCHAIN_STATE}/linaro-gcc
	env
	@${LINARO_GCC} --version | head -1

