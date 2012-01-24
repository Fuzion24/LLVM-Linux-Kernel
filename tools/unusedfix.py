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
	print "Usage: %s filename [srcdir]" % os.path.basename(sys.argv[0])

false_positives = [	"dev_dbg", 
			"INPUT_CLEANSE_BITMASK", 
			"DEFINE_LGLOCK",
			"DEFINE_BRLOCK",
			"write_lock_irqsave",
			"write_unlock_irqrestore",
			"snd_pcm_stream_lock_irqsave",
			"snd_pcm_stream_unlock_irqrestore",
			"read_lock_irqsave",
			"read_unlock_irqrestore",
			"put_user",
			"get_user",
			"__get_user",
			"__put_user",
			"clear_page",
			"readl",
			"if" ]
			

def skip_patch(line):
	for p in false_positives:
		if line.startswith(p):
			return 1
	return 0

def main():
	searchstr="warning: expression result unused"
	fixes=[]
	applied={}
	prefix=""

	if len(sys.argv) < 2 or len(sys.argv) > 3:
		usage()
		raise SystemExit

	if len(sys.argv) == 3:
		prefix=sys.argv[2]+"/"
	fp=open(sys.argv[1])
	line=fp.readline()
	while line:
		if searchstr in line:
			fixfile, fixline = line.split(":")[:2]
			line = fp.readline().strip()
			if not skip_patch(line):
				fixes.append([fixfile, int(fixline), line])
		line=fp.readline()

	for fix in fixes:
		if applied.has_key((fix[0],fix[1])):
			continue

		file_lines = open(prefix+fix[0]).readlines()
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
