all: test

TOPDIR		= $(realpath ../../..)
TARGETDIR	= $(TOPDIR)/targets/vexpress
CROSS_ARM_TOOLCHAIN = codesourcery

include ${TOPDIR}/common.mk
# We need one arch, this is as good as any
include ${ARCHDIR}/arm/arm.mk

#================================================================================

test: test.c
	${TOPDIR}/arch/arm/bin/clang-wrap.sh -Wall $< -static -o $@

clean:
	rm -f test
