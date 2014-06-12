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
HELP_TARGETS	+= kernel-git-request-pull-help

#############################################################################
kernel-git-request-pull-help:
	@echo
	@echo "These are the kernel git request pull make targets:"
	@echo "* make kernel-git-request-pull"
	@echo "   options:"
	@echo "    REQUEST_BRANCH=for-linus  Branch from which git pull request will be made"

#############################################################################
REQUEST_BRANCH	= for-linus
REQUEST_VER	=
REQUEST_TEXT	= LLVMLinux patches for ${REQUEST_VER}
REQUEST_TAG	= llvmlinux-for-${REQUEST_VER}
REQUEST_REPO_URI= git://git.linuxfoundation.org/llvmlinux/kernel.git
REQUEST_FILE	= msg.txt

#############################################################################
kernel-git-request-pull:
	@$(call assert,-n "${REQUEST_VER}",Need to set REQUEST_VER=v3.x\\n Example: make REQUEST_VER=v3.16 $@)
	@$(call banner,Generating Kernel Git Pull Request)
# Build request branch
	@${MAKE} -s kernel-git-${REQUEST_BRANCH}
# Check patches to be sure
	@${MAKE} -s ALL_PATCH_SERIES=${TARGET_PATCH_SERIES}.${REQUEST_BRANCH} kernel-git-submit-patch-check
# Checkout reuqest branch
	@$(call unpatch,${KERNELDIR})
	@$(call leavestate,${STATEDIR},kernel-patch)
	@$(call gitcheckout,${KERNELDIR},${REQUEST_BRANCH})
# Create signed tag for REUQEST_BRANCH
	@$(call git,${KERNELDIR},tag --sign --force --message="${REQUEST_TEXT}" ${REQUEST_TAG} ${REUQEST_BRANCH})
# Push tag to remote repo
	@[ -z "${DRYRUN}" ] \
		&&      $(call git,${KERNELDIR},push ${REQUEST_REPO_URI} +${REQUEST_TAG}) \
		|| echo "$(call git,${KERNELDIR},push ${REQUEST_REPO_URI} +${REQUEST_TAG})"
# Build To/Cc list
	@${MAKE} -s ALL_PATCH_SERIES=${TARGET_PATCH_SERIES}.${REQUEST_BRANCH} kernel-git-submit-patch-get_maintainers | sort
# Build request-pull message
	-$(call git,${KERNELDIR},request-pull master ${REQUEST_REPO_URI} ${REQUEST_TAG}) > ${TARGETDIR}/${REQUEST_FILE}
	@$(call banner,Created ${REQUEST_FILE})
# Checkout build branch
	@$(call gitcheckout,${KERNELDIR},${KERNEL_BRANCH})

