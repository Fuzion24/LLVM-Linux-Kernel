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

# Note: use CROSS_ARM_TOOLCHAIN=codesourcery to include this file

CSCC_URL	= https://sourcery.mentor.com/GNUToolchain/package8739/public/arm-none-linux-gnueabi/arm-2011.03-41-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2
CSCC_NAME	= arm-2011.03
CSCC_TAR	= ${notdir ${CSCC_URL}}
CSCC_TMPDIR	= ${ARCH_ARM_DIR}/toolchain/codesourcery/tmp

HOST		= arm-none-linux-gnueabi
CSCC_DIR	= ${ARCH_ARM_DIR}/toolchain/codesourcery/${CSCC_NAME}
CSCC_BINDIR	= ${CSCC_DIR}/bin
HOST_TRIPLE	= arm-none-gnueabi
COMPILER_PATH	= ${CSCC_DIR}
CC_FOR_BUILD	= ${CSCC_BINDIR}/${HOST}-gcc
export HOST HOST_TRIPLE

# Add path so that ${CROSS_COMPILE}${CC} is resolved
PATH		:= ${CSCC_BINDIR}:${ARCH_ARM_BINDIR}:${PATH}

# Get ARM cross compiler
${CSCC_TMPDIR}/${CSCC_TAR}:
	@mkdir -p ${CSCC_TMPDIR}
	wget -c -P ${CSCC_TMPDIR} "${CSCC_URL}"

CROSS_GCC=${CSCC_BINDIR}/${CROSS_COMPILE}gcc
arm-cc: ${ARCH_ARM_DIR}/toolchain/state/codesourcery-gcc
${ARCH_ARM_DIR}/toolchain/state/codesourcery-gcc: ${CSCC_TMPDIR}/${CSCC_TAR}
	tar -x -j -C ${ARCH_ARM_DIR}/toolchain/codesourcery -f $<
	$(call state,$@)

state/arm-cc: ${ARCH_ARM_DIR}/toolchain/state/codesourcery-gcc
	$(call state,$@)
	

arm-cc-version: ${ARCH_ARM_DIR}/toolchain/state/codesourcery-gcc
	@${CROSS_GCC} --version | head -1

${ARCH_ARM_TMPDIR}:
	@mkdir -p $@
