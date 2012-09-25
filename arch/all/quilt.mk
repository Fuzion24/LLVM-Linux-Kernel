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

# Must be included by all.mk

#############################################################################
ifeq "${KERNEL_REPO_PATCHES}" ""
ifneq "${KERNEL_TAG}" ""
KERNEL_REPO_PATCHES = ${KERNEL_TAG}
else
KERNEL_REPO_PATCHES = ${KERNEL_BRANCH}
endif
endif

#############################################################################
GENERIC_PATCH_DIR	= $(filter-out %${KERNEL_REPO_PATCHES},$(filter-out ${TARGETDIR}/%,${KERNEL_PATCH_DIR}))
GENERIC_PATCH_SERIES	= $(addsuffix /series,$(GENERIC_PATCH_DIR))
TARGET_PATCH_DIR	= $(filter-out ${ARCHDIR}/%,${KERNEL_PATCH_DIR})
TARGET_PATCH_SERIES	= $(addsuffix /series.target,$(TARGET_PATCH_DIR))
ALL_PATCH_SERIES	= ${GENERIC_PATCH_SERIES} ${TARGET_PATCH_SERIES}
TARGET_PATCH_SERIES	= ${PATCHDIR}/series
SERIES_DOT_TARGET	= ${TARGET_PATCH_SERIES}.target

#############################################################################
checkfilefor	= grep -q ${2} ${1} || echo "${2}${3}" >> ${1}
reverselist	= `for DIR in ${1} ; do echo $$DIR; done | tac`
ln_if_new	= ls -l "${2}" | grep -q "${1}" || ln -fsv "${1}" "${2}"
mv_n_ln		= mv -v "${1}" "${2}" ; ln -sv "${2}" "${1}"
ln_kernel_patch_dir = [ -z "${1}" ] || [ -e ${1}/patches ] || ln -sv ${PATCHDIR} ${1}/patches

#############################################################################
QUILT_TARGETS		= kernel-quilt kernel-quilt-clean kernel-quilt-help kernel-quilt-settings list-kernel-patches list-kernel-maintainer
TARGETS			+= ${QUILT_TARGETS}
CLEAN_TARGETS		+= kernel-quilt-clean
HELP_TARGETS		+= kernel-quilt-help
MRPROPER_TARGETS	+= kernel-quilt-clean
SETTINGS_TARGETS	+= kernel-quilt-settings

.PHONY:			${QUILT_TARGETS}

#############################################################################
kernel-quilt-help:
	@echo "* make kernel-quilt - Setup kernel(s) to be patched by quilt"
	@echo "* make kernel-quilt-clean - Remove quilt setup"
	@echo "* make list-kernel-patches"
	@echo "			- List which kernel patches will be applied"
	@echo "* make list-kernel-maintainer"
	@echo "			- List which kernel maintainers should be contacted for each patch"

#############################################################################
kernel-quilt-settings:
	@echo "KERNEL_REPO_PATCHES	= ${KERNEL_REPO_PATCHES}"

##############################################################################
# Tweak quilt setup to make diffs-of-diffs easier to read
QUILTRC	= ${HOME}/.quiltrc
kernel-quiltrc: ${QUILTRC}
${QUILTRC}:
	@$(call banner, "Setting up quilt rc file...")
	@touch $@
	@$(call checkfilefor,$@,QUILT_NO_DIFF_TIMESTAMPS,=1)
	@$(call checkfilefor,$@,QUILT_PAGER,=)

##############################################################################
# Handle the case of renaming target/%/series -> target/%/series.target
kernel-quilt-series-dot-target: ${SERIES_DOT_TARGET}
${SERIES_DOT_TARGET}:
	@$(call banner, "Updating quilt series.target file for kernel...")
	@mkdir -p ${PATCHDIR}
	@[ -f ${TARGET_PATCH_SERIES} ] || touch ${TARGET_PATCH_SERIES}
# Rename target series file to series.target (we will be generating the new series file)
	@[ -e $@ ] || mv ${TARGET_PATCH_SERIES} $@

##############################################################################
# Save any new patches from the generated series file to the series.target file
kernel-quilt-update-series-dot-target:
	@[ `stat -c %Z ${TARGET_PATCH_SERIES}` -le `stat -c %Z ${SERIES_DOT_TARGET}` ] || \
		($(call banner, "Saving quilt changes to series.target file for kernel...") ; \
		diff ${TARGET_PATCH_SERIES} ${SERIES_DOT_TARGET} \
		| perl -ne 'print "$$1\n" if $$hunk>1 && /^< (.*)$$/; $$hunk++ if /^[^<>]/' \
		>> ${SERIES_DOT_TARGET}; touch ${SERIES_DOT_TARGET})

