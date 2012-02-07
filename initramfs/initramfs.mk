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

# NOTE: MAKE_BINARY, BUILDDIR and TOPDIR must be defined by the calling Makefile

${BUILDDIR}/initramfs-build/init: ${TOPDIR}/initramfs/hello.c
	@rm -rf ${BUILDDIR}/initramfs
	@rm -rf ${BUILDDIR}/initramfs-build
	@mkdir ${BUILDDIR}/initramfs
	@mkdir ${BUILDDIR}/initramfs-build
	(cd ${BUILDDIR}/initramfs-build && ${MAKE_BINARY} -static ${TOPDIR}/initramfs/hello.c -o $@)

${BUILDDIR}/initramfs-build/initramfs.cpio: ${BUILDDIR}/initramfs-build/init
	@(cd ${BUILDDIR}/initramfs && mkdir bin sys dev proc)
	@cp ${BUILDDIR}/initramfs-build/init ${BUILDDIR}/initramfs/init
	@(cd ${BUILDDIR}/initramfs && find . | cpio -H newc -o > ${BUILDDIR}/initramfs-build/initramfs.cpio)
	
initramfs.img.gz: ${BUILDDIR}/initramfs-build/initramfs.cpio
	@cp ${BUILDDIR}/initramfs-build/initramfs.cpio initramfs.img
	@gzip -9 initramfs.img

