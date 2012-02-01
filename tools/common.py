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

class Patch:
	def __init__(self, patchdata):
		tmp=patchdata.split("--- a/")[1]
		self.filename=tmp.split("\n")[0]
		hunks=patchdata.split("\n@@ -")
		self.hunkinfo={}
		self.header=hunks[0]
		for h in hunks[1:]:
			self.hunkinfo[int(h.split(",")[0])]="@@ -"+h
	
	def __str__(self):
		patch=self.header
		for k in sorted(self.hunkinfo):
			patch+="\n"+self.hunkinfo[k]
		return patch+"\n"
		
	def merge(self, otherpatch):
		duplicates=[]
		for k in self.hunkinfo:
			if k in otherpatch.hunkinfo:
				duplicates.append(k)
		self.hunkinfo.update(otherpatch.hunkinfo)
		return (otherpatch.filename, duplicates)

	def getLines(self):
		return sorted(self.hunkinfo)

	def getFilename(self):
		return self.filename

	def compare(self, otherhunks):
		sk=sorted(self.hunkinfo)
		if sk==sorted(otherhunks.hunkinfo):
			return sk;
			
		matchedoffsets=[]
		for k in sk:
			if k in otherhunks.hunkinfo:
				matchedoffsets.append(k)
		return matchedoffsets

	def drophunks(self, hunks):
		for h in hunks:
			if h in self.hunkinfo:
				del self.hunkinfo[h]
				
			
class RejectedPatch(Patch):
	def __init__(self, patchdata):
		tmp=patchdata.split("--- ")[1]
		self.filename=tmp.split("\n")[0]
		hunks=patchdata.split("\n@@ -")
		self.hunkinfo={}
		self.header=hunks[0]
		for h in hunks[1:]:
			self.hunkinfo[int(h.split(",")[0])]="@@ -"+h

class PatchDict:
	def __init__(self):
		self.patch={}

	def __contains__(self, filename):
		return filename in self.patch

	def __getitem__(self, item):
		return self.patch[item]

	def __iter__(self):
		return self.patch.__iter__()

	def add(self, patch):
		dups=[]
		fn=patch.getFilename()
		if fn in self.patch:
			fn, duplicates=self.patch[fn].merge(patch)
			if duplicates:
				dups.append((fn, duplicates))
		else:
			self.patch[fn]=patch
		return dups
		
	def __delitem__(self, item):
		if item in self.patch:
			del self.patch[item]

	def write(self, outfile):
		plist=sorted(self.patch)
		if len(plist):
			fp=open(outfile,"w")
			if len(plist) > 1:
				for f in plist[:-1]:
					patch=str(self.patch[f])
					fp.write(patch)
			fp.write(str(self.patch[plist[-1]]))
		
	def drophunks(self, item, hunks):
		if item in self.patch:
			self.patch[item].drophunks(hunks)
			# If no hunks left, remove patch
			if not self.patch[item].getLines():
				del self.patch[item]

	def filter(self, filterfile):
		filename=""
		
		for line in open(filterfile).readlines():
			if line[0]=="F":
				filename=line[2:-1]
				print "Processing", filename
			elif line[0]=="M":
				filename=line[2:-1]
				if filename in self.patch:
					del self.patch[filename]
			elif line[0]=="R":
				filename=line[2:].split("[")[0][:-1]
				tmp=line.split("[")[1].split("]")[0].split(",")
				hunks=[ int(x) for x in tmp ]
				self.drophunks(filename, hunks)
			else:
				print "Error: Invalid Filter File"
				raise SystemExit
				
class PatchFile(PatchDict):
	def __init__(self, patchfile):
		PatchDict.__init__(self)
		self.filename=patchfile
		patchdata=open(patchfile).read()
		# Strip ending newline
		if patchdata.endswith("\n"):
			patchdata=patchdata[:-1]
		patches=patchdata.split("\ndiff")
		for p in patches:
			# add back the "diff"
			if p[0:4] !="diff":
				p="diff"+p+"\n"
			else:
				p+="\n"
			newpatch=Patch(p)
			PatchDict.add(self, newpatch)


