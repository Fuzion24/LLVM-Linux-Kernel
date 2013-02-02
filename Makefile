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
TARGETDIR=${TOPDIR}

all: help
.PHONY: mrproper

ALL_BOARD_TARGETS = $(filter-out targets/template,$(wildcard targets/*))

toplevel-help:
	@echo "Usage: Go into target directory ( cd targets/<target> ) and execute make there."
	@echo
	@for DIR in ${ALL_BOARD_TARGETS}; do echo "* cd $$DIR;	make help" ; done

clean mrproper:
	@for DIR in ${ALL_BOARD_TARGETS}; do make -C $$DIR $@ || true; done

list-board-targets:
	@for DIR in ${ALL_BOARD_TARGETS}; do echo $$DIR; done

HELP_TARGETS	+= toplevel-help
include common.mk

