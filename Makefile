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

CWD=${CURDIR}
SRCDIR:=${CWD}/src
INSTALLDIR:=${CWD}/install
LLVMBUILDDIR:=${CWD}/build/llvm
QEMUBUILDDIR:=${CWD}/build/qemu
KERNELDIR=${SRCDIR}/linux
MSMDIR=${SRCDIR}/msm
CFGDIR=${CWD}/config

.PHONY: clang-fetch clang-configure clang-build qemu-fetch qemu-configure \
	qemu-build kernel-fetch kernel-configure kernel-build msm-fetch \
	msm-patch msm-configure msm-build test

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
	(cd ${SRCDIR} && git clone ${QEMU_GIT} && git checkout ${QEMU_VERSION})
	@mkdir -p state
	@touch $@

qemu-configure: state/qemu-configure
state/qemu-configure: state/qemu-fetch
	@mkdir -p ${QEMUBUILDDIR}
	(cd ${QEMUBUILDDIR} && ${SRCDIR}/qemu/configure \
		--target-list=arm-softmmu --disable-kvm \
		--disable-sdl --audio-drv-list="" \ --audio-card-list="" \
		--disable-docs --prefix=${INSTALLDIR})
	@mkdir -p state
	@touch $@

qemu-build: state/qemu-build
state/qemu-build: state/qemu-configure
	@mkdir -p ${INSTALLDIR}
	(cd ${QEMUBUILDDIR} && make -j8 install)
	@mkdir -p state
	@touch $@
	
LINUS_KERNEL=git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git)

kernel-fetch: state/kernel-fetch
state/kernel-fetch:
	@mkdir -p ${SRCDIR}
	(cd ${SRCDIR} &&  git clone ${LINUS_KERNEL}
	@mkdir -p state
	@touch $@

kernel-patch: state/kernel-patch
state/kernel-patch: state/kernel-fetch
	(cd ${KERNELDIR} && patch -p1 < ${CFGDIR}/vexpress-llvm.patch)
	@mkdir -p state
	@touch $@

kernel-configure: state/kernel-configure
state/kernel-configure: state/kernel-patch
	@cp ${CFGDIR}/config_vexpress ${KERNELDIR}/.config
	(cd ${KERNELDIR} && make ARCH=arm oldconfig)
	@mkdir -p state
	@touch $@

kernel-build: state/kernel-build 
state/kernel-build: state/kernel-configure state/clang-build
	(cd ${KERNELDIR} && ${CFGDIR}/make-kernel.sh ${INSTALLDIR})
	@mkdir -p state
	@touch $@

MSM_KERNEL="git://codeaurora.org/kernel/msm.git -b msm-3.0"
MSM_BRANCH="msm-3.0"
MSM_PATCH=${CFGDIR}/msm-3.0-llvm.patch

msm-fetch: state/msm-fetch
state/msm-fetch: 
	@mkdir -p ${SRCDIR}
	(cd ${SRCDIR} && git clone ${MSM_KERNEL} -b ${MSM_BRANCH})
	@mkdir -p state
	@touch $@

msm-patch: state/msm-patch
state/msm-patch: state/msm-fetch
	(cd ${MSMDIR} && patch -p1 < ${MSM_PATCH})
	@mkdir -p state
	@touch $@

msm-configure: state/msm-configure
state/msm-configure: state/msm-patch
	@cp ${CFGDIR}/config_msm ${MSMDIR}/.config
	(cd ${MSMDIR} && make ARCH=arm oldconfig)
	@mkdir -p state
	@touch $@

msm-build: state/msm-build
state/msm-build: state/msm-configure
	(cd ${MSMDIR} && ${CFGDIR}/make-kernel.sh ${INSTALLDIR})
	@mkdir -p state
	@touch $@

test: state/kernel-build state/qemu-build
	@qemu-system-arm -kernel ${KERNELDIR}/arch/arm/boot/zImage \
		-initrd myinitrd -M vexpress-a9 -append 'console=earlycon \
		console=ttyAMA0,38400n8 earlyprintk init=/init' -nographic

