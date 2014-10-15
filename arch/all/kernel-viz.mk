#############################################################################
# Copyright (c) 2014 Behan Webster
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

#############################################################################
export OBJ_FILE_BASE SRC_FILE_BASE DOT_FILE_BASE

OBJ_FILE_BASE	= ${KERNEL_BUILD}
SRC_FILE_BASE	= ${KERNELDIR}
DOT_FILE_BASE	= ${KERNELDIR}

KERNELVIZ_FILE	= kernelviz.tar.xz
KERNELVIZ_DIRS	+= ${DOT_FILE_BASE} ${OBJ_FILE_BASE}

tarxz		= tar -cvJf ${1} ${2} | \
	( which pv && pv --bytes --eta --progress --rate --timer || cat ) >/dev/null

#############################################################################
ifdef KERNELVIZ
KERNEL_VAR	+= CFLAGS_KERNEL=" -mllvm -print-call-graph"
endif

#############################################################################
HELP_TARGETS	+= kernel-viz-help
kernel-viz-help:
	@echo
	@echo "These are the KernelViz make targets:"
	@echo "* make kernel-build-viz - Build clang kernel with KernelViz"
	@echo "* make kernelviz        - Start KernelViz"
	@echo "* make kernel-viz-tar   - Tar up files for KernelViz"

#############################################################################
kernel-build-viz:
	@${MAKE} KERNELVIZ=1 kernel-build

#############################################################################
kernelviz: kernel-build-viz
	@$(call makequiet,-C ${TOOLSDIR}/KernelViz OBJ_FILE_BASE=${OBJ_FILE_BASE} SRC_FILE_BASE=${SRC_FILE_BASE} DOT_FILE_BASE=${DOT_FILE_BASE})

#############################################################################
kernel-viz-tar:
	@$(call tarxz,${KERNELVIZ_FILE},${KERNELVIZ_DIRS})

#############################################################################
ifdef KERNELVIZ_TAR
kernel-build::
	@$(call makequiet,kernel-viz-tar)
endif
