##############################################################################
# Copyright (c) 2012 Mark Charlebois
#               2012 Jan-Simon Möller
#               2012 Behan Webster
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

QEMUSRCDIR	= ${QEMUDIR}/src/qemu
INSTALLDIR	= ${QEMUDIR}/install
QEMUBUILDDIR	= ${QEMUDIR}/build/qemu
QEMUSTATE	= ${QEMUDIR}/state
QEMUPATCHES	= ${QEMUDIR}/patches

QEMUBINDIR	= ${INSTALLDIR}/bin

QEMU_TARGETS	= qemu qemu-fetch qemu-configure qemu-build qemu-clean qemu-sync

SYNC_TARGETS	+= qemu-sync
TARGETS		+= ${QEMU_TARGETS}
.PHONY:		${QEMU_TARGETS}

QEMU_GIT	= "git://git.qemu.org/qemu.git"
QEMU_BRANCH	= "stable-1.0"

qemu-fetch: ${QEMUSTATE}/qemu-fetch
${QEMUSTATE}/qemu-fetch:
	@$(call banner, "Fetching QEMU...")
	@mkdir -p ${QEMUSRCDIR}
	[ -d ${QEMUSRCDIR}/.git ] || (rm -rf ${QEMUSRCDIR} && git clone ${QEMU_GIT} -b ${QEMU_BRANCH} ${QEMUSRCDIR})
	$(call state,$@,qemu-patch)

qemu-patch: ${QEMUSTATE}/qemu-patch
${QEMUSTATE}/qemu-patch: ${QEMUSTATE}/qemu-fetch
	@$(call banner, "Patching QEMU...")
	@ln -sf ${QEMUPATCHES} ${QEMUSRCDIR}
	(cd ${QEMUSRCDIR} && quilt push -a)
	$(call state,$@,qemu-configure)

qemu-configure: ${QEMUSTATE}/qemu-configure
${QEMUSTATE}/qemu-configure: ${QEMUSTATE}/qemu-fetch
	@$(call banner, "Configure QEMU...")
	@mkdir -p ${QEMUBUILDDIR}
	(cd ${QEMUBUILDDIR} && ${QEMUSRCDIR}/configure \
		--target-list=arm-softmmu,mips-softmmu,i386-softmmu,x86_64-softmmu --disable-kvm \
		--disable-sdl --audio-drv-list="" --audio-card-list="" \
		--disable-docs --prefix=${INSTALLDIR})
	$(call state,$@,qemu-build)

qemu qemu-build: ${QEMUSTATE}/qemu-build
${QEMUSTATE}/qemu-build: ${QEMUSTATE}/qemu-configure
	@$(call banner, "Building QEMU...")
	@mkdir -p ${INSTALLDIR}
	(cd ${QEMUBUILDDIR} && make -j${JOBS} install)
	$(call state,$@)
	
qemu-clean: ${QEMUSTATE}/qemu-fetch
	rm -rf ${QEMUBUILDDIR} 
	rm -f $(addprefix ${QEMUSTATE}/,qemu-configure,qemu-build)
	
qemu-sync: ${QEMUSTATE}/qemu-fetch
	@make qemu-clean
	(cd ${QEMUSRCDIR} && git checkout ${QEMU_BRANCH} && git pull)
