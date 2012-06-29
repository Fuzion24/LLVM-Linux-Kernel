#!/bin/bash

#TESTS=ltplite
TESTS=${1:-`cat /proc/cmdline | sed -e 's/^.*ltptest=\([^ ]*\).*$/\1/; s/.*=.*//'`}
TESTS=${TESTS:-fcntl-locktests,filecaps,fs,ipc,mm,pipes,pty,quickhit,sched,syscalls,timers}

echo "Running tests: $TESTS"

# Setup environment
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
mount /proc
mount /sys
cd /opt/ltp

# Remove past test results
rm -f results/*.log output/*.failed 2>/dev/null

# Timing before
BEFORE=`date +%s`
date --date "@$BEFORE"

# Run tests
./runltp -p -q -f "$TESTS"

# Timing after
AFTER=`date +%s`
DIFF=$(($AFTER - $BEFORE))

# Display test results
echo "--- Results --------------------------------------------------------------------"
cat results/*.log
echo "--- End Results ----------------------------------------------------------------"
echo
echo "Start:  `date --date @$BEFORE` ($BEFORE)"
echo "Finish: `date --date @$AFTER` ($AFTER)"
echo "Elapsed: `date --date @$DIFF` ($DIFF)"
echo
echo "--- Failures -------------------------------------------------------------------"
cat output/*.failed 2>/dev/null
echo "--- End Failures ---------------------------------------------------------------"

# Shutdown
poweroff -f
