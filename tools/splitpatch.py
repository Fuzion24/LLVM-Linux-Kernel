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
# Purpose: Split the patch file into architecture and non-architecture 
#          specific patches
##############################################################################
import os, sys
from common import readpatch

def usage():
	print "Error: Invalid arguments"
	print "Usage: %s patchfile outdir fileprefix" % os.path.basename(sys.argv[0])


def main():
	searchstr="diff"
	armpatches=[]
	mipspatches=[]
	allpatches=[]

	if len(sys.argv) < 4:
		usage()
		raise SystemExit

	patches = readpatch(sys.argv[1])

	for name in sorted(patches.keys()):
		if "/arm/" in name:
			armpatches.append(patches[name][1])
		elif "/mips/" in name:
			mipspatches.append(patches[name][1])
		else:
			allpatches.append(patches[name][1])

	if armpatches:
		fp=open(sys.argv[2]+"/"+sys.argv[3]+"-arm.patch", "w")
		for p in armpatches:
			fp.write(p)
	if mipspatches:
		fp=open(sys.argv[2]+"/"+sys.argv[3]+"-mips.patch", "w")
		for p in mipspatches:
			fp.write(p)
	if allpatches:
		fp=open(sys.argv[2]+"/"+sys.argv[3]+".patch", "w")
		for p in allpatches:
			fp.write(p)

	
if __name__ == "__main__":
    main()
