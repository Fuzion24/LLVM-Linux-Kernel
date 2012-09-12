seperator = "---------------------------------------------------------------------"
banner  = ( echo ${seperator}; echo ${1}; echo ${seperator} )

all: 
	@$(call banner, "** Testing Kbuild.include for $(CC) **")
	@$(CC) --version
	@echo "-------------"
	@echo "cc-version: " $(call cc-version,)
	@echo "--------------"
	@echo "Testing for supported flags, these should not be blank for both clang and gcc:"
	@echo "supported warning: " $(call cc-disable-warning,error,)
	@echo "supported warning: " $(call cc-disable-warning,unused-variable,)
	@echo "supported flag: " $(call cc-option,-fno-common,)
	@echo "--------------"
	@echo "Testing for unsupported flags, these should be blank for both clang and gcc:"
	@echo "unsupported flag (foo): " $(call cc-option,-ffoo,)
	@echo "unsupported warning (bar): " $(call cc-option,-Wbar,)
	@echo "--------------"
	@echo "Testing for unsupported clang flags, these should be blank for clang, not for gcc:"
	@echo "no-delete-pointer-checks:" $(call cc-option,-fno-delete-pointer-checks,)
	@echo "unused-but-set-variable: " $(call cc-disable-warning,unused-but-set-variable,)
	@echo "conserve-stack:" $(call cc-option,-fconserve-stack,)
	@echo "delete-null-pointer-checks:" $(call cc-option,-fdelete-null-pointer-checks,)
	@echo "no-inline-functions-called-once:" $(call cc-option,-fno-inline-functions-called-once,)
	@echo "no-inline-functions-called-once:" $(call cc-option,-fdelete-null-pointer-checks,)
	@echo

