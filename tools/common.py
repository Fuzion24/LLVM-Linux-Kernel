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


def getpatchinfo(patch):
	p = patch.split("\n--- a/")[1]

	filename = p.split("\n")[0]
	lines=p.split("\n@@ ")[1:]
	lines=[ x.split(",")[0] for x in lines ]

	return filename, lines

def readpatch(patchfile):
	patchinfo = {}
	patchdata = open(patchfile).read()
	patches = patchdata.split("\ndiff")
	for p in patches:
		# add back the "diff" and "\n"
		if p[0:4] != "diff":
			p="diff"+p+"\n"
		else:
			p=p+"\n"
		filename, lines = getpatchinfo(p)
		patchinfo[filename] = [lines, p]

	# Remove trailing "\n"
	patchinfo[filename][1] = patchinfo[filename][1][:-1]
	return patchinfo

