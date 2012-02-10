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
# NOTE: TOPDIR and BUILDDIR must be defined by the calling Makefile

.Phony: prep ${BUILDDIR}/initramfs/sbin/toybox ${BUILDDIR}/initramfs/bin/dash ${BUILDDIR}/initramfs/init initramfs initramfs-clean ${BUILDDIR}/initramfs.cpio 

${BUILDDIR}/initramfs.cpio: prep ${BUILDDIR}/initramfs/sbin/toybox ${BUILDDIR}/initramfs/init
	@(cd ${BUILDDIR}/initramfs && mkdir -p bin sys dev proc tmp usr/bin)
	@cp ${TOPDIR}/initramfs/bin/ls ${BUILDDIR}/initramfs/usr/bin
	@(cd ${BUILDDIR}/initramfs && find . | cpio -H newc -o > ${BUILDDIR}/initramfs.cpio)
	
initramfs.img.gz: ${BUILDDIR}/initramfs.cpio
	@rm -f initramfs.img
	@cp ${BUILDDIR}/initramfs.cpio initramfs.img
	@gzip -9 initramfs.img

initramfs: 
	@test -f initramfs.img.gz || make initramfs.img.gz

initramfs-clean:
	@rm -rf ${BUILDDIR}/initramfs
	@rm -rf ${BUILDDIR}/initramfs-build
	@rm -rf ${BUILDDIR}/dash-0.5.7
	@rm -rf ${BUILDDIR}/toybox*
	@rm -f initramfs.img.gz

${BUILDDIR}/initramfs/sbin/toybox: 
	@test -f ${BUILDDIR}/tip.tar.bz2 || (cd ${BUILDDIR} && wget http://www.landley.net/hg/toybox/archive/tip.tar.bz2)
	@rm -rf ${BUILDDIR}/toybox*
	(cd ${BUILDDIR} && tar -xjf tip.tar.bz2)
	(cd ${BUILDDIR}/toybox* && CFLAGS=--static CC=${CC} CROSS_COMPILE=${CROSS_COMPILE} PREFIX=${BUILDDIR}/initramfs make defconfig toybox install)

${BUILDDIR}/initramfs/bin/dash: 
	@test -f ${BUILDDIR}/dash-0.5.7.tar.gz || (cd ${BUILDDIR} && wget http://gondor.apana.org.au/~herbert/dash/files/dash-0.5.7.tar.gz)
	@rm -rf ${BUILDDIR}/dash-0.5.7
	(cd ${BUILDDIR} && tar xzf ${BUILDDIR}/dash-0.5.7.tar.gz)
	(cd ${BUILDDIR}/dash-0.5.7 && CFLAGS="--static" CC=${CC} CPP="${CPP}" ./configure --prefix=${BUILDDIR}/initramfs --host=${HOST})
	(cd ${BUILDDIR}/dash-0.5.7 && make install)
	
${BUILDDIR}/initramfs/init: ${BUILDDIR}/initramfs/bin/dash
	(cd ${BUILDDIR}/initramfs && ln -s bin/dash init)

prep:
	@rm -rf ${BUILDDIR}/initramfs
	@mkdir ${BUILDDIR}/initramfs
