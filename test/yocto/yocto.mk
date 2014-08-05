##############################################################################
# Copyright (c) 2014 Mark Charlebois
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
YOCTOOECORE=${YOCTODIR}/openembedded/jenkins-setup/openembedded-core
YOCTOAARCH64=${YOCTODIR}/build/aarch64

yocto-fetch: ${YOCTODIR}/state/yocto-fetch
${YOCTODIR}/state/yocto-fetch:
	mkdir -p ${YOCTODIR}/openembedded
	(cd ${YOCTODIR}/openembedded && git clone git://git.linaro.org/openembedded/jenkins-setup.git)
	(cd ${YOCTODIR}/openembedded/jenkins-setup && bash init-and-build.sh)
	mkdir -p $(dir $@)
	touch $@

${YOCTOAARCH64}:
	mkdir -p $@

yocto-aarch64-build: ${YOCTODIR}/state/yocto-fetch ${YOCTOAARCH64}
	mkdir -p ${YOCTOAARCH64}
	-(cd ${YOCTOOECORE} && source oe-init-build-env ${YOCTOAARCH64)
	(cd ${YOCTOOECORE} && source oe-init-build-env  ${YOCTOAARCH64} && 
	echo IMAGE_FSTYPES = "tar.gz cpio.gz" >> ${YOCTOAARCH64}/conf/local.conf && 
	echo TCMODE = "external-linaro" >> ${YOCTOAARCH64}/conf/local.conf
	echo ELT_TARGET_SYS = "aarch64-linux-gnu" >> ${YOCTOAARCH64}/conf/local.conf && 
	echo EXTERNAL_TOOLCHAIN = "${TOPDIR}/arch/aarch64/toolchain/linaro/gcc-linaro-aarch64-linux-gnu-4.8-2013.06_linux" >> ${YOCTOAARCH64}/conf/local.conf &&
	bitbake linaro-image-minimal)
	

