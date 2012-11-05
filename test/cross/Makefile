all: test1-cs testcxx-cs test1-linaro testcxx-linaro

test1-cs: test1.c
	../../arch/arm/toolchain/codesourcery/bin/arm-eabi-gcc -static -integrated-as -o $@ $?

testcxx-cs: testcxx.cpp
	../../arch/arm/toolchain/codesourcery/bin/arm-eabi-g++ -static -integrated-as -o $@ $?

test1-linaro: test1.c
	../../arch/arm/toolchain/linaro/bin/arm-eabi-gcc -static -integrated-as -o $@ $?

testcxx-linaro: testcxx.cpp
	../../arch/arm/toolchain/linaro/bin/arm-eabi-g++ -static -integrated-as -o $@ $?

clean:
	rm -f test1-cs testcxx-cs test1-linaro testcxx-linaro
