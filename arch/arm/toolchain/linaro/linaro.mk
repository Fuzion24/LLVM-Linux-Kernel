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
# Note: On x86_64, need to install libz1g:i386 and libstdc++6:i386

TARGETS		+= linaro-gcc

http://releases.linaro.org/14.10/components/toolchain/binaries/arm-linux-gnueabihf/gcc-linaro-4.9-2014.10-x86_64_arm-linux-gnueabihf.tar.xz
LINARO_VERSION		?= 14.10
LINARO_GCC_VERSION	?= 4.9
LINARO_CC_NAME		?= arm-linux-gnueabihf
LINARO_CC_DIR_NAME	= gcc-linaro-${LINARO_GCC_VERSION}-20${LINARO_VERSION}-x86_64_${LINARO_CC_NAME}
LINARO_CC_DIR		= ${LINARO_DIR}/${LINARO_CC_DIR_NAME}
LINARO_CC_URL		?= http://releases.linaro.org/${LINARO_VERSION}/components/toolchain/binaries/${LINARO_CC_NAME}/${LINARO_CC_DIR_NAME}.tar.xz
LINARO_DIR		?= ${ARCH_ARM_TOOLCHAIN}/linaro
LINARO_TMPDIR		= $(call shared,${LINARO_DIR}/tmp)
TMPDIRS			+= ${LINARO_TMPDIR}

LINARO_CC_TAR_XZ	= ${LINARO_CC_DIR_NAME}.tar.xz
LINARO_CC_TAR		= ${LINARO_CC_DIR_NAME}.tar
LINARO_CC_BINDIR	= ${LINARO_CC_DIR_NAME}/bin

HOST			?= ${LINARO_CC_NAME}
HOST_TRIPLE		?= ${HOST}
COMPILER_PATH		= ${LINARO_CC_DIR}
LINARO_GCC		= ${LINARO_CC_BINDIR}/${CROSS_COMPILE}gcc
CROSS_GCC		= ${LINARO_GCC}

DEBDEP			+= 

ARM_CROSS_GCC_TOOLCHAIN = ${LINARO_CC_DIR}

# Add path so that ${CROSS_COMPILE}${CC} is resolved
PATH			:= ${LINARO_CC_BINDIR}:${PATH}

# Get Linaro cross compiler
${LINARO_TMPDIR}/${LINARO_CC_TAR}:
	mkdir -p ${LINARO_TMPDIR}
	@$(call wget,${LINARO_CC_URL},${LINARO_TMPDIR})
	(cd ${LINARO_TMPDIR} && unxz ${LINARO_CC_TAR_XZ})

linaro-gcc arm-cc: ${ARCH_ARM_TOOLCHAIN_STATE}/linaro-gcc
${ARCH_ARM_TOOLCHAIN_STATE}/linaro-gcc: ${LINARO_TMPDIR}/${LINARO_CC_TAR}
	rm -rf ${LINARO_CC_DIR}
	tar -x -C ${LINARO_DIR} -f $<
	$(call state,$@)

state/arm-cc: ${ARCH_ARM_TOOLCHAIN_STATE}/linaro-gcc
	$(call state,$@)

linaro-gcc-clean arm-cc-clean:
	@$(call banner,Removing Linaro compiler...)
	@rm -f state/arm-cc ${ARCH_ARM_TOOLCHAIN_STATE}/linaro-gcc
	@rm -rf ${LINARO_CC_DIR}

arm-cc-version: ${ARCH_ARM_TOOLCHAIN_STATE}/linaro-gcc
	@echo -e "LINARO_GCC\t= `${LINARO_GCC} --version | head -1`"

env:
	echo ${LINARO_TMPDIR}
