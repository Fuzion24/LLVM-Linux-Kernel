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

# Note: use CROSS_ARM_TOOLCHAIN=android to include this file

export COMPILER_PATH=${CSCC_DIR}
export HOST_TYPE=${HOST}
export HOST_TRIPLE

HOST		= arm-linux-androideabi
HOST_TRIPLE	= arm-linux-androideabi
CROSS_COMPILE	= ${HOST}-
CC		= gcc

ANDROID_GCC	= arm-linux-androideabi-4.4.x

ANDROID_GCC_BINDIR=${TOOLCHAIN}/android/prebuilt/linux-x86/toolchain/${ANDROID_GCC}/bin

# Add path so that ${CROSS_COMPILE}${CC} is resolved
PATH		+= :${TOOLCHAIN}/android/prebuilt/linux-x86/toolchain/${ANDROID_GCC}/bin:

CROSS_GCC=${ANDROID_GCC_BINDIR}/${CROSS_COMPILE}gcc
arm-cc: state/android-gcc
state/android-gcc: ${TOOLCHAIN}/status/gcc-android-fetch

arm-cc-version: state/android-gcc
	@${CROSS_GCC} --version | head -1
