#!/bin/bash
#make kernel-build > logmg 2>&1
cat logmg | grep "Section mismatch in reference" | sed -e "s/^.*://" | cut -f1 -d"(" | sort | uniq > listmg
rm -rf src/msm-mgf
git clone src/msm/.git src/msm-mgf

# Get the current commit
pushd .
COMMIT=`cd src/msm && git log | head -n1 | cut -d" " -f2`
popd

# Sync to the same commit in clone
pushd .
cd src/msm-mgf
git checkout ${COMMIT}
popd

# Find the files
for f in `cat listmg`; do echo "--" $f":"; find src/msm-mgf -name "*.c" | xargs grep $f; done > filesmg

# Modify the files
./mergedglobalsfix.py  filesmg

# Create the patch 
pushd .
cd src/msm-mgf
git diff > msm-3.4-llvm-mg.patch
popd

#cat src/msm-mgf/msm-3.4-llvm-mg.patch | grep diff | sed -e "s/diff --git a\///" | sed -e "s/ .*//"
