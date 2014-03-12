##############################################################################
# Copyright (c) 2014 Mark Charlebois
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
#
# Based on directions from: http://llvm.org/docs/HowToCrossCompileLLVM.html
#
##############################################################################
ARMINSTALLDIR	= ${LLVMTOP}/arm/install
ARMLIBDIR	= ${LLVMTOP}/arm/chroot/usr/lib
ARMINCLUDEDIR	= ${LLVMTOP}/arm/chroot/usr/include
ARMBUILDDIR	= ${LLVMTOP}/arm/build
PATH		+= ${LLVMINSTALLDIR}/bin
ARM_CC		= arm-linux-gnueabihf-gcc

DEBDEP += cmake ninja-build gcc-4.7-arm-linux-gnueabihf \
	gcc-4.7-multilib-arm-linux-gnueabihf binutils-arm-linux-gnueabihf \
	libgcc1-armhf-cross libsfgcc1-armhf-cross libstdc++6-armhf-cross \
	libstdc++6-4.7-dev-armhf-cross

clang-arm: ${LLVMSTATE}/clang-arm-build 
${LLVMSTATE}/clang-arm-build: ${LLVMSTATE}/clang-build
	$(shell mkdir -p ${ARMINSTALLDIR})
	$(shell mkdir -p ${ARMBUILDDIR})
	[ -d ${ARMLIBDIR} ] || (echo "missing ARMLIBDIR" && false)
	[ -d ${ARMINCLUDEDIR} ] || (echo "missing ARMINCLUDEDIR" && false)
	cd ${ARMBUILDDIR} && CC=${LLVMINSTALLDIR}/bin/clang CXX=${LLVMINSTALLDIR}/bin/clang++ cmake -G Ninja ${LLVMTOP}/src/llvm -DCMAKE_CROSSCOMPILING=True \
		-DCMAKE_INSTALL_PREFIX=${ARMINSTALLDIR} \
		-DLLVM_TABLEGEN=${LLVMINSTALLDIR}/bin/llvm-tblgen \
		-DCLANG_TABLEGEN=${LLVMINSTALLDIR}/bin/clang-tblgen \
		-DLLVM_DEFAULT_TARGET_TRIPLE=arm-linux-gnueabihf \
		-DLLVM_TARGET_ARCH=ARM \
		-DLLVM_TARGETS_TO_BUILD=ARM \
		-DCMAKE_CXX_FLAGS='-target armv7a-linux-gnueabihf -mcpu=cortex-a9 -I/usr/arm-linux-gnueabihf/include/c++/4.7.2/arm-linux-gnueabihf/ -I/usr/arm-linux-gnueabihf/include/ -I${ARMINCLUDEDIR} -L${ARMLIBDIR} -mfloat-abi=hard -ccc-gcc-name ${ARM_CC}'
	@cd ${ARMBUILDDIR} && ninja
	cd ${ARMBUILDDIR} && CC=${LLVMINSTALLDIR}/bin/clang CXX=${LLVMINSTALLDIR}/bin/clang++ cmake -G Ninja ${LLVMTOP}/src/clang -DCMAKE_CROSSCOMPILING=True \
		-DCMAKE_INSTALL_PREFIX=${ARMINSTALLDIR} \
		-DLLVM_TABLEGEN=${LLVMINSTALLDIR}/bin/llvm-tblgen \
		-DCLANG_TABLEGEN=${LLVMINSTALLDIR}/bin/clang-tblgen \
		-DLLVM_DEFAULT_TARGET_TRIPLE=arm-linux-gnueabihf \
		-DLLVM_TARGET_ARCH=ARM \
		-DLLVM_TARGETS_TO_BUILD=ARM \
		-DCMAKE_CXX_FLAGS='-target armv7a-linux-gnueabihf -mcpu=cortex-a9 -I/usr/arm-linux-gnueabihf/include/c++/4.7.2/arm-linux-gnueabihf/ -I/usr/arm-linux-gnueabihf/include/ -I${ARMINCLUDEDIR} -L${ARMLIBDIR} -mfloat-abi=hard -ccc-gcc-name ${ARM_CC}'
	@cd ${ARMBUILDDIR} && ninja
	$(call state,$@)

