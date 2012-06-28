##############################################################################
# Copyright (c) 2012 Mark Charlebois
#                    Jan-Simon Möller
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

TOPDIR=${CWD}/../..
CWD=${CURDIR}
KERNEL_CFG=${CWD}/config_vexpress
KERNEL_GIT=git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
KERNELDIR=${SRCDIR}/linux
KERNELCOPY=${SRCDIR}/linux-copy
PATCH_FILES=${CWD}/workaround.patch ${CWD}/vexpress.patch

BUILDMODE:=DEFAULT

ifeq ('${GDBON}','1')
GDB_OPTS=-gdb tcp::4321 -S
else
GDB_OPTS=
endif

# initramfs.mk settings
BUILDDIR=${CWD}/tmp

all: prep kernel-build qemu-build

include ${TOPDIR}/common/common.mk
include ${TOPDIR}/qemu/qemu.mk
include ${TOPDIR}/test/ltp/ltp.mk
include ${TOPDIR}/common/arm/common-arm.mk
include ${TOPDIR}/initramfs/initramfs.mk

TARGETS+= clean mrproper test test2
.PHONY: test test2 prep clean mrproper

prep: state/prep
state/prep:
	@mkdir -p tmp
	@mkdir -p log
	@mkdir -p state
	@touch $@


clean: qemu-clean kernel-clean clang-clean initramfs-clean

# do a real wipe
mrproper: clean
	rm -rRf arm-test-0.2.tar.gz arm-test
#	rm -f state/fetch-initrd
	rm -rRf tmp/*
	rm -rRf log/*
	( cd ${KERNELDIR} && make mrproper )

#fetch-initrd: state/fetch-initrd
#state/fetch-initrd:
#	rm -f arm-test-0.2.tar.gz
#	wget -nd -c "http://wiki.qemu.org/download/arm-test-0.2.tar.gz"
#	tar -xzvf arm-test-0.2.tar.gz
#	@mkdir -p state
#	@touch $@

# state/fetch-initrd
test: state/prep ${QEMUSTATE}/qemu-build state/kernel-build
	@${INSTALLDIR}/bin/qemu-system-arm -kernel ${KERNELDIR}/arch/arm/boot/zImage -initrd reference/initramfs.img -m 768 -M vexpress-a9 -append 'mem=768M ramdisk_size=65536 rw console=earlycon console=ttyAMA0,38400n8 earlyprintk root=/dev/ram0' -nographic -net none ${GDB_OPTS}

test-ltp: state/prep ${QEMUSTATE}/qemu-build state/kernel-build
	@${INSTALLDIR}/bin/qemu-system-arm -kernel ${KERNELDIR}/arch/arm/boot/zImage -initrd reference/initramfs-ltp.img -m 768 -M vexpress-a9 -cpu cortex-a9 -append 'mem=768M ramdisk_size=327680 rw console=earlycon console=ttyAMA0,38400n8 earlyprintk root=/dev/ram0 rdinit=/bin/sh' -nographic -net none ${GDB_OPTS}


#	${INSTALLDIR}/bin/qemu-system-arm -kernel ${KERNELDIR}/arch/arm/boot/zImage \
#		-initrd arm-test/arm_root.img -M vexpress-a9 -append 'console=earlycon \
#		console=ttyAMA0,38400n8 earlyprintk root=/dev/ram0 rdinit=/bin/sh init=/bin/sh' -nographic -net none ${GDB_OPTS}

# state/fetch-initrd
test-kill: state/prep state/kernel-build ${QEMUSTATE}/qemu-build
	( ( ${INSTALLDIR}/bin/qemu-system-arm -kernel ${KERNELDIR}/arch/arm/boot/zImage -initrd reference/initramfs.img -m 256 -M vexpress-a9 -append 'mem=256M ramdisk_size=65536 rw console=earlycon console=ttyAMA0,38400n8 earlyprintk root=/dev/ram0 POWEROFF' -nographic -net none ${GDB_OPTS} | tee tmp/qemu_log ) & )
	( ( sleep 10 && killall -s 9 qemu-system-arm ) || exit 0 )
	@grep -a "SUCCESS" tmp/qemu_log 


test2: state/prep ${QEMUSTATE}/qemu-build state/kernel-build initramfs
	@${INSTALLDIR}/bin/qemu-system-arm -kernel ${KERNELDIR}/arch/arm/boot/zImage \
		-initrd initramfs.img.gz -M vexpress-a9 -append \
		'console=earlycon console=ttyAMA0,38400n8 earlyprintk init=/bin/init' -nographic ${GDB_OPTS}

LINARORELEASEURL=http://releases.linaro.org/images/12.03/oneiric/nano
LINAROBOARD=vexpress-a9
NANOBOARD=${LINAROBOARD}-nano
NANOIMG=${LINAROBOARD}.img

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

${TOPTMPDIR}/${NANOIMG}: ${TOPTMPDIR}/board-sources.txt
	(cd ${TOPTMPDIR} && echo sudo linaro-media-create --dev ${LINAROBOARD} --rootfs ext4 \
		`sed 's|.*nano.*/|--binary |; s|.*hwpack.*/|--hwpack |' $(notdir $<)` \
		--image-file $@ \
	)

