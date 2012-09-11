CLANG=../../../toolchain/clang/install/bin/clang
GCC=gcc

all: test-gcc test-clang

test-gcc:
	@CC=${GCC} srctree=. make -f test.mk

test-clang:
	@CC=${CLANG} srctree=. make -f test.mk
