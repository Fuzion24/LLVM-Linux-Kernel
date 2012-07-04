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

# Assumes has been included from ../test.mk

QEMUSRCDIR=${QEMUDIR}/src
INSTALLDIR=${QEMUDIR}/install
QEMUBUILDDIR=${QEMUDIR}/build/qemu
QEMUSTATE=${QEMUDIR}/state
SYNC_TARGETS+=qemu-sync

TARGETS+= qemu-fetch qemu-configure qemu-build qemu-clean qemu-sync
.PHONY: qemu-fetch qemu-configure qemu-build qemu-clean qemu-sync

QEMU_GIT="git://git.qemu.org/qemu.git"
QEMU_BRANCH="stable-1.0"

qemu-fetch: ${QEMUSTATE}/qemu-fetch
${QEMUSTATE}/qemu-fetch:
	@mkdir -p ${QEMUSRCDIR}
	(cd ${QEMUSRCDIR} && git clone ${QEMU_GIT} -b ${QEMU_BRANCH})
	$(call state,$@)

qemu-configure: ${QEMUSTATE}/qemu-configure
${QEMUSTATE}/qemu-configure: ${QEMUSTATE}/qemu-fetch
	@mkdir -p ${QEMUBUILDDIR}
	(cd ${QEMUBUILDDIR} && ${QEMUSRCDIR}/qemu/configure \
		--target-list=arm-softmmu,mips-softmmu,i386-softmmu,x86_64-softmmu --disable-kvm \
		--disable-sdl --audio-drv-list="" --audio-card-list="" \
		--disable-docs --prefix=${INSTALLDIR})
	$(call state,$@)

qemu-build: ${QEMUSTATE}/qemu-build
${QEMUSTATE}/qemu-build: ${QEMUSTATE}/qemu-configure
	@mkdir -p ${INSTALLDIR}
	(cd ${QEMUBUILDDIR} && make -j${JOBS} install)
	$(call state,$@)
	
qemu-clean: ${QEMUSTATE}/qemu-fetch
	rm -rf ${QEMUBUILDDIR} 
	rm -f ${QEMUSTATE}/qemu-configure ${QEMUSTATE}/qemu-build
	
qemu-sync: ${QEMUSTATE}/qemu-fetch
	@make qemu-clean
	(cd ${QEMUSRCDIR}/qemu && git checkout ${QEMU_BRANCH} && git pull)
