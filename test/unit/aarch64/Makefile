BASE=../../..

# Prebuilt Clang
#CLANGDIR=${BASE}/toolchain/clang/clang+llvm-3.3-Ubuntu-13.04-x86_64-linux-gnu/bin
#VERSION=3.3

# Src Clang
CLANGDIR=${BASE}/toolchain/clang/install/bin
VERSION=3.4

VEXPRESSDIR=${BASE}/targets/vexpress

ARMCC=${BASE}/arch/aarch64/toolchain/linaro/gcc-linaro-aarch64-linux-gnu-4.8-2013.06_linux/bin/aarch64-linux-gnu-gcc
ARMLIBC=${BASE}/arch/aarch64/toolchain/linaro/gcc-linaro-aarch64-linux-gnu-4.8-2013.06_linux/aarch64-linux-gnu/libc

OPTIONS=-O2

OPTIONS1=-cc1 -triple aarch64--linux-gnu -S -disable-free -disable-llvm-verifier -mrelocation-model static -mdisable-fp-elim -relaxed-aliasing -mdisable-tail-calls -fmath-errno -masm-verbose -mconstructor-aliases -fuse-init-array -g -nostdsysteminc -nobuiltininc -resource-dir /local2/mnt/workspace/llvmlinux/toolchain/clang/install/bin/../lib/clang/3.4 -sys-header-deps -isystem /local2/mnt/workspace/llvmlinux/toolchain/clang/install/bin/../lib/clang/3.4/include -fcolor-diagnostics -vectorize-loops -vectorize-slp -fobjc-runtime=gcc -fno-dwarf-directory-asm -fdebug-compilation-dir /local2/mnt/workspace/llvmlinux/targets/vexpress64/src/linaro-aarch64 -ferror-limit 19 -fmessage-length 127 -mstackrealign -Wno-gnu -Wno-tautological-compare -Wno-format-invalid-specifier -Wno-asm-operand-widths 


OPTIONS2=-D __KERNEL__ -D CC_HAVE_ASM_GOTO -I /local2/mnt/workspace/llvmlinux/targets/vexpress64/src/linaro-aarch64/arch/arm64/include -I /local2/mnt/workspace/llvmlinux/targets/vexpress64/src/linaro-aarch64/arch/arm64/include/uapi -I /local2/mnt/workspace/llvmlinux/targets/vexpress64/src/linaro-aarch64/include/uapi -O2 -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -Werror-implicit-function-declaration -Wno-format-security -Wno-unused-variable -Wdeclaration-after-statement -Wno-pointer-sign -fwrapv -fno-builtin -fno-signed-char -fno-common -fdiagnostics-show-option 

all: 
	make clean
	@echo
	@echo "=========== Building with GCC ============"
	@echo
	make t1-gcc
	make t2-gcc
	make t3-gcc
	make t4-gcc
	make t5-gcc
	@echo
	@echo "=========== building with Clang  ========="
	@echo
	-make t1
	-make t2
	-make t3
	-make t4
	-make t5

t%: t%.c
	@echo
	(CROSS_COMPILE=aarch64-linux-gnu- ${CLANGDIR}/clang -gcc-toolchain ${BASE}/arch/aarch64/toolchain/linaro/gcc-linaro-aarch64-linux-gnu-4.8-2013.06_linux -isystem ${CLANGDIR}/../lib/clang/${VERSION}/include -I. -target aarch64-none-linux-gnueabi -no-integrated-as --sysroot=${ARMLIBC} ${OPTIONS} -o $@ $? )
	@echo "+++ $@ built successfully +++"

t5: t5.c
	@echo
	(CROSS_COMPILE=aarch64-linux-gnu- ${CLANGDIR}/clang ${OPTIONS1} ${OPTIONS2} -o $@ $?)
	@echo "+++ $@ built successfully +++"


t%-gcc:  t%.c
	@echo
	${ARMCC} -o $@ $< 
	@echo "+++ $@ built successfully +++"

t5-gcc:  t5.c
	@echo
	${ARMCC} ${OPTIONS2} -o $@ $< 
	@echo "+++ $@ built successfully +++"

clean:
	rm -f t? t?-gcc
