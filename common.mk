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

COMMON_TARGETS	= list-jobs list-targets list-patch-applied list-path list-versions clean-all sync-all tmp-mrproper
TARGETS		+= ${COMMON_TARGETS}
.PHONY:		${COMMON_TARGETS}

seperator = "---------------------------------------------------------------------"
banner	= ( echo ${seperator}; echo ${1}; echo ${seperator} )
state	= @mkdir -p $(dir ${1}) && touch ${1} \
	  && $(call banner,"Finished state $(notdir ${1})") \
	  && ( [ -d $(dir ${1})${2} ] || rm -f $(dir ${3})${2} )
error1	= ( echo Error: ${1}; false )
assert	= [ ${1} ] || $(call error1,${2})
#assert	= echo "${1} --> ${2}"

# Default jobs is number of processors + 1 for disk I/O
ifeq "${JOBS}" ""
  JOBS:=${shell expr `getconf _NPROCESSORS_ONLN` + 1}
  ifeq "${JOBS}" ""
  JOBS:=2
  endif
endif

list-jobs:
	@echo "-j${JOBS}"

# The order of these includes is important
include ${TOOLCHAIN}/toolchain.mk

tmp-mrproper:
	@for t in ${TMPDIRS}; do rm -rf $$t/*; done

list-targets:
	@echo "List of available make targets:"
	@for t in ${TARGETS}; do echo $$t; done | sort -u

list-patch-applied:
	${MAKE} ${PATCH_APPLIED_TARGETS}

list-path:
	@echo ${PATH}

list-settings:
	@${MAKE} --silent ${SETTINGS_TARGETS}

list-versions:
	@cmake --version
	@gcc --version | head -1
	@git --version
	@make --version | head -1
	@echo "quilt version `quilt --version`"
	@${MAKE} ${VERSION_TARGETS} | grep -v ^make

clean-all:
	${MAKE} ${CLEAN_TARGETS}

sync-all:
	${MAKE} ${SYNC_TARGETS}

