all: aligned-attribute-gcc aligned-attribute-clang diff-all

aligned-attribute-gcc: aligned-attribute.c
	gcc $< -o $@

aligned-attribute-clang: aligned-attribute.c
	../../../toolchain/clang/install/bin/clang $< -o $@

diff-all: aligned-attribute-gcc aligned-attribute-clang
	./aligned-attribute-gcc > gcc-log
	./aligned-attribute-clang > clang-log
	diff -y gcc-log clang-log || true

clean:
	rm -f aligned-attribute-* *-log
