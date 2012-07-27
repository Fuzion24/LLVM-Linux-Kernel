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

export JOBS

TOOLCHAIN	= ${TOPDIR}/toolchain
TOOLSDIR	= ${TOPDIR}/tools
ARCHDIR		= ${TOPDIR}/arch
TESTDIR		= ${TOPDIR}/test

# Default jobs is number of processors + 1 for disk I/O
JOBS:=${shell expr `getconf _NPROCESSORS_ONLN` + 1}
ifeq "${JOBS}" ""
JOBS:=2
endif

list-jobs:
	@echo "-j${JOBS}"

# The order of these includes is important
include ${TOOLCHAIN}/toolchain.mk

TARGETS	+= tmp-mrproper list-path

tmp-mrproper:
	@for t in ${TMPDIRS}; do rm -rf $$t/*; done

list-targets:
	@echo "List of available make targets:"
	@for t in ${TARGETS}; do echo $$t; done

list-patch-applied:
	${MAKE} ${PATCH_APPLIED_TARGETS}

list-path:
	@echo ${PATH}

clean-all:
	${MAKE} ${CLEAN_TARGETS}

sync-all:
	${MAKE} ${SYNC_TARGETS}

