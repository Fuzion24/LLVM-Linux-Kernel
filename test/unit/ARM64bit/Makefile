#
# Unit test framwork for Kbuild
#

all: unittests

TOPDIR		= $(realpath ../../..)
TARGETDIR	= $(TOPDIR)/targets/vexpress

include ${TOPDIR}/common.mk
# We need one arch, this is as good as any
include ${ARCHDIR}/arm/arm.mk

#================================================================================

foo4: context-parsed.c
	${ARCHDIR}/arm/bin/clang-wrap.sh -include ./include/kconfig.h -D __KERNEL__ -D __LINUX_ARM_ARCH__=7 -I ./include -O2 -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -Werror-implicit-function-declaration -Wno-format-security -Wno-asm-operand-widths -Wno-unused-variable -Wno-tautological-compare -Wdeclaration-after-statement -Wno-pointer-sign -fno-dwarf2-cfi-asm -fno-dwarf-directory-asm -fdebug-compilation-dir /local2/mnt/workspace/llvmlinux/targets/vexpress/src/linux -fwrapv -mstackrealign -fno-builtin -fobjc-runtime=gcc -fno-common -fdiagnostics-show-option -fcolor-diagnostics -c -o context.o $? -static

