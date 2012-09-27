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

TARGETS		+= initramfs initramfs-clean
CLEAN_TARGETS	+= initramfs-clean
MRPROPER_TARGETS+= initramfs-mrproper
RAZE_TARGETS	+= initramfs-raze

.PHONY: initramfs-prep initramfs initramfs-clean ltp dash

INITRAMFS	= initramfs.img.gz
INITBUILDDIR	= ${TARGETDIR}/initramfs
INITBUILDFSDIR	= ${INITBUILDDIR}/initramfs
INITCPIO	= ${INITBUILDFSDIR}.cpio

TOYBOXVER	= 0.4.0
TOYBOX		= toybox-${TOYBOXVER}
TOYBOXURL	= http://landley.net/toybox/downloads/${TOYBOX}.tar.bz2
DASHVER		= 0.5.7
DASH		= dash-${DASHVER}
DASHURL		= http://gondor.apana.org.au/~herbert/dash/files/${DASH}.tar.gz
LTPVER		= 20120104
LTP		= ltp-full-${LTPVER}
LTPURL		= http://prdownloads.sourceforge.net/ltp/${LTP}.bz2?download

GCC		= gcc

HELP_TARGETS	+= initramfs-help
SETTINGS_TARGETS+= initramfs-settings

initramfs-help:
	@echo
	@echo "These are the make targets for building a basic testing initramfs:"
	@echo "* make initramfs-[build,clean]"

initramfs-settings:
	@echo "# initramfs settings"
	@echo "TOYBOXVER		= ${TOYBOXVER}"
	@echo "TOYBOX			= ${TOYBOX}"
	@echo "TOYBOXURL		= ${TOYBOXURL}"
	@echo "DASHVER			= ${DASHVER}"
	@echo "DASH			= ${DASH}"
	@echo "DASHURL			= ${DASHURL}"
#	@echo "LTPVER			= ${LTPVER}"
#	@echo "LTP			= ${LTP}"
#	@echo "LTPURL			= ${LTPURL}"

${INITCPIO}: toybox dash 
	@rm -rf ${INITBUILDFSDIR}
	@mkdir -p $(addprefix ${INITBUILDFSDIR}/,bin sys dev proc tmp usr/bin)
	@PREFIX=${INITBUILDFSDIR} make -C ${INITBUILDDIR}/${TOYBOX} install
	@make -C ${INITBUILDDIR}/${DASH} install
	@ln -sf bin/dash ${INITBUILDFSDIR}/init
	@(cd ${INITBUILDFSDIR} && find . | cpio -H newc -o > ${INITCPIO})
#	@cp ${INITRAMFSDIR}/bin/ls ${INITBUILDFSDIR}/usr/bin
#	@(cd ${INITBUILDDIR}/${LTP} && make install)


initramfs initramfs-build: ${INITRAMFS}
${INITRAMFS}: ${INITCPIO}
	@cat $< | gzip -9c > $@
	@echo "Created $@: Done."

initramfs-clean:
	@$(call banner,Clean initramfs...)
	rm -rf ${INITRAMFS} $(addprefix ${INITBUILDDIR}/,initramfs initramfs-build ${DASH}* ${TOYBOX}* ${LTP}*)

initramfs-mrproper initramfs-raze:
	@$(call banner,Scrub initramfs...)
	rm -f ${INITRAMFS}
	rm -rf ${INITBUILDDIR}

toybox: ${INITBUILDDIR}/${TOYBOX}/toybox
${INITBUILDDIR}/${TOYBOX}/toybox:
	@wget -P ${INITBUILDDIR} -c ${TOYBOXURL}
	@rm -rf ${INITBUILDDIR}/${TOYBOX}
	(cd ${INITBUILDDIR} && tar xjf ${TOYBOX}.tar.bz2)
	(cd ${INITBUILDDIR}/${TOYBOX} && CFLAGS="--static" CC=${GCC} CROSS_COMPILE=${CROSS_COMPILE} PREFIX=${INITBUILDFSDIR} make defconfig toybox)

# && cd ${TOYBOX} && patch -p1 < ${INITRAMFSDIR}/patches/toybox.patch)

dash: ${INITBUILDDIR}/${DASH}/src/dash
${INITBUILDDIR}/${DASH}/src/dash:
	env
	@wget -P ${INITBUILDDIR} -c ${DASHURL}
	@rm -rf ${INITBUILDDIR}/${DASH}
	(cd ${INITBUILDDIR} && tar xzf ${DASH}.tar.gz)
	(cd ${INITBUILDDIR}/${DASH} && ./configure --prefix=${INITBUILDFSDIR} --host=${HOST})
	(cd ${INITBUILDDIR}/${DASH} && make CFLAGS="-static")

ltp: ${INITBUILDDIR}/${LTP}/Version
${INITBUILDDIR}/${LTP}/Version:
	@wget -P ${INITBUILDDIR} -c ${LTPURL}
	@rm -rf ${INITBUILDDIR}/${LTP}
	(cd ${INITBUILDDIR} && tar xjf ${LTP}.bz2 && cd ${LTP} && patch -p1 < ${INITRAMFSDIR}/patches/ltp.patch)
	(cd ${INITBUILDDIR}/${LTP} && CFLAGS="-D_GNU_SOURCE=1 -std=gnu89" CC=${GCC} CPP="${CPP}" ./configure --prefix=${INITBUILDFSDIR} --without-expect --without-perl --without-python --host=${HOST})
	(cd ${INITBUILDDIR}/${LTP} && make)
