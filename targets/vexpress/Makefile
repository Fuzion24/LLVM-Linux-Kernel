##############################################################################
# Copyright (c) 2012 Mark Charlebois
#               2012 Jan-Simon Möller
#               2012 Behan Webster
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

TARGETDIR	= ${CURDIR}
TOPDIR		= $(realpath ${TARGETDIR}/../..)

KERNEL_CFG	= ${TARGETDIR}/config_vexpress

KERNEL_PATCHES	+= $(call add_patches,${TARGETDIR}/patches)

BUILDMODE	:= DEFAULT

ifeq ('${GDBON}','1')
GDB_OPTS=-gdb tcp::4321 -S
else
GDB_OPTS=
endif

TESTRESULTS = test-results

#all: all2
all: prep kernel-build qemu-build

include ${TOPDIR}/common.mk
include ${ARCHDIR}/arm/arm.mk

LINARORELEASEURL=http://releases.linaro.org/images/12.03/oneiric/nano
BOARD=vexpress-a9
NANOBOARD=${BOARD}-nano
NANOIMG=${NANOBOARD}.img

TARGETS+= clean mrproper test test2
.PHONY: help test test2 prep clean mrproper

help:
	@echo "targets/vexpress has these options:"
	@echo ""
	@echo "* make test          - simple boot to rootfs (make test-[gcc-]kill *1)"
	@echo "* make test2         - bsd userspace with toybox"
	@echo "* make test3         - linaro/ubuntu rootfs"
	@echo "* make test3-ltp     - linaro/ubuntu rootfs starting LTP, kernel built with clang"
	@echo "* make test3-gcc-ltp - linaro/ubuntu rootfs starting LTP, kernel built with gcc"
	@echo ""
	@echo "* make clean         - cleanup"
	@echo "* make mrproper      - wipe all built files"
	@echo "* make kernels       - build kernel with clang and gcc"
	@echo "* make [llvm,clang,qemu,kernel]-build"
	@echo "                     - build [llvm,clang,qemu,kernel]"
	@echo "* make [llvm,clang,qemu,kernel]-sync"
	@echo "                     - sync repos [llvm,clang,qemu,kernel]"
	@echo "* make sync-all      - sync all repos"
	@echo ""
	@echo "* make patch-update"

all2: help
	@( echo "Continue to build the compiler and initramfs ? [nY]" ; read aw;  if [ x"$$aw" == x"n" ] || [ x"$$aw" == x"N" ] ; then exit 1 ; fi )
	@make prep kernel-build qemu-build
	@echo "To continue execute 'make test'."

prep: state/prep
state/prep:
	@mkdir -p ${LOGDIR} ${TMPDIR}
	$(call state,$@)

clean: qemu-clean kernel-clean clang-clean llvm-clean initramfs-clean

# do a real wipe
mrproper: clean ltp-mrproper tmp-mrproper
	-rm -rf arm-test-0.2.tar.gz arm-test
#	rm -f state/fetch-initrd
	@rm -rf ${LOGDIR}/*
	( cd ${KERNELDIR} && make mrproper )
	-( cd ${KERNELGCC} && make mrproper )

#fetch-initrd: state/fetch-initrd
#state/fetch-initrd:
#	rm -f arm-test-0.2.tar.gz
#	wget -nd -c "http://wiki.qemu.org/download/arm-test-0.2.tar.gz"
#	tar -xzvf arm-test-0.2.tar.gz
#	$(call state,$@)

# state/fetch-initrd
test: state/prep ${QEMUSTATE}/qemu-build state/kernel-build
	@$(call qemu,${BOARD},${KERNELDIR},768,/dev/ram0,ramdisk_size=65536 rw,-initrd reference/initramfs.img -net none)

test-ltp: state/prep ${QEMUSTATE}/qemu-build state/kernel-build
	@$(call qemu,${BOARD} -cpu cortex-a9,${KERNELDIR},768,/dev/ram0,ramdisk_size=327680 rw rdinit=/bin/sh,-initrd reference/initramfs.img -net none)

# state/fetch-initrd
test-kill: state/prep state/kernel-build ${QEMUSTATE}/qemu-build
	( $(call qemu,${BOARD},${KERNELDIR},256,/dev/ram0,ramdisk_size=65536 rw POWEROFF,-initrd reference/initramfs.img -net none) \
		| tee tmp/qemu_log ) &
	( sleep 10 && killall -s 9 qemu-system-arm ) || exit 0
	@grep -a "SUCCESS" tmp/qemu_log 

test-gcc-kill: state/prep state/kernel-gcc-build ${QEMUSTATE}/qemu-build
	( $(call qemu,${BOARD},${KERNELGCC},256,/dev/ram0,ramdisk_size=65536 rw POWEROFF,-initrd reference/initramfs.img -net none) \
		| tee tmp/qemu_gcc_log ) &
	( sleep 10 && killall -s 9 qemu-system-arm ) || exit 0
	@grep -a "SUCCESS" tmp/qemu_gcc_log 

test2: state/prep ${QEMUSTATE}/qemu-build state/kernel-build initramfs
	@$(call qemu,${BOARD},${KERNELDIR},256,/dev/ram0,init=/bin/init,-initrd initramfs.img.gz)

# Get prebuilt vexpress image
${TOPTMPDIR}/${NANOBOARD}.img.gz:
	wget -P $(dir $@) -c ${LINARORELEASEURL}/$(notdir $@)

vexpress.img: ${TOPTMPDIR}/${NANOBOARD}.img.gz
	gzip -dc $< > $@

# Build vexpress image
${TOPTMPDIR}/sources.txt:
	wget --quiet $(LINARORELEASEURL)/sources.txt -O $@

${TOPTMPDIR}/get-sources.sh: ${TOPTMPDIR}/sources.txt
	perl -ne 'if(/^${NANOBOARD}:/){$$f=1} elsif($$f && m|(http://\S+)|){print "wget -c -P ${TOPTMPDIR} $$1/"} elsif($$f && /(\S*\.tar\..*): md5sum/){print "$$1\n"} elsif(/^\s+:/) {$$f=0}' $< >$@
	sh $@

${TOPTMPDIR}/board-sources.txt: ${TOPTMPDIR}/sources.txt
	perl -ne 'if(/^${NANOBOARD}:/){$$f=1} elsif($$f && m|(http://\S+)|){print "$$1/"} elsif($$f && /(\S*\.tar\..*): md5sum/){print "$$1\n"} elsif(/^\s+:/) {$$f=0}' $< >$@
	wget -c -P ${TOPTMPDIR} `cat $@`

${NANOIMG}: ${TOPTMPDIR}/${NANOIMG}
${TOPTMPDIR}/${NANOIMG}: ${TOPTMPDIR}/board-sources.txt
	(cd ${TOPTMPDIR} && sudo linaro-media-create --dev ${BOARD} --rootfs ext4 \
		`sed 's|.*nano.*/|--binary |; s|.*hwpack.*/|--hwpack |' $(notdir $<)` \
		--hwpack-force-yes --image-size 1G --image-file $@ \
	)

