#############################################################################
# Copyright (c) 2012 Behan Webster
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

TMP_BRANCH	?= tmp
PUSH_BRANCH	?= $(shell date +llvmlinux-%Y.%m.%d-%H%M)

#############################################################################
kernel-git-import-quilt-patches: kernel-fetch kernel-quilt-link-patches
	@$(call banner,Importing quilt patch series into git branch: ${TMP_BRANCH}...)
	@$(call gitcheckout,${KERNELDIR},${KERNEL_BRANCH})
	@$(call unpatch,${KERNELDIR})
	@$(call leavestate,${STATEDIR},kernel-patch)
	-@$(call git,${KERNELDIR}, rebase --continue) >/dev/null 2>&1
	-@$(call git,${KERNELDIR}, branch -D ${TMP_BRANCH}) >/dev/null 2>&1
	@$(call gitcheckout,${KERNELDIR},-b ${TMP_BRANCH})
	-@$(call git,${KERNELDIR}, rebase --continue) >/dev/null 2>&1
	@$(call git,${KERNELDIR}, quiltimport ${TMP_BRANCH})
	@$(call gitcheckout,${KERNELDIR},${KERNEL_BRANCH})

kernel-git-export-patches:
	@$(call banner,Exporting quilt patch series from git branch: ${TMP_BRANCH}...)
	@$(call unpatch,${KERNELDIR})
	@$(call leavestate,${STATEDIR},kernel-patch)
	@$(call gitcheckout,${KERNELDIR},${TMP_BRANCH})
	@$(call git,${KERNELDIR}, format-patch --no-numbered ${KERNEL_BRANCH})
	@$(call gitcheckout,${KERNELDIR},${KERNEL_BRANCH})

kernel-quilt-rename-patches:
	@$(call banner,Exporting quilt patch series from git branch: ${TMP_BRANCH}...)
	@(cd $(KERNELDIR); \
	for NEWPATCH in 0*.patch; do \
		[ "$$NEWPATCH" = '0*.patch' ] && exit 0; \
		FILE=""; SAMENESS=99999; \
		for OLDPATCH in `cat patches/series` ; do \
			SCORE=`diff --suppress-common-lines $$NEWPATCH patches/$$OLDPATCH | wc -l` ; \
			if [ $$SCORE -lt $$SAMENESS ] ; then \
				FILE=patches/$$OLDPATCH; SAMENESS=$$SCORE; \
			fi ; \
		done ; \
		[ -n "$$FILE" ] && mv $$NEWPATCH $$FILE; \
	done)

kernel-quilt-fix-unchanged-patches:
	@for PATCH in `git status | awk '/#.*modified.*patch/ {print $$3}'`; do \
		CHANGED=`GIT_EXTERNAL_DIFF=${TOOLSDIR}/patchdiff git diff $$PATCH 2>/dev/null | wc -l`; \
		if [ $$CHANGED -eq 0 ] ; then \
			git checkout $$PATCH; \
		else \
			echo "modified: $$PATCH"; \
		fi ; \
	done

kernel-quilt-import-git-patches: kernel-git-export-patches
	$(MAKE) kernel-quilt-rename-patches
	$(MAKE) kernel-quilt-link-patches
	$(MAKE) kernel-quilt-fix-unchanged-patches
	@$(call banner,Patches successfully sent through git back to quilt series)

kernel-git-quilt-delete-branch:
	@$(call banner,Deleting git branch: ${TMP_BRANCH}...)
	@$(call git,${KERNELDIR}, branch -D ${TMP_BRANCH})

kernel-git-quilt-roundtrip: kernel-git-import-quilt-patches kernel-quilt-import-git-patches
