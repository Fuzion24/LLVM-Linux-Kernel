##############################################################################
# Copyright (c) 2012 Mark Charlebois
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

# This makefile must be included after common.mk which includes toolchain.mk

ARMSTATE		= ${ARCH_ARM_TOOLCHAIN}/state
COMPILERRTBUILDDIR	= ${ARCH_ARM_TOOLCHAIN}/compiler-rt/build
COMPILERRTINSTALLDIR	= ${ARCH_ARM_TOOLCHAIN}/compiler-rt/install
TARGETS			+= compilerrt-arm-configure compilerrt-arm-build

compilerrt-arm-configure: ${ARMSTATE}/compilerrt-configure
${ARMSTATE}/compilerrt-configure: ${LLVMSTATE}/compilerrt-patch ${LLVMSTATE}/cmake-build
	@$(call banner, "Configure Compiler-rt...")
	@mkdir -p ${COMPILERRTBUILDDIR}
	(cd ${COMPILERRTBUILDDIR} && ${LLVMINSTALLDIR}/bin/cmake -DCMAKE_BUILD_TYPE=Release  -DCMAKE_INSTALL_PREFIX=${LLVMINSTALLDIR} -DCLANG_PATH_TO_LLVM_SOURCE=${LLVMDIR}   -DCLANG_PATH_TO_LLVM_BUILD=${LLVMINSTALLDIR}   ${COMPILERRTDIR} )
	$(call state,$@,compilerrt-arm-build)

compilerrt-arm-build: ${LLVMSTATE}/compilerrt-build
${ARMSTATE}/compilerrt-build: ${ARMSTATE}/compilerrt-configure
	@$(call banner, "Building Compiler-rt...")
	@mkdir -p ${COMPILERRTNSTALLDIR} ${COMPILERRTBUILDDIR}
	(cd ${COMPILERRTBUILDDIR} && make -j${JOBS} install)
	$(call state,$@,compiilerrt-build)

