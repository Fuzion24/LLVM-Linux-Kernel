#!/usr/bin/env python
##############################################################################
# Copyright (c) 2012 Mark Charlebois
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

import os, sys


def usage():
	print "Error: Invalid arguments"
	print "Usage: %s logfile srcdir" % os.path.basename(sys.argv[0])

fixable = [
	"memset",
	"ASSERT_RDEV_LOCK",
	"ASSERT_WDEV_LOCK",
	"bio_integrity_clone",
	"blk_integrity_register",
	"CFG80211_DEV_WARN_ON",
	"CLEAR_AFTER_FIELD",
	"clear_page",
	"cmpxchg",
	"dev_vdbg",
	"do_div",
	"fops_get",
	"format_dev_t",
	"freezable_schedule_timeout_killable",
	"__get_user",
	"get_user",
	"hugetlb_free_pgd_range",
	"hybrid_tuner_release_state",
	"inb",
	"J_EXPECT_JH",
	"lockdep_assert_held",
	"lock_task_sighand",
	"memcpy",
	"memzero",
	"netdev_WARN",
	"on_each_cpu",
	"psmouse_dbg",
	"__put_user",
	"put_user",
	"RB_WARN_ON",
	"readb",
	"register_hotcpu_notifier",
	"sk_wait_event",
	"start_thread",
	"tcp_verify_left_out",
	"try_then_request_module",
	"typecheck",
	"wait_event_freezable",
	"wait_event_interruptible",
	"wait_event_interruptible_timeout",
	"wait_event_interruptible_tty",
	"wait_event_timeout",
	"WARN",
	"WARN_CONSOLE_UNLOCKED",
	"WARN_ON",
	"WARN_ONCE",
	"WARN_ON_ONCE",
	"WARN_RATELIMIT",
	"xchg" ]
		
def skip_patch(line):
	for p in fixable:
		if line.startswith(p):
			return 0
	return 1

def main():
	searchstr="warning: expression result unused"
	fixes=[]
	applied={}

	if len(sys.argv) != 3:
		usage()
		raise SystemExit

	prefix=sys.argv[2]+"/"
	fp=open(sys.argv[1])
	line=fp.readline()
	while line:
		if searchstr in line:
			print line
			if line.startswith("clang: "):
				line=line[7:]
			fixfile, fixline = line.split(":")[:2]
			if fixfile.strip() and fixline.strip():
				print "**", fixfile, fixline
				line = fp.readline().strip()
				print line
				if not skip_patch(line):
					fixes.append([fixfile, int(fixline), line])
		line=fp.readline()

	for fix in fixes:
		if applied.has_key((fix[0],fix[1])):
			continue

		try:
			file_lines = open(prefix+fix[0]).readlines()
		except:
			print "Error: Failed to open", prefix+fix[0]
			continue
		idx = fix[1]-1
		old_line = file_lines[idx];
		file_lines[idx] = file_lines[idx].replace(fix[2], "(void)"+fix[2])

		if old_line == file_lines[idx]:
			print "Failed %s: line %d" % (fix[0], fix[1])
		else:
			print "Patched %s: line %d" % (fix[0], fix[1])

		applied[(fix[0],fix[1])] = 1
		open(prefix+fix[0], "w").writelines(file_lines)

	
if __name__ == "__main__":
    main()
