##############################################################################
# Copyright (c) 2012 Mark Charlebois
#               2012 Jan-Simon Möller
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

clean: help
help:
	@echo "Usage: Go into target directory ( cd targets/<target> ) and execute make there."
	@echo "       Valid targets:"
	@echo "       * vexpress  (make <all|test|test2|clean|mrproper>)"
	@echo "       * msm       (make <all|clean|mrproper>)"
	@echo "       * hexagon   (make <all|clean|mrproper>)"
	@echo "       * ar71xx    (make <all|clean|mrproper>)"
	@echo "       "
	@echo "       Cleanup with:"
	@echo "         make mrproper "
	@echo ""
	@echo "       Options:  make <option> [target]"
	@echo "       * BUILDMODE=[DEFAULT*|BOT]"
	@echo "         (for buildbot)"
	@echo "       * GDBON=[0*|1]  - enable GDB on qemu-system-arm"
	@exit 0

mrproper:
	( cd targets/vexpress ; make mrproper )
	( cd targets/msm ; make mrproper )
	( cd targets/hexagon ; make mrproper )
	( cd targets/ar71xx ; make mrproper )

include clang/clang.mk
include qemu/qemu.mk
include test/ltp/ltp.mk

DEBDEP = build-essential kpartx linaro-image-tools rsync zlib1g-dev
RPMDEP = gcc kpartx rsync zlib-devel
build-dep:
	@if [ -f /etc/debian_version ] ; then \
		dpkg -l $(DEBDEP) >/dev/null 2>&1 || ( echo "apt-get install $(DEBDEP)"; false ) \
	else \
		rpm -q $(DEPENDENCIES) >/dev/null 2>&1 || ( echo "apt-get install $(DEPENDENCIES)"; false ) \
	fi
	@/opt/arm-2011.09/bin/arm-none-linux-gnueabi-gcc -v >/dev/null 2>&1 \
		|| ( echo "Can't find working Codesourcery 2011.09 arm cross-compiler"; false )
	@echo "All build dependencies were found"
