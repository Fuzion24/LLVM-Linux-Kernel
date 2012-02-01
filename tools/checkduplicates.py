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

##############################################################################
# Purpose: find duplicates in this patch file and other patch files
##############################################################################
import os, sys
from common import *


def usage():
	print "Error: Invalid arguments"
	print "Usage: %s patchfile1 patchfile2 ..." % os.path.basename(sys.argv[0])

def main():
	if len(sys.argv) < 3:
		usage()
		raise SystemExit

	filemap = {}
	for patchfile in sys.argv[1:]:
		pf = PatchFile(patchfile)
		for k in pf.patch:
			p = pf.patch[k]
			for linenum in p.getLines():
				key = (p.filename, linenum)
				if not key in filemap:
					filemap[(p.filename, linenum)] = [patchfile]
				else:
					filemap[(p.filename, linenum)].append(patchfile)
	for k in filemap:
		if len(filemap[k]) > 1:
			print "Duplicate hunk: %s %d in:" % k
			for f in filemap[k]:
				print "  %s" % f
			
	
if __name__ == "__main__":
    main()
