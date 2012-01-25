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
	lines=p.split("\n@@ -")[1:]
	lines=[ int(x.split(",")[0]) for x in lines ]

	return filename, lines

def gethunkinfo(patch):
	hunks=patch.split("\n@@ -")
	hunkinfo={}
	hunkinfo["header"]=hunks[0]
	for h in hunks[1:]:
		hunkinfo[int(h.split(",")[0])] = "@@ -"+h
	return hunkinfo

def mergehunks(hunkinfo1, hunkinfo2):
	for k in hunkinfo1.keys():
		if hunkinfo2.has_key(k):
			print "Patches have duplicated hunks! Merge failed."
	patch=hunkinfo1["header"]
	del hunkinfo1["header"]
	del hunkinfo2["header"]

	hunkinfo1.update(hunkinfo2)
	
	for k in sorted(hunkinfo1.keys()):
		patch += "\n"+hunkinfo1[k]

	return patch, sorted(hunkinfo1.keys())

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
		if patchinfo.has_key(filename):
			print "Merging hunks in", filename
			h1 = gethunkinfo(patchinfo[filename][1])
			h2 = gethunkinfo(p)
			p, lines = mergehunks(h1, h2)
		patchinfo[filename] = [lines, p]

	# Remove trailing "\n"
	#patchinfo[filename][1] = patchinfo[filename][1][:-1]
	return patchinfo

