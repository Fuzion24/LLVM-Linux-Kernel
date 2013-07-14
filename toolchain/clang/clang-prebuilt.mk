##############################################################################
# Copyright (c) 2013 Behan Webster
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to 
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

# Assumes has been included from clang.mk

CLANG_TMPDIR	= ${LLVMTOP}/tmp
TMPDIRS		+= ${CLANG_TMPDIR}
RAZE_TARGETS	+= clang-raze

CLANG_DIR	= clang+llvm-3.3-Ubuntu-13.04-x86_64-linux-gnu
CLANG_PATH	= ${LLVMTOP}/${CLANG_DIR}
CLANG_BINDIR	= ${CLANG_PATH}/bin
CLANG_TAR	= ${CLANG_DIR}.tar.bz2
CLANG_URL	= http://llvm.org/releases/3.3/${CLANG_TAR}

CLANG			= ${CLANG_BINDIR}/clang
STATE_CLANG_TOOLCHAIN	= ${CLANG}

# Add clang to the path
PATH		:= ${CLANG_BINDIR}:${PATH}

${CLANG}: ${LLVMSTATE}/clang-prebuild

clang-get: ${CLANG_TMPDIR}/${CLANG_TAR}
${CLANG_TMPDIR}/${CLANG_TAR}:
	@$(call wget,${CLANG_URL},${CLANG_TMPDIR})

clang-unpack: ${LLVMSTATE}/clang-prebuild
${LLVMSTATE}/clang-prebuild: ${CLANG_TMPDIR}/${CLANG_TAR}
	@$(call unbz2,$<,${LLVMTOP})
	$(call state,$@)

clang-raze:
	@rm -rf ${LLVMSTATE}/clang-prebuild ${CLANG_PATH} ${CLANG_TMPDIR}/${CLANG_TAR}
