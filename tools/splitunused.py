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
	print "Usage: %s patchfile outdir fileprefix" % os.path.basename(sys.argv[0])

def main():
	searchstr="diff"
	unusedpatches=[]
	allpatches=[]

	if len(sys.argv) < 4:
		usage()
		raise SystemExit

	patchfile=open(sys.argv[1]).read()
	patches = patchfile.split("\ndiff")

	for p in patches:
		# add back the "diff" and "\n"
		if p[0:4] != "diff":
			p="diff"+p+"\n"
		else:
			p=p+"\n"

		unused = 0
		lines = p.split("\n")
		for line in lines:
			if len(line) > 8 and line[0] == "+" and line[1] != '+':
				if line[1:].strip()[0:6] == "(void)":
					unusedpatches.append(p)
					unused = 1
					break
		
		if not unused:
			allpatches.append(p)

	if unusedpatches:
		# Remove trailing "\n"
		unusedpatches[-1]=unusedpatches[-1][:-1]
		fp=open(sys.argv[2]+"/"+sys.argv[3]+"-unused.patch", "w")
		for p in unusedpatches:
			fp.write(p)
	if allpatches:
		# Remove trailing "\n"
		allpatches[-1]=allpatches[-1][:-1]
		fp=open(sys.argv[2]+"/"+sys.argv[3]+".patch", "w")
		for p in allpatches:
			fp.write(p)

	
if __name__ == "__main__":
    main()