# Build ltp image into vexpress image
vexpress-ltp.img: ${TOPTMPDIR}/${NANOBOARD}.img.gz ${LTPSTATE}/ltp-build ${LTPSTATE}/ltp-scripts
	gzip -dc $< > $@
	${TOOLSDIR}/partcopy.sh $@ rootfs ${LTPINSTALLDIR}/ /opt/ltp/ || (rm $@ && echo "E: $@ error" && false)

vexpress-ltp-clean:
	rm -f vexpress-ltp.img
vexpress-ltp-force: vexpress-ltp-clean vexpress-ltp.img

test3: state/prep ${QEMUSTATE}/qemu-build state/kernel-build vexpress.img
	@$(call qemu,${BOARD},${KERNELDIR},256,/dev/mmcblk0p2,rootfstype=ext4 init=/bin/bash)

#LTPTESTS = fcntl-locktests filecaps fs ipc mm pipes pty quickhit sched syscalls timers
LTPTESTS = ltplite
test3-ltp: state/prep ${QEMUSTATE}/qemu-build state/kernel-build vexpress-ltp.img
	mkdir -p ${TESTRESULTS}
	for LTPTEST in ${LTPTESTS} ; do \
		$(call qemu,${BOARD},${KERNELDIR},256,/dev/mmcblk0p2,rootfstype=ext4 rw init=/opt/ltp/run-tests.sh ltptest=$$LTPTEST,-sd vexpress-ltp.img) -net nic,macaddr=52:54:00:12:34:57 | tee ${TESTRESULTS}/clang-`date +%Y-%m-%d_%H:%M:%S`_$$LTPTEST.log; \
	done
#	${INSTALLDIR}/bin/qemu-system-arm -kernel ${KERNELDIR}/arch/arm/boot/zImage \
		-m 256 -M vexpress-a9 -nographic ${GDB_OPTS} \
		-append 'root=/dev/mmcblk0p2 console=earlycon console=ttyAMA0,38400n8 earlyprintk rootfstype=ext4 rw init=/opt/ltp/run-tests.sh ltptest='$$LTPTEST \
		-net nic,macaddr=52:54:00:12:34:57 \
		-sd vexpress-ltp.img \
		| tee ${TESTRESULTS}/clang-`date +%Y-%m-%d_%H:%M:%S`_$$LTPTEST.log; \
	done

test3-gcc-ltp: state/prep ${QEMUSTATE}/qemu-build state/kernel-gcc-build vexpress-ltp.img
	mkdir -p ${TESTRESULTS}
	for LTPTEST in ${LTPTESTS} ; do \
		$(call qemu,${BOARD},${KERNELDIR},256,/dev/mmcblk0p2,rootfstype=ext4 rw init=/opt/ltp/run-tests.sh ltptest=$$LTPTEST,-sd vexpress-ltp.img) -net nic,macaddr=52:54:00:12:34:57 | tee ${TESTRESULTS}/gcc-`date +%Y-%m-%d_%H:%M:%S`_$$LTPTEST.log; \
	done

test3-all-ltp: test3-ltp test3-gcc-ltp

patch-update: state/kernel-patch
	@${TOOLSDIR}/applyfilter.py ${ARCHALLPATCHES}/common.patch ${TMPDIR}/common.patch ${FILTERFILE}
	@${TOOLSDIR}/applyfilter.py ${ARCHALLPATCHES}/fix-warnings.patch ${TMPDIR}/fix-warnings.patch ${FILTERFILE}
	@${TOOLSDIR}/applyfilter.py ${ARCHALLPATCHES}/fix-warnings-unused.patch ${TMPDIR}/fix-warnings-unused.patch ${FILTERFILE}
	@${TOOLSDIR}/applyfilter.py ${ARCHARMPATCHES}/common-arm.patch ${TMPDIR}/common-arm.patch ${FILTERFILE}
	@${TOOLSDIR}/applyfilter.py ${ARCHARMPATCHES}/fix-warnings-arm.patch ${TMPDIR}/fix-warnings-arm.patch ${FILTERFILE}
	@${TOOLSDIR}/applyfilter.py ${ARCHARMPATCHES}/fix-warnings-arm-unused.patch ${TMPDIR}/fix-warnings-arm-unused.patch ${FILTERFILE}

