#!/usr/bin/env python

import os

def usage():
   print("%s filelist" % os.sys.argv[0])

def gettokens(hunks):
   tokenmap = {}
   for h in hunks:
      tmp=h.split("\n")
      token=tmp[0][:-1]
      base = getbasetoken(token)
      #print("Token: %s" % token)
      if token[-6:] == "_probe" or token[-5:] == "_init": 
         if not tokenmap.has_key(base):
            tokenmap[base] = "i"
         elif tokenmap[base] == "e":
            tokenmap[base] = "r"
      elif token[-7:] == "_remove" or token[-5:] == "_exit":
         if not tokenmap.has_key(base):
            tokenmap[base] = "e"
         elif tokenmap[base] == "i":
            tokenmap[base] = "r"
      else:
         print("Token unknown: %s" % token)
   return tokenmap

def getbasetoken(token):
   if token[-6:] == "_probe":
      return token[:-6]
   elif token[-7:] == "_remove":
      return token[:-7]
   elif token[-5:] == "_init":
      return token[:-5]
   elif token[-5:] == "_exit":
      return token[:-5]
   else:
      return token
      
def processhunks(hunks):
   filemap = {}
   for hunk in hunks:
      tmp=hunk.split("\n")[:-1]
      token=tmp[0][:-1]
      basetoken = getbasetoken(token)
      decltype=""
      #print("Token: %s" % token)
      idx=1
      while idx < len(tmp):
	 tmp2 = tmp[idx].split(":")
	 #print("TMP2 = '%s'" % tmp2)
	 if tmp2[0][0:7] == "src/msm":
	    fname = tmp2[0]
	    if not filemap.has_key((fname, basetoken)):
		   filemap[(fname,basetoken)] = []
	    #print("File: %s" % fname)
	 #print("TMP2[1] = '%s'" % tmp2[1].strip())
	 tmp3=tmp2[1].strip()
	 if tmp3[0:6] == "static":
	    tmp4 = tmp3.split(" ")
	    for t in tmp4:
	       if t[0:2] == "__":
		  decltype = t
	    #print("%s %s %s" % (token, fname, decltype))
	 if tmp3[0:6] == ".probe":
	    #print("%s %s %s %s" % (token, fname, "probe", decltype))
	    filemap[(fname,basetoken)].append(decltype)
	 elif tmp3[0:7] == ".remove":
	    #print("%s %s %s %s" % (token, fname, "remove", decltype))
	    filemap[(fname,basetoken)].append(decltype)
	 idx+=1

   return filemap 

if __name__ == "__main__":
   if len(os.sys.argv) != 2:
      usage()
      raise SystemExit

   body=open(os.sys.argv[1]).read()
   hunks=body.split("-- ")[1:]
   tokenmap = gettokens(hunks)
   print("%s" % tokenmap)
   fmap = processhunks(hunks)
   for key in fmap.keys():
      if len(fmap[key]) == 1:
         if fmap[key][0] == "__devinit":
            ref = "__initdata"
         elif fmap[key][0] == "__devexit":
            ref = "__exitdata"
      elif len(fmap[key]) == 2:
         if "__devinit" in fmap[key] and "__devexit" in fmap[key]:
            ref = "__refdata"
      else:
         ref = "unknown"
      if ref != "unknown":
         print(key[0])
         print("   %s" % key[1])
         newfile=""
         count=0
	 for line in open(key[0]).readlines():
            if line.startswith("static struct platform_driver"):
               tmp = line.split("=")
               tmp2 = tmp[0].split(" ")
               count+=1
               if "__initdata" in tmp2 or "__exitdata" in tmp2 or "__refdata" in tmp2:
                  newfile+=line
                  print("      unchanged: %s" % line[:-1])
               else:
                  newfile+="%s %s = %s" % (tmp[0], ref, tmp[1])
                  print("      patched  : %s %s = %s" % (tmp[0], ref, tmp[1][:-1]))
            else:
               newfile+=line
         if count == 1:
            open(key[0],"w").write(newfile)
      else:
         print("Unknown: %s %s" % key)

