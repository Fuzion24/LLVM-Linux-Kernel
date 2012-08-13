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

export CSCC_DIR
export CSCC_BINDIR
export COMPILER_PATH=${CSCC_DIR}
export HOST_TYPE=${HOST}
export HOST_TRIPLE

HOST		= arm-none-linux-gnueabi
HOST_TRIPLE	= arm-none-gnueabi
CROSS_COMPILE	= ${HOST}-

CSCC_URL	= https://sourcery.mentor.com/GNUToolchain/package8739/public/arm-none-linux-gnueabi/arm-2011.03-41-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2
CSCC_NAME	= arm-2011.03
#CSCC_URL	= https://sourcery.mentor.com/sgpp/lite/arm/portal/package9728/public/arm-none-linux-gnueabi/arm-2011.09-70-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2"
#CSCC_NAME	= arm-2011.09

CSCC_TAR	= ${notdir ${CSCC_URL}}
CSCC_DIR	= ${TOOLCHAIN}/${CSCC_NAME}
CSCC_BINDIR	= ${CSCC_DIR}/bin

# Add path so that ${CROSS_COMPILE}${CC} is resolved
PATH		+= :${CSCC_BINDIR}:${ARCH_ARM_BINDIR}:

# Get arm cross compiler
${ARCH_ARM_TMPDIR}/${CSCC_TAR}:
	@mkdir -p ${ARCH_ARM_TMPDIR}
	wget -c -P ${ARCH_ARM_TMPDIR} "${CSCC_URL}"

CROSS_GCC=${CSCC_BINDIR}/${CROSS_COMPILE}gcc
arm-cc: state/codesourcery-gcc
state/codesourcery-gcc: ${ARCH_ARM_TMPDIR}/${CSCC_TAR}
	tar -x -j -C ${TOOLCHAIN} -f $<
	$(call state,$@)

arm-cc-version: state/codesourcery-gcc
	@${CROSS_GCC} --version | head -1

${ARCH_ARM_TMPDIR}:
	@mkdir -p $@
