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
from common import readpatch


def usage():
	print "Error: Invalid arguments"
	print "Usage: %s patchfile patchfile1 patchfile2 ..." % os.path.basename(sys.argv[0])

def main():
	if len(sys.argv) < 3:
		usage()
		raise SystemExit

	patchedfiles = readpatch(sys.argv[1])

	for f in sys.argv[2:]:
		pf = readpatch(f)
		for k in patchedfiles.keys():
			if pf.has_key(k):
				if pf[k][0] == patchedfiles[k][0]:
					print "Exact match: %s : %s" % (f, k)
					continue
				else:
					for t in patchedfiles[k][0]:
						if t in pf[k][0]:
							print "Partial match: %s : %s line %s" % (f, k, t)
				print "File match in %s : %s" % (f, k)
				print "   %s: %s" % (pf[k][0], patchedfiles[k][0])
	
	
if __name__ == "__main__":
    main()
