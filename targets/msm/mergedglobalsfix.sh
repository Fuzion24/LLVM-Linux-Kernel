#!/bin/bash
#make kernel-build > logmg 2>&1
cat logmg | grep "Section mismatch in reference" | sed -e "s/^.*://" | cut -f1 -d"(" | sort | uniq > listmg
rm -rf src/msm-mgf
git clone src/msm/.git src/msm-mgf
for f in `cat listmg`; do echo "--" $f":"; find src/msm-mgf -name "*.c" | xargs grep $f; done > filesmg
./mergedglobalsfix.py  filesmg
pushd .
cd src/msm-mgf
git diff > msm-3.4-llvm-mg.patch
popd
