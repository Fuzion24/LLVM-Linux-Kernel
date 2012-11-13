CLANG	= ../../../toolchain/clang/install/bin/clang
GCC	= gcc

TARGET	= test-vlais

.PHONY: all test clean

OBJS		= test.o util.o
DIFF_OBJS	= novlais novlais1 novlais2
GCC_OBJS	= vlais-gcc.o ${addsuffix -gcc.o,${DIFF_OBJS}}
CLANG_OBJS	= $(addsuffix -clang.o,${DIFF_OBJS})
ALL_OBJS	= ${CLANG_OBJS} ${GCC_OBJS} ${OBJS}
SOME		= vlais-gcc novlais2-gcc novlais2-clang

all: $(TARGET)

${GCC_OBJS}: %-gcc.o: %.c
	$(GCC) ${EXTRAFLAGS} -DNOVLAIS=$*_gcc -c $^ -o $@

${CLANG_OBJS}: %-clang.o: %.c
	$(CLANG) ${EXTRAFLAGS} -g -DNOVLAIS=$*_clang -c $^ -o $@

${OBJS}: %.o: %.c
	$(CLANG) ${EXTRAFLAGS} -g -c $^ -o $@

$(TARGET): ${ALL_OBJS}
	$(GCC) -g -o $@ $^

test: $(TARGET)
	./$(TARGET)

get-asm:
	@for FILE in ${SOME} ; do \
		objdump --disassemble $${FILE}.o > $${FILE}.txt ; \
	done

TESTS	= test-O0 test-O2 test-Os
test-all: ${TESTS}
${TESTS}: test%:
	EXTRAFLAGS=$* $(MAKE) clean test >/dev/null
	@objsize --extended $(addsuffix .o,${SOME})

clean:
	rm -f $(TARGET) *.o
