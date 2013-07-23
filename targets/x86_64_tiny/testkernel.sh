#!/bin/bash
set +x

export RUNNING=true

while $RUNNING; do
    
    # for old kernels ... we deprecated that patch already.
    sed -i -e "s#extern inline#static inline#g" src/linux/drivers/gpu/drm/i915/i915_drv.h
    make all test-kill
    ret=$?
    echo "ret = $ret"

    # revert above hack again.
    pushd src/linux ; git checkout -- drivers/gpu/drm/i915/i915_drv.h; popd
    echo "worked [y/N]" ?
    read aw
    if test x"$aw" == x"" -o x"$aw" == x"n" -o x"$aw" == x"N" ; then
	export ret=1
    fi

    if test x"$aw" == x"y" -o x"$aw" == x"Y" ; then
	export ret=0 
    fi

    if test x"$ret" == x"0" ; then
	echo good
	make kernel-bisect-good 2>&1 | tee bisectlog
    else 
	echo bad
	make kernel-bisect-bad 2>&1 | tee bisectlog
    fi
    rm initramfs.img.gz.clang -f 2>&1 > /dev/null

    grep -i "first good commit" bisectlog && export RUNNING=false
    grep -i "first bad commit" bisectlog && export RUNNING=false
done