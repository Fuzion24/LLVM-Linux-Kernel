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

TOPDIR=${CURDIR}

all: help
.PHONY: mrproper

ALL_BOARD_TARGETS = $(filter-out targets/template,$(wildcard targets/*))

toplevel-help:
	@echo "Usage: Go into target directory ( cd targets/<target> ) and execute make there."
	@echo
	@for DIR in ${ALL_BOARD_TARGETS}; do echo "* cd $$DIR;	make help" ; done
	@echo
	@echo "* make build-dep	- Make sure packaged build-dependencies are installed"

clean mrproper:
	@for DIR in ${ALL_BOARD_TARGETS}; do make -C $$DIR $@ || true; done

list-board-targets:
	@for DIR in ${ALL_BOARD_TARGETS}; do echo $$DIR; done

TARGETS		+= build-dep install-build-dep
HELP_TARGETS	+= toplevel-help
include common.mk

DEBDEP		= build-essential cmake flex git git-svn kpartx libfdt-dev libglib2.0-dev patch quilt rsync sparse subversion zlib1g-dev
DEBDEP_32	= libc6:i386 libncurses5:i386
DEBDEP_EXTRAS	= linaro-image-tools
debdep		= [ `dpkg -l $(1) | grep -c '^[pu]'` -eq 0 ] || ( echo "$(2)"; echo "  sudo apt-get install $(1)"; false )

RPMDEP		= cmake gcc flex gcc gcc-g++ git git-svn kpartx make patch quilt rsync sparse subversion zlib-devel

build-dep:
	@if [ -f /etc/debian_version ] ; then \
		$(call debdep,${DEBDEP},You must install...) ; \
		[ `uname -p | grep -c 64` -eq 0 ] || $(call debdep,${DEBDEP_32},You likely need to install...) ; \
		$(call debdep,${DEBDEP_EXTRAS},Not necessary, but you may want...) || true ; \
	else \
		rpm -q $(RPMDEP) >/dev/null 2>&1 || ( echo "sudo yum install $(RPMDEP)"; false ) \
	fi
	@echo "All build dependencies were found"

install-build-dep:
	@if [ -f /etc/debian_version ] ; then \
		sudo apt-get install $(DEBDEP); \
	else \
		sudo yum install $(RPMDEP); \
	fi
	@echo "All build dependencies were found"

