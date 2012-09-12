CLANG=../../../toolchain/clang/install/bin/clang
GCC=gcc

all: test-gcc-orig test-clang-orig test-gcc-patched test-clang-patched

test-gcc-orig:
	@CC=${GCC} srctree=. make -f orig.mk

test-clang-orig:
	@CC=${CLANG} srctree=. make -f orig.mk

test-gcc-patched:
	@echo "Using patched Kbuild.include:"
	@CC=${GCC} srctree=. make -f patched.mk

test-clang-patched:
	@echo "Using patched Kbuild.include:"
	@CC=${CLANG} srctree=. make -f patched.mk
