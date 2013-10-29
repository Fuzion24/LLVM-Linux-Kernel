BASE=../../..

# Prebuilt Clang
#CLANGDIR=${BASE}/toolchain/clang/clang+llvm-3.3-Ubuntu-13.04-x86_64-linux-gnu/bin
#VERSION=3.3

# Src Clang
CLANGDIR=${BASE}/toolchain/clang/install/bin
VERSION=3.4

VEXPRESSDIR=${BASE}/targets/vexpress

ARMCC=${BASE}/arch/aarch64/toolchain/linaro/gcc-linaro-aarch64-linux-gnu-4.8-2013.06_linux/bin/aarch64-linux-gnu-gcc

all: 
	make t1-gcc
	make t2-gcc
	make t3-gcc
	@echo "=========== Successfully built with GCC ============"
	-make t1
	-make t2
	-make t3
	@echo "=========== All tests failed to build with Clang  =="

t%: t%.c
	(CROSS_COMPILE=aarch64-linux-gnu- ${CLANGDIR}/clang -gcc-toolchain ${BASE}/arch/aarch64/toolchain/linaro/gcc-linaro-aarch64-linux-gnu-4.8-2013.06_linux -isystem ${CLANGDIR}/../lib/clang/${VERSION}/include -I. -target aarch64-none-linux-gnueabi -no-integrated-as -g -o $@ $? )

t%-gcc:  t%.c
	${ARMCC} -o $@ $< 

clean:
	rm -f t? t?-gcc
