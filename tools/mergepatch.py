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
# Purpose: Take two patch files with overlapping patches and remove the    
#          duplicates 
##############################################################################
import os, sys
from common import *

def usage():
	print "Error: Invalid arguments"
	print "Usage: %s [-k|-d] patchfile1 patchfile2" % os.path.basename(sys.argv[0])
	print "          or"
	print "Usage: %s -e patchfile1 patchfile2 commonpatchfile" % os.path.basename(sys.argv[0])
	print "\t-k  Keep the common patches in the first file, drop from the second"
	print "\t-d  Drop the common patches from the first file, keep in the second"
	print "\t-e  Extract the common patches from both files and write to the third file"
	raise SystemExit


def main():
	armpatches=[]
	mipspatches=[]
	allpatches=[]

	if len(sys.argv) < 4:
		usage()

	if sys.argv[1] in [ "-k", "--keep"]:
		mode = "keep"
	elif sys.argv[1] in [ "-d", "--drop"]:
		mode = "drop"
	elif sys.argv[1] in [ "-e", "--extract"]:
		if sys.argv != 5:
			usage()
		mode = "extract"
	else:
		usage()

	patches1 = PatchFile(sys.argv[2])
	patches2 = PatchFile(sys.argv[3])
	patches3 = {}

	for name in sorted(patches1):
		if name in patches2:
			print patches1[name].getLines()
			print patches2[name].getLines()
			# if all hunk offsets are identical
			matches = patches1[name].compare(patches2[name])
			if matches == patches1[name].getLines():
				if mode == "extract":
					patches3[name] = patches2[name]
				if not mode == "keep":
					print "Dropping", name, "from", sys.argv[2]
					del patches1[name]
				if not mode == "drop":
					del patches2[name]

	if mode == "extract":
		fp=open(sys.argv[4], "w")
		for key in sorted(patches3.keys()):
			fp.write(patches3[key].str())
	if not mode == "keep":
		fp=open(sys.argv[2], "w")
		for key in sorted(patches1.keys()):
			fp.write(patches1[key].str())
	if not mode == "drop":
		fp=open(sys.argv[3], "w")
		for p in sorted(patches2.keys()):
			fp.write(patches2[key].str())

	
if __name__ == "__main__":
    main()
