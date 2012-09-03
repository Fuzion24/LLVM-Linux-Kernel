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

# The assumption is that this will be imported from the vexpress Makfile

LINARORELEASEURL	= http://releases.linaro.org/images/12.03/oneiric/nano
NANOBOARD		= ${BOARD}-nano
NANOIMG			= ${NANOBOARD}.img

get_linaro_prebuilt	= mkdir -p $(dir ${1}) && wget -P $(dir ${1}) -c ${LINARORELEASEURL}/$(notdir ${1})

TARGETS			+= 
CLEAN_TARGETS		+= vexpress-linaro-clean
MRPROPER_TARGETS	+= vexpress-linaro-mrproper
RAZE_TARGETS		+= vexpress-linaro-mrproper
.PHONY:			

# Build vexpress image
${TMPDIR}/sources.txt:
	wget --quiet $(LINARORELEASEURL)/sources.txt -O $@

${TMPDIR}/get-sources.sh: ${TMPDIR}/sources.txt
	perl -ne 'if(/^${NANOBOARD}:/){$$f=1} elsif($$f && m|(http://\S+)|){print "wget -c -P ${TMPDIR} $$1/"} elsif($$f && /(\S*\.tar\..*): md5sum/){print "$$1\n"} elsif(/^\s+:/) {$$f=0}' $< >$@
	sh $@

${TMPDIR}/board-sources.txt: ${TMPDIR}/sources.txt
	perl -ne 'if(/^${NANOBOARD}:/){$$f=1} elsif($$f && m|(http://\S+)|){print "$$1/"} elsif($$f && /(\S*\.tar\..*): md5sum/){print "$$1\n"} elsif(/^\s+:/) {$$f=0}' $< >$@
	wget -c -P ${TMPDIR} `cat $@`

${NANOIMG}: ${TMPDIR}/board-sources.txt
	(cd ${TMPDIR} && sudo linaro-media-create --dev ${BOARD} --rootfs ext4 \
		`sed 's|.*nano.*/|--binary |; s|.*hwpack.*/|--hwpack |' $(notdir $<)` \
		--hwpack-force-yes --image-size 1G --image-file $@ \
	)

vexpress-linaro-clean:
	rm -f ${NANOIMG}

# do a real wipe
vexpress-linaro-mrproper: vexpress-linaro-clean
	rm -f ${TMPDIR}/sources.txt ${TMPDIR}/get-sources.sh ${TMPDIR}/board-sources.txt

