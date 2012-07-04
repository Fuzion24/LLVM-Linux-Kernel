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

# NOTE: CROSS_COMPILE, HOST and CC must be defined by common-<arch>.mk
# NOTE: TOPDIR must be defined by the calling Makefile

TARGETS	+= initramfs initramfs-clean

.PHONY: initramfs-prep initramfs initramfs-clean ltp dash

BUILDDIR = ${TMPDIR}

TOYBOXVER=0.2.1
TOYBOX=toybox-${TOYBOXVER}
DASHVER=0.5.7
DASH=dash-${DASHVER}
LTPVER=20120104
LTP=ltp-full-${LTPVER}

${BUILDDIR}/initramfs.cpio: initramfs-prep toybox dash 
	@(cd ${BUILDDIR}/initramfs && mkdir -p bin sys dev proc tmp usr/bin)
	@(cd ${BUILDDIR}/${TOYBOX} && PREFIX=${BUILDDIR}/initramfs make install)
	@(cd ${BUILDDIR}/${DASH} && make install)
	@(cd ${BUILDDIR}/initramfs && ln -s bin/dash init)
	@(cd ${BUILDDIR}/initramfs && find . | cpio -H newc -o > ${BUILDDIR}/initramfs.cpio)

#	@cp ${TOPDIR}/initramfs/bin/ls ${BUILDDIR}/initramfs/usr/bin
#	@(cd ${BUILDDIR}/${LTP} && make install)

initramfs.img.gz: ${BUILDDIR}/initramfs.cpio
	@rm -f initramfs.img
	@cp ${BUILDDIR}/initramfs.cpio initramfs.img
	@gzip -9 initramfs.img

initramfs: 
	@test -f initramfs.img.gz || make initramfs.img.gz

initramfs-clean:
	@rm -rf ${BUILDDIR}/initramfs
	@rm -rf ${BUILDDIR}/initramfs-build
	@rm -rf ${BUILDDIR}/${DASH}
	@rm -rf ${BUILDDIR}/${TOYBOX}
	@rm -f initramfs.img.gz

toybox: ${BUILDDIR}/${TOYBOX}/toybox
${BUILDDIR}/${TOYBOX}/toybox:
	@test -f ${BUILDDIR}/${TOYBOX}.tar.bz2 || (cd ${BUILDDIR} && wget http://landley.net/toybox/downloads/toybox-0.2.1.tar.bz2)
	@rm -rf ${BUILDDIR}/${TOYBOX}
	(cd ${BUILDDIR} && tar -xjf ${TOYBOX}.tar.bz2)
	(cd ${BUILDDIR}/${TOYBOX} && CFLAGS="--static" CC=${CC} CROSS_COMPILE=${CROSS_COMPILE} PREFIX=${BUILDDIR}/initramfs make allyesconfig toybox)

# && cd ${TOYBOX} && patch -p1 < ${TOPDIR}/initramfs/toybox.patch)

dash: ${BUILDDIR}/${DASH}/src/dash
${BUILDDIR}/${DASH}/src/dash:
	@test -f ${BUILDDIR}/${DASH}.tar.gz || (cd ${BUILDDIR} && wget http://gondor.apana.org.au/~herbert/dash/files/${DASH}.tar.gz)
	@rm -rf ${BUILDDIR}/${DASH}
	(cd ${BUILDDIR} && tar xzf ${BUILDDIR}/${DASH}.tar.gz)
	(cd ${BUILDDIR}/${DASH} && CFLAGS="--static" CC=${CC} CPP="${CPP}" ./configure --prefix=${BUILDDIR}/initramfs --host=${HOST})
	(cd ${BUILDDIR}/${DASH} && make)

initramfs-prep:
	@rm -rf ${BUILDDIR}/initramfs
	@mkdir ${BUILDDIR}/initramfs

ltp: ${BUILDDIR}/${LTP}/Version
${BUILDDIR}/${LTP}/Version:
	@test -f ${BUILDDIR}/${LTP}.bz2 || (cd ${BUILDDIR} && wget -c http://prdownloads.sourceforge.net/ltp/${LTP}.bz2?download)
	@rm -rf ${BUILDDIR}/${LTP}
	(cd ${BUILDDIR} && tar xjf ${BUILDDIR}/${LTP}.bz2 && cd ${LTP} && patch -p1 < ${TOPDIR}/initramfs/ltp.patch)
	(cd ${BUILDDIR}/${LTP} && CFLAGS="-D_GNU_SOURCE=1 -std=gnu89" CC=${CC} CPP="${CPP}" ./configure --prefix=${BUILDDIR}/initramfs --without-expect --without-perl --without-python --host=${HOST})
	(cd ${BUILDDIR}/${LTP} && make)
