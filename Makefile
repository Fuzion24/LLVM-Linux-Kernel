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

clean: help
help:
	@echo "Usage: Go into target directory ( cd targets/<target> ) and execute make there."
	@echo "       Valid targets:"
	@echo "       * vexpress  (make <all|test|test2|test3|clean|mrproper>)"
	@echo "       * msm       (make <all|clean|mrproper>)"
	@echo "       * hexagon   (make <all|clean|mrproper>)"
	@echo "       * ar71xx    (make <all|clean|mrproper>)"
	@echo ""
	@echo "       E.g.: cd targets/vexpress ; make help"
	@echo ""
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

include common.mk

DEBDEP = build-essential cmake git kpartx linaro-image-tools patch quilt rsync subversion zlib1g-dev
RPMDEP = cmake gcc git kpartx patch quilt rsync subversion zlib-devel

build-dep:
	@if [ -f /etc/debian_version ] ; then \
		[ `dpkg -l $(DEBDEP) | grep -c '^[pu]'` -eq 0 ] || ( echo "sudo apt-get install $(DEBDEP)"; false ) \
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

