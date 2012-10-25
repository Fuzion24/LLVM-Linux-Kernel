CLANG	= ../../../toolchain/clang/install/bin/clang
GCC	= gcc

TARGET	= test-vlais

.PHONY: all test clean

all: $(TARGET)

vlais-gcc.o no-vlais-gcc.o: %-gcc.o: %.c
	$(GCC) -DNOVLAIS=novlais_gcc -c $^ -o $@

no-vlais-clang.o: %-clang.o: %.c
	$(CLANG) -g -DNOVLAIS=novlais_clang -c $^ -o $@

test.o util.o: %.o: %.c
	$(GCC) -g -c $^ -o $@

$(TARGET): test.o no-vlais-clang.o vlais-gcc.o no-vlais-gcc.o util.o
	$(GCC) -g -o $@ $^

test: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(TARGET) *.o
