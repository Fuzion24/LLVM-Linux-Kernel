all: test test_gcc

TOPDIR		= $(realpath ../../..)
TARGETDIR	= $(TOPDIR)/targets/vexpress
CROSS_ARM_TOOLCHAIN = codesourcery
ARMGCCSYSROOT=`arm-none-linux-gnueabi-gcc -print-sysroot`

include ${TOPDIR}/common.mk
# We need one arch, this is as good as any
include ${ARCHDIR}/arm/arm.mk

#================================================================================

test: test.c
	${CLANGCC} -Wall --sysroot=${ARMGCCSYSROOT} $< -static -o $@

test_gcc: test.c
	${CROSS_COMPILE}gcc -Wall $< -static -o $@

clean:
	rm -f test test_gcc
