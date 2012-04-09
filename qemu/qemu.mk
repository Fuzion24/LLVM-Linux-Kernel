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

# NOTE: TOPQEMUDIR must be defined by the calling Makefile

TOPQEMUDIR=${TOPDIR}/qemu
QEMUSRCDIR=${TOPQEMUDIR}/src
INSTALLDIR=${TOPQEMUDIR}/install
QEMUBUILDDIR=${TOPQEMUDIR}/build/qemu
QEMUSTATE=${TOPQEMUDIR}/state
SYNC_TARGETS+=qemu-sync
JOBS:=${shell getconf _NPROCESSORS_ONLN}
ifeq "${JOBS}" ""
JOBS:=2
endif


TARGETS+= qemu-fetch qemu-configure qemu-build qemu-clean qemu-sync
.PHONY: qemu-fetch qemu-configure qemu-build 

QEMU_GIT="git://git.qemu.org/qemu.git"
QEMU_BRANCH="stable-1.0"

qemu-fetch: ${QEMUSTATE}/qemu-fetch
${QEMUSTATE}/qemu-fetch:
	@mkdir -p ${QEMUSRCDIR}
	(cd ${QEMUSRCDIR} && git clone ${QEMU_GIT} -b ${QEMU_BRANCH})
	@mkdir -p ${QEMUSTATE}
	@touch $@

qemu-configure: ${QEMUSTATE}/qemu-configure
${QEMUSTATE}/qemu-configure: ${QEMUSTATE}/qemu-fetch
	@mkdir -p ${QEMUBUILDDIR}
	(cd ${QEMUBUILDDIR} && ${QEMUSRCDIR}/qemu/configure \
		--target-list=arm-softmmu,mips-softmmu,i386-softmmu,x86_64-softmmu --disable-kvm \
		--disable-sdl --audio-drv-list="" --audio-card-list="" \
		--disable-docs --prefix=${INSTALLDIR})
	@mkdir -p ${QEMUSTATE}
	@touch $@

qemu-build: ${QEMUSTATE}/qemu-build
${QEMUSTATE}/qemu-build: ${QEMUSTATE}/qemu-configure
	@mkdir -p ${INSTALLDIR}
	(cd ${QEMUBUILDDIR} && make -j${JOBS} install)
	@mkdir -p ${QEMUSTATE}
	@touch $@
	
qemu-clean:
	rm -rf ${QEMUBUILDDIR} 
	rm -f ${QEMUSTATE}/qemu-configure ${QEMUSTATE}/qemu-build
	
qemu-sync:
	@make qemu-clean
	(cd ${QEMUSRCDIR}/qemu && git checkout ${QEMU_BRANCH} && git pull)