##############################################################################
# Generate target series file from relevant kernel quilt patch series files
kernel-quilt-generate-series: ${TARGET_PATCH_SERIES}
${TARGET_PATCH_SERIES}: ${ALL_PATCH_SERIES}
	$(MAKE) kernel-quilt-update-series-dot-target
	@$(call banner, "Building quilt series file for kernel...")
# Save any new patches from the generated series file to the series.target file
	@cat $^ > $@

##############################################################################
# Have git ignore extra patch files
QUILT_GITIGNORE	= ${PATCHDIR}/.gitignore
kernel-quilt-ignore-links: ${QUILT_GITIGNORE}
${QUILT_GITIGNORE}: ${GENERIC_PATCH_SERIES}
	@$(call banner, "Ignore symbolic linked quilt patches for kernel...")
	@echo .gitignore > $@
	@echo series >> $@
	@cat $^ >> $@

##############################################################################
# Remove broken symbolic links to old patches
kernel-quilt-clean-broken-symlinks:
	@$(call banner, "Removing broken symbolic linked quilt patches for kernel...")
	@[ -d ${PATCHDIR} ] && file ${PATCHDIR}/* | awk -F: '/broken symbolic link to/ {print $$1}' | xargs --no-run-if-empty rm

##############################################################################
# Move updated patches back to their proper place, and link patch files into target patches dir
kernel-quilt-link-patches: ${TARGET_PATCH_SERIES} ${QUILT_GITIGNORE}
	$(MAKE) kernel-quilt-update-series-dot-target kernel-quilt-clean-broken-symlinks
	@$(call banner, "Linking quilt patches for kernel...")
	@REVDIRS=$(call reverselist,${KERNEL_PATCH_DIR}) ; \
	for PATCH in `cat ${GENERIC_PATCH_SERIES}` ; do \
		PATCHLINK="${PATCHDIR}/$$PATCH" ; \
		for DIR in $$REVDIRS ; do \
			if [ -f "$$DIR/$$PATCH" -a ! -L "$$DIR/$$PATCH" ] ; then \
				if [ -f "$$PATCHLINK" -a ! -L "$$PATCHLINK" ] ; then \
					$(call mv_n_ln,$$PATCHLINK,$$DIR/$$PATCH) ; \
				else \
					$(call ln_if_new,$$DIR/$$PATCH,$$PATCHLINK) ; \
				fi ; \
				break; \
			fi ; \
		done ; \
	done | sed -e 's|${TARGETDIR}|.|g; s|${TOPDIR}|...|g'

##############################################################################
QUILT_STATE	= state/kernel-quilt
kernel-quilt: ${QUILT_STATE}
${QUILT_STATE}: state/kernel-fetch ${QUILTRC}
	@$(MAKE) kernel-quilt-link-patches
	@$(call banner, "Quilting kernel...")
	@$(call ln_kernel_patch_dir,${KERNELDIR})
	-@$(call ln_kernel_patch_dir,${KERNELGCC})
	$(call state,$@,kernel-patch)

##############################################################################
# List all patches which are being applied to the kernel
list-kernel-patches:
	@REVDIRS=$(call reverselist,${KERNEL_PATCH_DIR}) ; \
	for PATCH in `cat ${ALL_PATCH_SERIES}` ; do \
		for DIR in $$REVDIRS ; do \
			if [ -f "$$DIR/$$PATCH" -a ! -L "$$DIR/$$PATCH" ] ; then \
				echo "$$DIR/$$PATCH" ; \
				break; \
			fi ; \
		done ; \
	done

##############################################################################
list-kernel-maintainer: kernel-quilt
	@$(call banner,Finding maintainers for patches)
	@(cd ${KERNELDIR} && for PATCH in `cat ${ALL_PATCH_SERIES}` ; do \
		$(call banner,$$PATCH) ; \
		./scripts/get_maintainer.pl $$PATCH ; \
	done)

##############################################################################
kernel-quilt-clean: ${SERIES_DOT_TARGET}
	@$(call banner, "Removing symbolic linked quilt patches for kernel...")
	@rm -f ${QUILT_GITIGNORE}
	@[ ! -f ${SERIES_DOT_TARGET} ] || rm -f ${TARGET_PATCH_SERIES}
	@for FILE in ${PATCHDIR}/* ; do \
		[ ! -L $$FILE ] || rm $$FILE; \
	done
	@rm -f ${QUILT_STATE}
	@$(call banner,Quilting cleaned)

