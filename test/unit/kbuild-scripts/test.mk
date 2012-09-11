include Kbuild.include

seperator = "---------------------------------------------------------------------"
banner  = ( echo ${seperator}; echo ${1}; echo ${seperator} )

all: 
	@$(call banner, "** Testing Kbuild.include for $(CC) **")
	@$(CC) --version
	@echo "-------------"
	@echo "cc-version: " $(call cc-version,)
	@echo "no-reorder-blocks: " $(call cc-option,-fno-reorder-blocks,)
	@echo "unused-but-set-variable: " $(call cc-option,-Wno-unused-but-set-variable,)
	@echo "foo: " $(call cc-option,-Wfoo,)
	@echo "Disable unused-but-set-variable: " $(call cc-disable-warning, unused-but-set-variable)
	@echo

