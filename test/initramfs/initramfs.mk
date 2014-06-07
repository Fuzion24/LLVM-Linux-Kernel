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

.PHONY: initramfs-prep initramfs initramfs-clean ltp

INITRAMFS	= initramfs.img.gz
INITBUILDDIR	= ${TARGETDIR}/initramfs
INITTMPDIR	= $(call shared,${INITBUILDDIR}/tmp)
INITBUILDFSDIR	= ${INITBUILDDIR}/initramfs_root
INITCPIO	= ${INITBUILDFSDIR}.cpio

TMPDIRS		+= ${INITTMPDIR}

LTPVER		= 20120104
LTP		= ltp-full-${LTPVER}
LTPEXT		= .bz2
LTPURL		= http://prdownloads.sourceforge.net/ltp/${LTP}${LTPEXT}?download
LTPFILE		= ${INITTMPDIR}/${LTP}${LTPEXT}
INITBUILDLTP	= ${INITBUILDDIR}/${LTP}
STRACEURL	=
STRACEBIN 	=

# Set the busybox URL depending on the target ARCH
ifeq (${ARCH},)
BUSYBOXURL	= "http://busybox.net/downloads/binaries/1.20.0/busybox-i586"
else
ARCHSTR=${ARCH}
ifeq (${ARCH},arm)
ARCHSTR=armv6l
STRACEURL	= "http://android-group-korea.googlecode.com/files/strace"
STRACEBIN	= ${INITBUILDDIR}/strace
endif
BUSYBOXURL	= "http://busybox.net/downloads/binaries/1.20.0/busybox-${ARCHSTR}"

endif

GCC		?= gcc
CPP		?= ${CC} -E

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

initramfs-unpacked: ${INITBUILDFSDIR}/etc
${INITBUILDFSDIR}/etc: ${INITBUILDDIR}/busybox ${STRACEBIN} ${KERNEL_MODULES}
	@rm -rf ${INITBUILDFSDIR}
	@mkdir -p $(addprefix ${INITBUILDFSDIR}/,bin sys dev proc tmp usr/bin sbin usr/sbin)
	@cp -r ${INITRAMFSDIR}/etc ${INITBUILDFSDIR}
	@cp -r ${INITRAMFSDIR}/bootstrap ${INITBUILDFSDIR}/init
	@cp ${INITBUILDDIR}/busybox ${INITBUILDFSDIR}/bin/busybox
	(cd ${INITBUILDFSDIR}/bin && ln -s busybox sh)


initramfs initramfs-build: ${INITRAMFS}
${INITRAMFS}: ${INITBUILDFSDIR}/etc
	@(cd ${INITBUILDFSDIR} && find . | cpio -H newc -o > ${INITCPIO})
	@(if test -e /usr/bin/pigz; then cat ${INITCPIO} | pigz -9c > $@ ; else cat ${INITCPIO} | gzip -9c > $@ ; fi )
	@echo "Created $@: Done."

initramfs-clean:
	@$(call banner,Clean initramfs...)
	rm -rf ${INITRAMFS} $(addprefix ${INITBUILDDIR}/,initramfs initramfs-build ${LTP}*)

#	([ -f ${INITBUILDDIR}/busybox/Makefile ] && cd ${INITBUILDDIR}/busybox && make clean || rm -rf ${INITBUILDDIR}/busybox)

initramfs-mrproper initramfs-raze:
	@$(call banner,Scrub initramfs...)
	@$(call initramfs-busybox-clean, removing busybox)
	rm -f ${INITRAMFS}
	rm -rf ${INITBUILDDIR}
	rm -rf ${INITTMPDIR}

${INITBUILDDIR}:
	mkdir -p ${INITBUILDDIR}

${INITTMPDIR}:
	mkdir -p ${INITTMPDIR}

${INITBUILDDIR}/strace: ${INITTMPDIR}/strace
	cp ${INITTMPDIR}/strace ${INITBUILDDIR}/strace
	@chmod +x ${INITBUILDDIR}/strace

${INITTMPDIR}/strace: ${INITTMPDIR} ${INITBUILDDIR}
	(if test ! -e ${INITTMPDIR}/strace ; then $(call wget,${STRACEURL},$(dir $@)) ; fi )

${INITBUILDDIR}/busybox: ${INITTMPDIR}/busybox
	cp ${INITTMPDIR}/busybox ${INITBUILDDIR}/busybox
	@chmod +x ${INITBUILDDIR}/busybox

${INITTMPDIR}/busybox: ${INITTMPDIR} ${INITBUILDDIR}
	(if test ! -e ${INITTMPDIR}/busybox ; then $(call wget,${BUSYBOXURL},$(dir $@)) ; fi )

initramfs-busybox-clean:
	rm -f ${INITTMPDIR}/busybox ${INITBUILDDIR}/busybox
	rm state/busybox

${LTPFILE}:
	@$(call wget,$LTPURL,$(dir $@))

ltp: ${INITBUILDLTP}/Version
${INITBUILDLTP}/Version: ${LTPFILE}
	@mkdir -p ${INITBUILDDIR}
	@rm -rf ${INITBUILDLTP}
	tar -C ${INITBUILDDIR} -x -j -f ${LTPFILE}
	cd ${INITBUILDLTP} && patch -p1 < ${INITRAMFSDIR}/patches/ltp.patch
	(cd ${INITBUILDLTP} && CFLAGS="-D_GNU_SOURCE=1 -std=gnu89" CC=${GCC} CPP="${CPP}" ./configure --prefix=${INITBUILDFSDIR} --without-expect --without-perl --without-python --host=${HOST})
	make -C ${INITBUILDLTP}
