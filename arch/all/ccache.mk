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
export CCACHE_COMPRESS CCACHE_CPP2 CCACHE_DIR

ifneq "${USE_CCACHE}" ""
CCACHE		= ccache
CCACHE_COMPRESS	= true
CCACHE_CPP2	= true
CCACHE_DIR	= $(subst ${TOPDIR},${BUILDROOT},${BUILDDIR})/ccache
#CCACHE_CLANG_OPTS = -fcolor-diagnostics
endif

#############################################################################
ccache-clean:
	@[ -z "${USE_CCACHE}" ] || ccache --cleanup

#############################################################################
ccache-mrproper:
	@[ -z "${USE_CCACHE}" ] || ccache --clear

#############################################################################
ccache-raze:
	@[ -z "${USE_CCACHE}" ] || rm -rf ${CCACHE_DIR}

#############################################################################
ccache-stats:
	@[ -z "${USE_CCACHE}" ] || ccache --show-stats

#############################################################################
list-ccache-dir:
	@[ -z "${USE_CCACHE}" ] || echo ${CCACHE_DIR}
	@echo ${GCC}

