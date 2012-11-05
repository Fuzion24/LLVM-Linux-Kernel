all: test1 testcxx

test1: test1.c
	../../arch/arm/toolchain/codesourcery/bin/arm-eabi-gcc -static -integrated-as -o $@ $?

testcxx: testcxx.cpp
	../../arch/arm/toolchain/codesourcery/bin/arm-eabi-g++ -static -integrated-as -o $@ $?

clean:
	rm -f test1 testcxx
