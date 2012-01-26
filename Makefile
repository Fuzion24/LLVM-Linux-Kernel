##############################################################################
# Copyright (c) 2012 Mark Charlebois
#               2012 Jan-Simon Möller
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

CWD=${CURDIR}
SRCDIR:=${CWD}/src
INSTALLDIR:=${CWD}/install
LLVMBUILDDIR:=${CWD}/build/llvm
QEMUBUILDDIR:=${CWD}/build/qemu
CFGDIR=${CWD}/config

.PHONY: clang-fetch clang-configure clang-build qemu-fetch qemu-configure \
	qemu-build 


all: clang-build qemu-build

LLVM_GIT="http://llvm.org/git/llvm.git"
CLANG_GIT="http://llvm.org/git/clang.git"
LLVM_RELEASE="release_30"

clang-fetch: state/clang-fetch
state/clang-fetch:
	@mkdir -p ${SRCDIR}
	(cd ${SRCDIR} && git clone ${LLVM_GIT} -b ${LLVM_RELEASE})
	(cd ${SRCDIR}/llvm/tools && git clone ${CLANG_GIT} -b ${LLVM_RELEASE})
	@mkdir -p state
	@touch $@

clang-configure: state/clang-configure
state/clang-configure: state/clang-fetch
	@mkdir -p ${LLVMBUILDDIR}
	(cd ${LLVMBUILDDIR} && CC=gcc CXX=g++ ${SRCDIR}/llvm/configure \
		--target=arm-linux --enable-targets=arm --disable-shared \
		--enable-languages=c,c++ --enable-bindings=none \
		--prefix=${INSTALLDIR} target_alias=arm-linux)
	@mkdir -p state
	@touch $@

clang-build:  state/clang-build
state/clang-build: state/clang-configure
	@mkdir -p ${INSTALLDIR}
	(cd ${LLVMBUILDDIR} && make -j2 install)
	@mkdir -p state
	@touch $@

QEMU_GIT="git://git.qemu.org/qemu.git"
QEMU_VERSION="v0.15.1"

qemu-fetch: state/qemu-fetch
state/qemu-fetch:
	@mkdir -p ${SRCDIR}
	(cd ${SRCDIR} && git clone ${QEMU_GIT} && cd qemu && git checkout ${QEMU_VERSION})
	@mkdir -p state
	@touch $@

qemu-configure: state/qemu-configure
state/qemu-configure: state/qemu-fetch
	@mkdir -p ${QEMUBUILDDIR}
	(cd ${QEMUBUILDDIR} && ${SRCDIR}/qemu/configure \
		--target-list=arm-softmmu,mips-softmmu --disable-kvm \
		--disable-sdl --audio-drv-list="" --audio-card-list="" \
		--disable-docs --prefix=${INSTALLDIR})
	@mkdir -p state
	@touch $@

qemu-build: state/qemu-build
state/qemu-build: state/qemu-configure
	@mkdir -p ${INSTALLDIR}
	(cd ${QEMUBUILDDIR} && make -j8 install)
	@mkdir -p state
	@touch $@
	
versatile: qemu-build clang-build
	(cd targets/versatile && make)

msm: clang-build
	(cd targets/msm && make)

