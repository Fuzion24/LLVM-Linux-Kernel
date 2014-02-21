#############################################################################
# Copyright (c) 2014 Behan Webster
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to 
# deal in the Software without restriction, including without limitation the 
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
# sell copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in 
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
##############################################################################


#############################################################################
HELP_TARGETS	+= kernel-git-submit-help

#############################################################################
kernel-git-submit-help:
	@echo
	@echo "These are the kernel git patch submit make targets:"
	@echo "* make kernel-git-submit-patch"
	@echo "   options:"
	@echo "    CHECKPATCH=ignore       Ignore checkpatch.pl failures (for known problems)"
	@echo "    PATCH_LIST='patch list' List of patches to submit"
	@echo "    PATCH_FILTER_REGX=regex Choose patches from current patchset by regex"

#############################################################################
kernel-git-submit-patch-check:
	@$(call banner,Checking patches for obvious syntax problems)
	@OUTPUT=`$(MAKE) list-kernel-checkpatch NOPASS=1 NOFAIL=1 | grep ^FAIL`; \
	if [ -n "$$OUTPUT" ] ; then \
		echo "Not all the patches passed checkpatch.pl"; \
		echo "$$OUTPUT"; \
		if [ "$$CHECKPATCH" != "ignore" ] ; then \
			echo "If your patches are correct, you can override this failure by setting CHECKPATCH=ignore"; \
			false; \
		else \
			echo "Ignoring failures since CHECKPATCH=ignore"; \
		fi ; \
	fi


#############################################################################
email_addresses = cd ${KERNELDIR} ; \
	./scripts/get_maintainer.pl ${1} | while read ENTRY; do \
		case "$$ENTRY" in \
			*maintainer*|*authored*) echo "--to $$ENTRY";; \
			*) echo "--cc $$ENTRY";; \
		esac; \
	done \
	| sed -e 's/ .*</ /g; s/>.*//g; s/ (.*)//g'

#############################################################################
SUBMIT_BRANCH=for-upstream
SUBMIT_TMP=${KERNELDIR}/for-upstream
SUBMIT_COVER=${SUBMIT_TMP}/0000-cover-letter.patch
SUBMIT_COVER_SUBJECT=LLVMLinux: Patches to enable the kernel to be compiled with clang/LLVM
SUBMIT_COVER_BLURB=${DOCDIR}/patch-blurb.txt
kernel-git-submit-patch: kernel-fetch kernel-git-submit-patch-check
	@$(call banner,Importing patches into git)
	@$(call importprepare,${SUBMIT_BRANCH})
	@cd ${KERNELDIR} ; \
	[ -n "$$PATCH_LIST" ] || PATCH_LIST=`$(call catuniq,${ALL_PATCH_SERIES}) | grep "${PATCH_FILTER_REGEX}"`; \
	for PATCH in $$PATCH_LIST ; do echo $$PATCH; done > ${TARGET_PATCH_SERIES}.${SUBMIT_BRANCH}; \
	for PATCH in `$(call catuniq,${ALL_PATCH_SERIES})`; do \
		grep $$PATCH ${TARGET_PATCH_SERIES}.${SUBMIT_BRANCH} || true; \
	done > ${TARGET_PATCH_SERIES}
	@$(call git,${KERNELDIR}, quiltimport ${SUBMIT_BRANCH})
	@$(call banner,Formatting patches for sending via email)
	@mkdir -p ${SUBMIT_TMP}; rm -f ${SUBMIT_TMP}/*
	@$(call git,${KERNELDIR}, format-patch --cover-letter --no-color --find-renames --find-copies --output-directory ${SUBMIT_TMP} ${KERNEL_BRANCH}) | sed -e 's|${TOPDIR}||g'
	@$(call banner,Patches saved to ${SUBMIT_TMP})
	@$(call gitcheckout,${KERNELDIR},${KERNEL_BRANCH})
	@$(MAKE) kernel-quilt-link-patches >/dev/null 2>&1
	@if [ `find ${SUBMIT_TMP} -name '*.patch' | wc -l` -eq 2 ] ; then \
		rm ${SUBMIT_COVER}; \
	else \
		perl -i -n -e ' \
			s|\*\*\* SUBJECT HERE \*\*\*|${SUBMIT_COVER_SUBJECT}|; \
			s|\*\*\* BLURB HERE \*\*\*|`cat ${SUBMIT_COVER_BLURB}`|e; \
			print' ${SUBMIT_COVER}; \
		[ -n "$$VISUAL" ] || VISUAL=$$EDITOR; \
		[ -n "$$VISUAL" ] || VISUAL=vim; \
		$$VISUAL ${SUBMIT_COVER}; \
	fi
	@E=`cd ${TOPDIR}; git config --get user.email`; \
	PATCHES=`find ${SUBMIT_TMP} -name '*.patch' | grep -v 0000-`; \
	echo git send-email --from "$$E" \
		--annotate --confirm=always --signed-off-by-cc --thread \
		`$(call email_addresses,$$PATCHES)` ${SUBMIT_TMP}/*

#	sed -i 's|\*\*\* SUBJECT HERE \*\*\*|${SUBMIT_COVER_SUBJECT}|' ${SUBMIT_COVER}
#	sed -i '/\*\*\* BLURB HERE \*\*\*/{ s/\*\*\* BLURB HERE \*\*\*//g; r ${SUBMIT_COVER_BLURB}\
}' ${SUBMIT_COVER}
