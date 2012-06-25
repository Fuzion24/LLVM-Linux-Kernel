#!/bin/sh
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

#TESTS=ltplite
TESTS="fcntl-locktests,filecaps,fs,ipc,math,mm,pipes,pty,quickhit,sched,syscalls,timers"

mount /proc
mount /sys
cd /opt/ltp

BEFORE=`date`
echo $BEFORE

./runltp -p -q -f "$TESTS"
cat results/*

echo "Start: $BEFORE"
echo "Finish: `date`"
