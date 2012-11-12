CLANG	= ../../../toolchain/clang/install/bin/clang
GCC	= gcc

TARGET	= test-vlais

.PHONY: all test clean

OBJS		= test.o util.o
DIFF_OBJS	= novlais novlais1 novlais2
GCC_OBJS	= vlais-gcc.o ${addsuffix -gcc.o,${DIFF_OBJS}}
CLANG_OBJS	= ${addsuffix -clang.o,${DIFF_OBJS}}

all: $(TARGET)

${GCC_OBJS}: %-gcc.o: %.c
	$(GCC) -DNOVLAIS=$*_gcc -c $^ -o $@

${CLANG_OBJS}: %-clang.o: %.c
	$(CLANG) -g -DNOVLAIS=$*_clang -c $^ -o $@

${OBJS}: %.o: %.c
	$(CLANG) -g -c $^ -o $@

$(TARGET): ${CLANG_OBJS} ${GCC_OBJS} ${OBJS}
	$(GCC) -g -o $@ $^

test: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(TARGET) *.o
