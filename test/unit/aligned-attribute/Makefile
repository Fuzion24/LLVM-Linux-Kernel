all: aligned-attribute-gcc aligned-attribute-clang

aligned-attribute-gcc: aligned-attribute.c
	gcc $< -o $@

aligned-attribute-clang: aligned-attribute.c
	../../../toolchain/clang/install/bin/clang $< -o $@
