include $(KBUILD)

# gcc clang

cc-version: # 0407 0402 0407 0402
	@echo $(call cc-version,)

# Testing for supported flags, these should not be blank for both clang and gcc:
cc-disable-warning-error: # -Wno-error -Wno-error -Wno-error -Wno-error
	@echo $(call cc-disable-warning,error,)
cc-disable-warning-unused-variable: # -Wno-unused-variable -Wno-unused-variable -Wno-unused-variable -Wno-unused-variable
	@echo $(call cc-disable-warning,unused-variable,)
cc-option-fno-common: # -fno-common -fno-common -fno-common -fno-common
	@echo $(call cc-option,-fno-common,)

# Testing for unsupported flags, these should be blank for both clang and gcc:
unsupported-flag-foo: # '' -ffoo '' ''
	@echo $(call cc-option,-ffoo,)
unsupported-warning-bar: # '' -Wbar '' ''
	@echo $(call cc-option,-Wbar,)

# Testing for unsupported clang flags, these should be blank for clang, not for gcc:
unused-but-set-variable: # -Wno-unused-but-set-variable -Wno-unused-but-set-variable -Wno-unused-but-set-variable ''
	@echo $(call cc-disable-warning,unused-but-set-variable,)
no-delete-pointer-checks: # -fno-delete-null-pointer-checks -fno-delete-null-pointer-checks -fno-delete-null-pointer-checks ''
	@echo $(call cc-option,-fno-delete-null-pointer-checks,)
conserve-stack: # -fconserve-stack -fconserve-stack -fconserve-stack ''
	@echo $(call cc-option,-fconserve-stack,)
delete-null-pointer-checks: # -fdelete-null-pointer-checks -fdelete-null-pointer-checks -fdelete-null-pointer-checks ''
	@echo $(call cc-option,-fdelete-null-pointer-checks,)
no-inline-functions-called-once: # -fno-inline-functions-called-once -fno-inline-functions-called-once -fno-inline-functions-called-once ''
	@echo $(call cc-option,-fno-inline-functions-called-once,)

# Testing for unsupported clang gcc, these should be blank for gcc, not for clang:
unused-argument: # '' -Qunused-arguments '' -Qunused-arguments
	@echo $(call cc-option,-Qunused-arguments,)
unused-as-argument: # '' -Qunused-arguments '' -Qunused-arguments
	@echo $(call as-option,-Qunused-arguments,)

