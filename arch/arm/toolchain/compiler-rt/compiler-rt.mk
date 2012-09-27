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

COMPILERRT_LOCALGIT  = "${LLVMSRCDIR}/llvm/projects/compiler-rt/.git"

COMPILERRTSTATE		= ${ARCH_ARM_TOOLCHAIN}/compiler-rt/state

COMPILERRTPATCHES	= ${ARCH_ARM_TOOLCHAIN}/compiler-rt/patches
COMPILERRTDIR		= ${ARCH_ARM_TOOLCHAIN}/compiler-rt/build
COMPILERRTINSTALLDIR	= ${ARCH_ARM_TOOLCHAIN}/compiler-rt/install
TARGETS			+= compilerrt-arm-clone compilerrt-arm-patch compilerrt-arm-configure compilerrt-arm-build 

compilerrt-arm-clone: ${COMPILERRTSTATE}/compilerrt-arm-clone
${COMPILERRTSTATE}/compilerrt-arm-clone: ${LLVMSTATE}/compilerrt-fetch
	@$(call banner, "Cloning Compiler-rt for ARM build...")
	@mkdir -p ${COMPILERRTDIR}
	( [ -d ${COMPILERRTDIR}/compiler-rt/.git ] || (cd ${COMPILERRTDIR} && git clone ${COMPILERRT_LOCALGIT} -b ${COMPILERRT_BRANCH}))
	$(call state,$@)

compilerrt-arm-patch: ${COMPILERRTSTATE}/compilerrt-arm-patch
${COMPILERRTSTATE}/compilerrt-arm-patch: ${COMPILERRTSTATE}/compilerrt-arm-clone
	@$(call banner, "Patching Compiler-rt...")
	@ln -sf ${COMPILERRTPATCHES} ${COMPILERRTDIR}/compiler-rt/patches
	@$(call patch,${COMPILERRTDIR}/compiler-rt)
	$(call state,$@)

compilerrt-arm-build: ${COMPILERRTSTATE}/compilerrt-arm-build
${COMPILERRTSTATE}/compilerrt-arm-build: ${COMPILERRTSTATE}/compilerrt-arm-patch
	@$(call banner, "Building Compiler-rt...")
	@mkdir -p ${COMPILERRTINSTALLDIR}
	(cd ${COMPILERRTDIR}/compiler-rt && make ARMGCCHOME=${ARCH_ARM_TOOLCHAIN}/codesourcery/arm-2011.03 linux_armv7)
	$(call state,$@)

