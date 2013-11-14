##############################################################################
# Copyright (c) 2013 Mark Charlebois
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
# Build and test __builtin_stack_address

CLANG	= ../../../toolchain/clang/install/bin/clang
CFLAGS	= -g

TARGET	= test

.PHONY: all clean


### BUILD ######################################################################
all: arm_test.s aarch64_test.s x86_test.s

arm_test.s: test.c Makefile
	$(CLANG) -target arm-none-linux-gnueabi ${EXTRAFLAGS} -S -O2 $< -o $@

x86_test.s: test.c Makefile
	$(CLANG) ${EXTRAFLAGS} -S -O2 $< -o $@

aarch64_test.s: test.c Makefile
	$(CLANG) -target aarch64-none-linux-gnueabi ${EXTRAFLAGS} -S -O2 $< -o $@

test: test.c Makefile
	$(CLANG) -target arm-none-gnueabi ${EXTRAFLAGS} -O2 $< -o $@

clean:
	@rm -f *test.s
