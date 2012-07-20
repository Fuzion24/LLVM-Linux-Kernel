#!/bin/bash

# PATH, LLVMINSTALLDIR, CSCC_DIR, CSCC_BINDIR, and HOST_TYPE are exported from the Makefile

export PATH=`echo $PATH | sed -E 's/(.*?) :(.*)/\2\1/g; s/(.*?) :(.*)/\2\1/g; s/(.*?) :(.*)/\2\1/g'`

CLANGFLAGS="-march=i586 -fcatch-undefined-behavior"

CC="$LLVMINSTALLDIR/bin/clang ${CLANGFLAGS}"

${CC} $*
