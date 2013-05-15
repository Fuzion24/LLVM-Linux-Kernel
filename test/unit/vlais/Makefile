CLANG	= ../../../toolchain/clang/install/bin/clang
GCC	= gcc -std=c11
CFLAGS	= -g

TARGET	= test-vlais

.PHONY: all test clean

OBJS		= test.o util.o
DIFF_OBJS	= novlais novlais1 novlais2 novlais3 novlais4
GCC_OBJS	= vlais-gcc.o ${addsuffix -gcc.o,${DIFF_OBJS}}
CLANG_OBJS	= $(addsuffix -clang.o,${DIFF_OBJS})
ALL_OBJS	= ${CLANG_OBJS} ${GCC_OBJS} ${OBJS}

all: $(TARGET)

${GCC_OBJS}: %-gcc.o: %.c util.h
	$(GCC) ${EXTRAFLAGS} -DNOVLAIS=$*_gcc -c $< -o $@

${CLANG_OBJS}: %-clang.o: %.c util.h
	$(CLANG) ${EXTRAFLAGS} -g -DNOVLAIS=$*_clang -c $< -o $@

${OBJS}: %.o: %.c util.h
	$(CLANG) ${EXTRAFLAGS} -g -c $< -o $@

$(TARGET): ${ALL_OBJS}
	$(GCC) -o $@ $^

test: $(TARGET)
	./$(TARGET)

timing:
	EXTRAFLAGS=-DTIMING $(MAKE) clean all >/dev/null
	./$(TARGET)

get-asm:
	@for FILE in ${GCC_OBJS} ; do \
		objdump --disassemble $${FILE} > $${FILE}.asm ; \
	done

TESTS	= test-O0 test-O2 test-Os
test-all: ${TESTS}
${TESTS}: test%:
	EXTRAFLAGS=$* $(MAKE) clean all >/dev/null
	@objsize --extended ${GCC_OBJS} ${CLANG_OBJS} | sort -k2

clean:
	rm -f $(TARGET) *.o
