##############################################################################
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

# Assumes has been included from ../test.mk

LTPTMPDIR	= ${LTPDIR}/tmp
LTPSRCDIR	= ${LTPDIR}/src
TOPLTPINSTALLDIR= ${LTPDIR}/install
LTPINSTALLDIR	= ${TOPLTPINSTALLDIR}/opt/ltp
#LTPBUILDDIR	= ${LTPDIR}/build/ltp
LTPBUILDDIR	= ${LTPSRCDIR}/ltp
LTPSTATE	= ${LTPDIR}/state
LTPSCRIPTS	= ${LTPDIR}/scripts
SYNC_TARGETS	+= ltp-sync

LTP_TARGETS	= ltp-fetch ltp-configure ltp-build ltp-clean ltp-sync ltp-mrproper ltp-clean
TARGETS		+= ${LTP_TARGETS}
CLEAN_TARGETS	+= ltp-clean
SETTINGS_TARGETS+= ltp-settings
SYNC_TARGETS	+= ltp-sync
VERSION_TARGETS	+= ltp-version
.PHONY:		${LTP_TARGETS}

LTPCVS=":pserver:anonymous@ltp.cvs.sourceforge.net:/cvsroot/ltp"
LTPBRANCH="stable-1.0"

LTPSF_RELEASE=20120614
LTPSF_TAR=ltp-full-${LTPSF_RELEASE}.bz2
LTPSF_URI=http://downloads.sourceforge.net/project/ltp/LTP%20Source/ltp-${LTPSF_RELEASE}/${LTPSF_TAR}

ltpstate=mkdir -p ${LTPSTATE}; touch $(1); echo "Entering state $(notdir $(1))"; rm -f ${LTPSTATE}/ltp-$(2)

${LTPTMPDIR}/${LTPSF_TAR}:
	@mkdir -p $(dir $@)
	wget -nd -P $(dir $@) -c ${LTPSF_URI}

ltp-settings:
	@echo "# LTP settings"
	@echo "LTPSF_RELEASE		= ${LTPSF_RELEASE}"
	@echo "LTPSF_TAR		= ${LTPSF_TAR}"
	@echo "LTPSF_URI		= ${LTPSF_URI}"

ltp-fetch: ltp-sf
ltp-sf: ${LTPSTATE}/ltp-fetch
${LTPSTATE}/ltp-fetch: ${LTPTMPDIR}/${LTPSF_TAR}
	@mkdir -p ${LTPSRCDIR}
	@rm -rf ${LTPSRCDIR}/ltp
	tar -x -C ${LTPSRCDIR} -f $<
	ln -fs $(basename $(notdir ${LTPSF_TAR})) ${LTPSRCDIR}/ltp
	@$(call ltpstate,$@,configure)

ltp-cvs:
	@mkdir -p ${LTPSRCDIR}
	(cd ${LTPSRCDIR} && cvs -z3 -d ${LTPCVS} co -P ltp)

ltp-sync: ${LTPSTATE}/ltp-fetch
	@make ltp-clean
	(( test -e ${LTPTMPDIR}/${LTPSF_TAR} && echo "Skipping cvs up (tarball present)" )|| ( cd ${LTPSRCDIR}/ltp && cvs update ))

ltp-configure: ${LTPSTATE}/ltp-configure
${LTPSTATE}/ltp-configure: ${LTPSTATE}/ltp-fetch
	@mkdir -p ${LTPBUILDDIR}
	(cd ${LTPBUILDDIR} && ${LTPSRCDIR}/ltp/configure \
		--host arm-none-linux-gnueabi \
		--disable-docs --prefix=${LTPINSTALLDIR})
	make -C ${LTPBUILDDIR} clean
	@$(call ltpstate,$@,build)

ltp-build: ${LTPSTATE}/ltp-build
${LTPSTATE}/ltp-build: ${LTPSTATE}/ltp-configure
	make -C ${LTPBUILDDIR}
#	make -C ${LTPBUILDDIR} top_builddir=${LTPBUILDDIR} \
#		-f ${LTPSRCDIR}/ltp/Makefile top_srcdir=${LTPSRCDIR}/ltp
	rm -rf ${LTPINSTALLDIR}
	@mkdir -p ${LTPINSTALLDIR}
	SKIP_IDCHECK=1 make -C ${LTPBUILDDIR} -j${JOBS} install
#	SKIP_IDCHECK=1 make -C ${LTPBUILDDIR} top_builddir=${LTPBUILDDIR} \
#		-f ${LTPSRCDIR}/ltp/Makefile top_srcdir=${LTPSRCDIR}/ltp \
#		-j${JOBS} install
	@$(call ltpstate,$@,scripts)
	
ltp-scripts: ${LTPSTATE}/ltp-scripts
${LTPSTATE}/ltp-scripts: ${LTPSTATE}/ltp-build
	cp -rv ${LTPSCRIPTS}/* ${LTPINSTALLDIR}/
	@$(call ltpstate,$@)

ltp-clean:
	rm -rf ${LTPSTATE}/ltp-{configure,build} ${TOPLTPINSTALLDIR}
	make -C ${LTPBUILDDIR} clean
#	rm -rf ${LTPBUILDDIR}

ltp-mrproper:
	rm -rf ${LTPSTATE} ${LTPTMPDIR} ${LTPSRCDIR} ${TOPLTPINSTALLDIR}

ltp-version:
	@echo "LTP version ${LTPSF_RELEASE} (from sourceforge)"

# ${1}=logdir ${2}=toolchain ${3}=testname
ltplog	= ${1}/${2}-${ARCH}-`date +%Y-%m-%d_%H:%M:%S`-${3}.log
