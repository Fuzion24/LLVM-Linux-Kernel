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

COMMON_TARGETS	= list-config list-jobs list-targets list-fetch-all list-patch-applied list-path list-versions \
			clean-all fetch-all mrproper-all raze-all sync-all tmp-mrproper
TARGETS		+= ${COMMON_TARGETS}
HELP_TARGETS	+= common-help
.PHONY:		${COMMON_TARGETS}

seperator = "---------------------------------------------------------------------"
banner	= ( echo ${seperator}; echo ${1}; echo ${seperator} )
state	= @mkdir -p $(dir ${1}) && touch ${1} \
	  && $(call banner,"Finished state $(notdir ${1})") \
	  && ( [ -d $(dir ${1})${2} ] || rm -f $(dir ${3})${2} )
error1	= ( echo Error: ${1}; false )
assert	= [ ${1} ] || $(call error1,${2})
#assert	= echo "${1} --> ${2}"

applied	= ( [ -d ${1} ] && cd ${1} && quilt applied || true )
patch	= [ ! -d ${1} ] || (cd ${1} && if [ -e patches ] && quilt unapplied ; then quilt push -a ; else >/dev/null ; fi)
unpatch	= [ ! -d ${1} ] || (cd ${1} && if [ -e patches ] && quilt applied ; then quilt pop -af ; else >/dev/null ; fi)

# Default jobs is number of processors + 1 for disk I/O
ifeq "${JOBS}" ""
  JOBS:=${shell expr `getconf _NPROCESSORS_ONLN` + 1}
  ifeq "${JOBS}" ""
  JOBS:=2
  endif
endif

common-help:
	@echo
	@echo "* make clean-all	- clean all code"
	@echo "* make fetch-all	- fetch all repos and external files"
	@echo "* make mproper-all	- scrub all code (cleaner than clean)"
	@echo "* make raze-all		- Remove most things not in the llvmlinux repo"
	@echo "* make sync-all		- sync all repos"
	@echo
	@echo "* make list-config	- List make variables you can specify in the CONFIG files"
	@echo "* make list-jobs	- List number of parallel build jobs"
	@echo "* make list-targets	- List all build targets"
	@echo "* make list-fetch-all	- List all things to be downloaded"
	@echo "* make list-patch-applied - List all applied patches"
	@echo "* make list-path	- List the search path used by the Makefiles"
	@echo "* make list-versions	- List the version of all relevant software"
	@echo
	@echo "* make CONFIG=<file> ... - Choose configuration file(s) to use"

list-jobs:
	@echo "-j${JOBS}"

# The order of these includes is important
include ${TOOLCHAIN}/toolchain.mk

help:
	@${MAKE} --silent ${HELP_TARGETS}

list-targets:
	@echo "List of available make targets:"
	@for t in ${TARGETS}; do echo $$t; done | sort -u

list-fetch-all:
	@for t in ${FETCH_TARGETS}; do echo $$t | sed -e "s|^`pwd`/||"; done

list-patch-applied:
	${MAKE} ${PATCH_APPLIED_TARGETS}

list-path:
	@echo ${PATH}

list-settings list-config:
	@${MAKE} --silent ${SETTINGS_TARGETS}

list-versions:
	@cmake --version
	@gcc --version | head -1
	@git --version
	@make --version | head -1
	@echo "quilt version `quilt --version`"
	@${MAKE} ${VERSION_TARGETS} | grep -v ^make

clean-all:
	@$(call banner,Cleaning everything...)
	${MAKE} ${CLEAN_TARGETS}

fetch-all:
	@$(call banner,Fetching external repos...)
	${MAKE} ${FETCH_TARGETS}

mrproper-all: tmp-mrproper
	@$(call banner,Scrubbing everything...)
	${MAKE} ${MRPROPER_TARGETS}

raze-all: tmp-mrproper
	@$(call banner,Removing everything...)
	${MAKE} ${RAZE_TARGETS}

sync-all:
	@$(call banner,Syncing everything...)
	${MAKE} ${SYNC_TARGETS}

tmp-mrproper:
	@$(call banner,Scrubbing tmp dirs...)
	rm -rf $(addsuffix /*,${TMPDIRS})

