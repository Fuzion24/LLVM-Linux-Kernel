##############################################################################
# Copyright (c) 2012 Mark Charlebois
# Copyright (c) 2012 Behan Webster
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

# NOTE: CROSS_COMPILE, HOST and CC must be defined by <arch>.mk

TARGETS_TEST	+= initramfs initramfs-clean
CLEAN_TARGETS	+= initramfs-clean
MRPROPER_TARGETS+= initramfs-mrproper
RAZE_TARGETS	+= initramfs-raze

.PHONY: initramfs-prep initramfs initramfs-clean ltp busybox

INITRAMFS	= initramfs.img.gz
INITBUILDDIR	= ${TARGETDIR}/initramfs
INITBUILDFSDIR	= ${INITBUILDDIR}/initramfs
INITCPIO	= ${INITBUILDFSDIR}.cpio

LTPVER		= 20120104
LTP			= ltp-full-${LTPVER}
LTPURL		= http://prdownloads.sourceforge.net/ltp/${LTP}.bz2?download
BUSYBOX		= ${INITBUILDDIR}/busybox/_install/bin/busybox
BUSYBOXGIT	= git://busybox.net/busybox.git

GCC		= gcc

HELP_TARGETS	+= initramfs-help
SETTINGS_TARGETS+= initramfs-settings

initramfs-help:
	@echo
	@echo "These are the make targets for building a basic testing initramfs:"
	@echo "* make initramfs-[build,clean]"

initramfs-settings:
	@echo "# initramfs settings"
#	@$(call prsetting,LTPVER,${LTPVER})
#	@$(call prsetting,LTP,${LTP})
#	@$(call prsetting,LTPURL,${LTPURL})

initramfs-unpacked: ${BUSYBOX}
${INITBUILDFSDIR}/etc: ${BUSYBOX} ${KERNEL_MODULES}
	@rm -rf ${INITBUILDFSDIR}
	@mkdir -p $(addprefix ${INITBUILDFSDIR}/,bin sys dev proc tmp usr/bin)
	@cp -ar ${INITBUILDDIR}/busybox/_install/* ${INITBUILDFSDIR}
	@cp -r ${INITRAMFSDIR}/etc ${INITBUILDFSDIR}
	@cp  /etc/resolv.conf ${INITBUILDFSDIR}/etc

initramfs initramfs-build: ${INITRAMFS}
${INITRAMFS}: ${INITBUILDFSDIR}/etc
	@(cd ${INITBUILDFSDIR} && find . | cpio -H newc -o > ${INITCPIO})
	@cat ${INITCPIO} | gzip -9c > $@
	@echo "Created $@: Done."

initramfs-clean:
	@$(call banner,Clean initramfs...)
	rm -rf ${INITRAMFS} $(addprefix ${INITBUILDDIR}/,initramfs initramfs-build ${LTP}*)
	([ -f ${INITBUILDDIR}/busybox/Makefile ] && cd ${INITBUILDDIR}/busybox && make clean || rm -rf ${INITBUILDDIR}/busybox)

initramfs-mrproper initramfs-raze:
	@$(call banner,Scrub initramfs...)
	rm -f ${INITRAMFS}
	rm -rf ${INITBUILDDIR}

busybox: ${BUSYBOX}
${BUSYBOX}:
	([ ! -d ${INITBUILDDIR} ] && mkdir -p ${INITBUILDDIR})
	([ ! -f ${INITBUILDDIR}/busybox/.git/config ] && (cd ${INITBUILDDIR} && git clone ${BUSYBOXGIT}) || \
		(cd ${INITBUILDDIR}/busybox && git pull))
	(cd ${INITBUILDDIR}/busybox && LDFLAGS="--static" make -j ${JOBS} CROSS_COMPILE="${HOST}-" defconfig)
	(cd ${INITBUILDDIR}/busybox && LDFLAGS="--static" make -j ${JOBS} CROSS_COMPILE="${HOST}-")
	(cd ${INITBUILDDIR}/busybox && LDFLAGS="--static" make -j ${JOBS} CROSS_COMPILE="${HOST}-" install)


ltp: ${INITBUILDDIR}/${LTP}/Version
${INITBUILDDIR}/${LTP}/Version:
	@wget -P ${INITBUILDDIR} -c ${LTPURL}
	@rm -rf ${INITBUILDDIR}/${LTP}
	(cd ${INITBUILDDIR} && tar xjf ${LTP}.bz2 && cd ${LTP} && patch -p1 < ${INITRAMFSDIR}/patches/ltp.patch)
	(cd ${INITBUILDDIR}/${LTP} && CFLAGS="-D_GNU_SOURCE=1 -std=gnu89" CC=${GCC} CPP="${CPP}" ./configure --prefix=${INITBUILDFSDIR} --without-expect --without-perl --without-python --host=${HOST})
	(cd ${INITBUILDDIR}/${LTP} && make)
