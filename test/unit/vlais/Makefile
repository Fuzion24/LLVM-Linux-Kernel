CLANG	= ../../../toolchain/clang/install/bin/clang
GCC	= gcc -std=c11
CFLAGS	= -g

TARGET	= test-vlais

.PHONY: all test clean

OBJS		= test.o util.o
VLAIS_OBJ	= vlais-gcc.o
DIFF_OBJS	= novlais novlais1 novlais2 novlais3 novlais4
GCC_OBJS	= ${VLAIS_OBJ} ${addsuffix -gcc.o,${DIFF_OBJS}}
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

timing.log:
	EXTRAFLAGS=-DTIMING $(MAKE) clean all >/dev/null
	./$(TARGET) | tee $@

timing.dat: timing.log
	@echo "# Filename usecs" > $@
	@sed 's/:/ /g' $< | awk '/^PASS/ { print $$2 " " $$12 }' >> $@

TIMINGPLOT = "\
\# set terminal svg size 600,400 dynamic enhanced fname 'arial' fsize 10 mousing name 'histograms_2' butt solid\n \
\# set output 'histograms.2.svg'\n \
set boxwidth 0.9 absolute\n \
set style fill solid 1.00 border lt -1\n \
set key inside right top vertical Right noreverse noenhanced autotitles nobox\n \
set style histogram clustered gap 1 title  offset character 0, 0, 0\n \
set datafile missing '-'\n \
set style data histograms\n \
set xtics border in scale 0,0 nomirror rotate by -45  offset character 0, 0, 0 autojustify\n \
set xtics norangelimit font ',8'\n \
set xtics ()\n \
set title 'Timing data for VLAIS alternatives'\n \
i = 22\n \
plot 'timing.dat' u 2 title 'Diff from VLAIS in usecs', '' using 0:xticlabel(1) notitle ' '\n"

timing: timing.dat
	@(echo $(TIMINGPLOT); read FOO) | gnuplot

get-asm:
	@for FILE in ${GCC_OBJS} ; do \
		objdump --disassemble $${FILE} > $${FILE}.asm ; \
	done

textsize = `objdump -h $(1) \
		| awk --non-decimal-data '/\.text/ { printf("%d", "0x" $$3) }'`
printsize = printf "%-18s size:%d text:%d diff:%d\n" \
		$(1) `stat -c %s $(1)` $(2) `expr $(2) - $(3)`

TESTS	= test-O0 test-O1 test-O2 test-Os
test-all: ${TESTS}
${TESTS}: test%:
	EXTRAFLAGS=$* $(MAKE) clean all >/dev/null
	@CMPSIZE=$(call textsize,${VLAIS_OBJ}); \
	$(call printsize,${VLAIS_OBJ},$$CMPSIZE,$$CMPSIZE); \
	for FILE in ${DIFF_OBJS} ; do \
		for EXT in -gcc.o -clang.o ; do \
			SIZE=$(call textsize,$$FILE$$EXT); \
			$(call printsize,$$FILE$$EXT,$$SIZE,$$CMPSIZE); \
		done; \
	done

clean:
	rm -f $(TARGET) *.o
