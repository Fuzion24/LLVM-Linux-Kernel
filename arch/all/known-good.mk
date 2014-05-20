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

##############################################################################
KNOWN_GOOD_KERNEL_CONFIG_URL = http://buildbot.llvm.linuxfoundation.org/configs/${TARGET}.cfg
KERNEL_CONFIG	= ${TMPDIR}/kernel.cfg
-include ${KERNEL_CONFIG}

##############################################################################
# Get known good config from continue integration buildbot
# ${KERNEL_CONFIG}: # Can't be this or will autodownload on above include
kernel-config:
	-@$(call wget,${KNOWN_GOOD_KERNEL_CONFIG_URL},$(dir $@)) \
		&& rm -f $@; ln -sf $(notdir ${KNOWN_GOOD_KERNEL_CONFIG_URL}) $@

##############################################################################
kernel-build-known-good: ${STATEDIR}/kernel-build-known-good
${STATEDIR}/kernel-build-known-good: kernel-config
	@$(MAKE) kernel-resync
	@$(call leavestate,${STATEDIR},kernel-configure kernel-build)
	@$(MAKE) state/kernel-build
	@$(call state,$@)

##############################################################################
kernel-rebuild-known-good:
	@$(call leavestate,${STATEDIR},kernel-build-known-good)
	@$(MAKE) ${STATEDIR}/kernel-build-known-good

##############################################################################
kernel-resync:
	@$(call banner,Sync known good kernel)
	@cat ${KERNEL_CONFIG}
	@$(call unpatch,${KERNELDIR})
	@$(call optinal_gitreset,${KERNELDIR})
	@$(call gitsync,${KERNELDIR},${KERNEL_COMMIT},${KERNEL_BRANCH},${KERNEL_TAG})

##############################################################################
kernel-raze::
	@rm -rf ${STATEDIR}/kernel-build-known-good ${KERNEL_CONFIG}

foo-known-good:
	@echo KERNEL_CONFIG=${KERNEL_CONFIG}
	@echo TOPDIR=${TOPDIR}
	@echo TARGETDIR=${TARGETDIR}
	@echo TMPDIR=${TMPDIR}
	@echo TARGET=${TARGET}
	@echo KNOWN_GOOD_KERNEL_CONFIG_URL=${KNOWN_GOOD_KERNEL_CONFIG_URL}
	@echo KERNEL_CONFIG=${KERNEL_CONFIG}