# Build ltp image into vexpress image
vexpress-ltp.img: ${TOPTMPDIR}/${NANOBOARD}.img.gz ${LTPSTATE}/ltp-build ${LTPSTATE}/ltp-scripts
	gzip -dc $< > $@
	${TOOLSDIR}/partcopy.sh $@ rootfs ${LTPINSTALLDIR}/ /opt/ltp/ || (rm $@ && echo "E: $@ error" && false)

vexpress-ltp-clean:
	rm -f vexpress-ltp.img
vexpress-ltp-force: vexpress-ltp-clean vexpress-ltp.img

test3: state/prep ${QEMUSTATE}/qemu-build state/kernel-build vexpress.img
	@${INSTALLDIR}/bin/qemu-system-arm -kernel ${KERNELDIR}/arch/arm/boot/zImage \
		-m 256 -M vexpress-a9 -nographic ${GDB_OPTS} \
		-append 'root=/dev/mmcblk0p2 console=earlycon console=ttyAMA0,38400n8 earlyprintk rootfstype=ext4 init=/bin/bash' \
		-sd vexpress.img

test3-ltp: state/prep ${QEMUSTATE}/qemu-build state/kernel-build vexpress-ltp.img
	${INSTALLDIR}/bin/qemu-system-arm -kernel ${KERNELDIR}/arch/arm/boot/zImage \
		-m 256 -M vexpress-a9 -nographic ${GDB_OPTS} \
		-append 'root=/dev/mmcblk0p2 console=earlycon console=ttyAMA0,38400n8 earlyprintk rootfstype=ext4 rw init=/bin/bash' \
		-net nic,macaddr=52:54:00:12:34:57 \
		-sd vexpress-ltp.img

patch-update: state/kernel-patch
	@${TOPDIR}/tools/applyfilter.py ${TOPDIR}/common/common.patch ${TMPDIR}/common.patch ${CWD}/kernel-filter
	@${TOPDIR}/tools/applyfilter.py ${TOPDIR}/common/fix-warnings.patch ${TMPDIR}/fix-warnings.patch ${CWD}/kernel-filter
	@${TOPDIR}/tools/applyfilter.py ${TOPDIR}/common/fix-warnings-unused.patch ${TMPDIR}/fix-warnings-unused.patch ${CWD}/kernel-filter
	@${TOPDIR}/tools/applyfilter.py ${TOPDIR}/common/arm/common-arm.patch ${TMPDIR}/common-arm.patch ${CWD}/kernel-filter
	@${TOPDIR}/tools/applyfilter.py ${TOPDIR}/common/arm/fix-warnings-arm.patch ${TMPDIR}/fix-warnings-arm.patch ${CWD}/kernel-filter
	@${TOPDIR}/tools/applyfilter.py ${TOPDIR}/common/arm/fix-warnings-arm-unused.patch ${TMPDIR}/fix-warnings-arm-unused.patch ${CWD}/kernel-filter

kernel-copy: state/kernel-copy
state/kernel-copy: kernel-fetch
	(cd ${SRCDIR} && git clone ${KERNELDIR} linux-copy)
	@touch $@

kernel-autopatch: kernel-build state/kernel-copy
	(cd ${KERNELCOPY} && git reset --hard HEAD && git pull)
	(cd ${KERNELCOPY} &&  patch -p1 -i ${TMPDIR}/final.patch >> ${LOGDIR}/patchcopy.log)
	@${TOOLSDIR}/unusedfix.py ${LOGDIR}/build.log ${KERNELCOPY} 
	(cd ${KERNELCOPY} &&  patch -R -p1 -i ${TMPDIR}/final.patch >> ${LOGDIR}/patchcopy.log)
	(cd ${KERNELCOPY} && git diff > ${TMPDIR}/autopatch.patch)
	@${TOOLSDIR}/splitarch.py ${TMPDIR}/autopatch.patch ${CWD} autopatch
	@touch $@
