#!/bin/bash
set +x

export RUNNING=true

while $RUNNING; do
    
    # for old kernels ... we deprecated that patch already.
    sed -i -e "s#extern inline#static inline#g" src/linux/drivers/gpu/drm/i915/i915_drv.h
    make $1 all test-kill
    ret=$?
    echo "ret = $ret"
    sleep 2
    make kernel-mrproper
    # revert above hack again.
    pushd src/linux 
     git checkout -- drivers/gpu/drm/i915/i915_drv.h
     echo -n "$(git log -1 --pretty=oneline) -- " >> ../../_single
    popd
    echo -n " $ret " >> _single


	if test x"$ret" == x"0" ; then
	    echo good
	    # 2nd if
	    if grep "BUG:" tmp/qemu_log ; then
		echo BUG
		echo BUG >> _single
	    else
	      export RUNNING=false
		echo "" >> _single
	    fi
	fi


	if $RUNNING; then
	    echo bad
	    pushd src/linux
	    git reset --hard HEAD~
	    popd
	fi

done