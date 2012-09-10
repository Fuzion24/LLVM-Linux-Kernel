include Kbuild.include

CLANG=../../../toolchain/clang/install/bin/clang

test-gcc:
	@echo "no-reorder-blocks: " $(call cc-option,-fno-reorder-blocks,)
	@echo "unused-but-set-variable: " $(call cc-option,-Wno-unused-but-set-variable,)
	@echo "foo: " $(call cc-option,-Wfoo,)
	@echo "Disable unused-but-set-variable: " $(call cc-disable-warning, unused-but-set-variable)

test-clang:
	@CC=${CLANG} echo "no-reorder-blocks: " $(call cc-option,-fno-reorder-blocks,)
	@CC=${CLANG} echo "unused-but-set-variable: " $(call cc-option,-Wno-unused-but-set-variable,)
	@CC=${CLANG} echo "foo: " $(call cc-option,-Wfoo,)
	@CC=${CLANG} echo "Disable unused-but-set-variable: " $(call cc-disable-warning, unused-but-set-variable)
