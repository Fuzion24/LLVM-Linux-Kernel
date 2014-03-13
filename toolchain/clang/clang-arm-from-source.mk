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
ARMLIBDIRS	= -L${LLVMTOP}/arm/chroot/usr/lib -L${LLVMTOP}/arm/chroot/usr/lib/arm-linux-gnueabihf -L${LLVMTOP}/arm/chroot/lib/arm-linux-gnueabihf -L${LLVMTOP}/arm/chroot/lib
ARMINCLUDEDIR	= ${LLVMTOP}/arm/chroot/usr/include
ARMLLVMBUILDDIR	= ${LLVMTOP}/arm/build/llvm
ARMCLANGBUILDDIR	= ${LLVMTOP}/arm/build/clang
LLVMBINDIR	= ${LLVMTOP}/build/llvm/bin
CLANGBINDIR	= ${LLVMTOP}/build/clang/bin

DEBDEP += cmake ninja-build gcc-4.8-arm-linux-gnueabihf \
	gcc-4.8-multilib-arm-linux-gnueabihf binutils-arm-linux-gnueabihf \
	libgcc1-armhf-cross libsfgcc1-armhf-cross libstdc++6-armhf-cross \
	libstdc++-4.8-dev-armhf-cross g++-4.8-arm-linux-gnueabihf

llvm-arm: ${LLVMSTATE}/llvm-arm-build 
${LLVMSTATE}/llvm-arm-build: ${LLVMSTATE}/clang-build
	$(shell mkdir -p ${ARMINSTALLDIR})
	$(shell mkdir -p ${ARMLLVMBUILDDIR})
	[ -d ${ARMLIBDIR} ] || (echo "missing ARMLIBDIR" && false)
	[ -d ${ARMINCLUDEDIR} ] || (echo "missing ARMINCLUDEDIR" && false)
	cd ${ARMLLVMBUILDDIR} && CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++-4.8 cmake -G Ninja ${LLVMTOP}/src/llvm -DCMAKE_CROSSCOMPILING=True \
		-DCMAKE_INSTALL_PREFIX=${ARMINSTALLDIR} \
		-DLLVM_TABLEGEN=${LLVMBINDIR}/llvm-tblgen \
		-DLLVM_DEFAULT_TARGET_TRIPLE=arm-linux-gnueabihf \
		-DLLVM_TARGET_ARCH=ARM \
		-DLLVM_TARGETS_TO_BUILD=ARM \
		-DCMAKE_CXX_FLAGS='-mcpu=cortex-a9 -I/usr/arm-linux-gnueabihf/include/c++/4.8.1/arm-linux-gnueabihf/ -I/usr/arm-linux-gnueabihf/include/ -I${ARMINCLUDEDIR} -mfloat-abi=hard'
	@cd ${ARMLLVMBUILDDIR} && ninja
	@cd ${ARMLLVMBUILDDIR} && ninja install
	$(call state,$@)

clang-arm: ${LLVMSTATE}/clang-arm-build 
${LLVMSTATE}/clang-arm-build: ${LLVMSTATE}/clang-build ${LLVMSTATE}/llvm-arm-build
	$(shell mkdir -p ${ARMCLANGBUILDDIR})
	cd ${ARMCLANGBUILDDIR} && CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++-4.8 cmake -G Ninja ${LLVMTOP}/src/clang -DCMAKE_CROSSCOMPILING=True \
		-DCMAKE_INSTALL_PREFIX=${ARMINSTALLDIR} \
		-DCLANG_TABLEGEN=${CLANGBINDIR}/clang-tblgen \
		-DLLVM_TARGETS_TO_BUILD=ARM \
		-DLLVM_LIBRARY_DIR=${ARMINSTALLDIR}/lib \
		-DLLVM_MAIN_INCLUDE_DIR=${ARMINSTALLDIR}/include \
		-DLIBXML2_INCLUDE_DIR=${LLVMTOP}/arm/chroot/usr/include \
		-DLIBXML2_LIBRARIES=${LLVMTOP}/arm/chroot/usr/lib/arm-linux-gnueabihf/libxml2.a \
		-DLLVM_CONFIG=${LLVMTOP}/arm/llvm-config \
		-DLLVM_TABLEGEN_EXE=${LLVMBINDIR}/llvm-tblgen \
		-DCMAKE_CXX_FLAGS='-mcpu=cortex-a9 -I/usr/arm-linux-gnueabihf/include/c++/4.8.1/arm-linux-gnueabihf/ -I/usr/arm-linux-gnueabihf/include/ -I${ARMINSTALLDIR}/include -L${ARMINSTALLDIR}/lib -I${ARMINCLUDEDIR} -mfloat-abi=hard'
	@cd ${ARMCLANGBUILDDIR} && ninja
	@cd ${ARMCLANGBUILDDIR} && ninja install
	$(call state,$@)
