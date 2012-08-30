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

.PHONY: initramfs-prep initramfs initramfs-clean ltp dash

INITRAMFS	= initramfs.img.gz
BUILDDIR	= ${TARGETDIR}/initramfs
BUILDFSDIR	= ${BUILDDIR}/initramfs
CPIO		= ${BUILDFSDIR}.cpio

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

SETTINGS_TARGETS+= initramfs-settings

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

${CPIO}: toybox dash 
	@rm -rf ${BUILDFSDIR}
	@mkdir -p $(addprefix ${BUILDFSDIR}/,bin sys dev proc tmp usr/bin)
	@PREFIX=${BUILDFSDIR} make -C ${BUILDDIR}/${TOYBOX} install
	@make -C ${BUILDDIR}/${DASH} install
	@ln -sf bin/dash ${BUILDFSDIR}/init
	@(cd ${BUILDFSDIR} && find . | cpio -H newc -o > ${CPIO})
#	@cp ${INITRAMFSDIR}/bin/ls ${BUILDFSDIR}/usr/bin
#	@(cd ${BUILDDIR}/${LTP} && make install)


initramfs: ${INITRAMFS}
${INITRAMFS}: ${CPIO}
	@cat $< | gzip -9c > $@
	@echo "Created $@: Done."

initramfs-clean:
	rm -rf initramfs.img.gz $(addprefix ${BUILDDIR}/,initramfs initramfs-build ${DASH}* ${TOYBOX}* ${LTP}*)

initramfs-mrproper:
	rm -rf ${BUILDDIR}

toybox: ${BUILDDIR}/${TOYBOX}/toybox
${BUILDDIR}/${TOYBOX}/toybox:
	@wget -P ${BUILDDIR} -c ${TOYBOXURL}
	@rm -rf ${BUILDDIR}/${TOYBOX}
	(cd ${BUILDDIR} && tar xjf ${TOYBOX}.tar.bz2)
	(cd ${BUILDDIR}/${TOYBOX} && CFLAGS="--static" CC=${GCC} CROSS_COMPILE=${CROSS_COMPILE} PREFIX=${BUILDFSDIR} make defconfig toybox)

# && cd ${TOYBOX} && patch -p1 < ${INITRAMFSDIR}/patches/toybox.patch)

dash: ${BUILDDIR}/${DASH}/src/dash
${BUILDDIR}/${DASH}/src/dash:
	env
	@wget -P ${BUILDDIR} -c ${DASHURL}
	@rm -rf ${BUILDDIR}/${DASH}
	(cd ${BUILDDIR} && tar xzf ${DASH}.tar.gz)
	(cd ${BUILDDIR}/${DASH} && ./configure --prefix=${BUILDFSDIR} --host=${HOST})
	(cd ${BUILDDIR}/${DASH} && make CFLAGS="-static")

ltp: ${BUILDDIR}/${LTP}/Version
${BUILDDIR}/${LTP}/Version:
	@wget -P ${BUILDDIR} -c ${LTPURL}
	@rm -rf ${BUILDDIR}/${LTP}
	(cd ${BUILDDIR} && tar xjf ${LTP}.bz2 && cd ${LTP} && patch -p1 < ${INITRAMFSDIR}/patches/ltp.patch)
	(cd ${BUILDDIR}/${LTP} && CFLAGS="-D_GNU_SOURCE=1 -std=gnu89" CC=${GCC} CPP="${CPP}" ./configure --prefix=${BUILDFSDIR} --without-expect --without-perl --without-python --host=${HOST})
	(cd ${BUILDDIR}/${LTP} && make)
