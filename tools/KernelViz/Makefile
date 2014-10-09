##############################################################################
# Copyright (c) 2014 Mark Charlebois
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

TOPDIR = $(realpath ../..)
include ../../common.mk 

# Set these to the locations on your system
TARGET=vexpress
DOT_FILE_BASE=../../targets/${TARGET}/src/linux
OBJ_FILE_BASE=../../targets/${TARGET}/build/kernel-clang
SRC_FILE_BASE=../../targets/${TARGET}/src/linux

node_modules: 
	-[ -d node_modules/string ] || npm install string
	-[ -d node_modules/node-dir ] || npm install node-dir
	-[ -d node_modules/graphlib ] || npm install graphlib
	-[ -d node_modules/graphlib-dot ] || npm install graphlib-dot@0.4.10
	-[ -d node_modules/object-keys ] || npm install object-keys
	-[ -d node_modules/path ] || npm install path

data/Modules.json: ReadDotFiles.js
	nodejs ReadDotFiles.js ${DOT_FILE_BASE}

data/Symbols.json: ReadSymbols.js
	nodejs ReadSymbols.js ${OBJ_FILE_BASE} ${SRC_FILE_BASE}

data/ModulesResolved.json: Resolve.js data/Modules.json data/Symbols.json
	nodejs Resolve.js

data/TopViewFG.json: TopView.js data/ModulesResolved.json
	nodejs TopView.js

database: data/ModulesResolved.json data/TopViewFG.json

kernelviz: database
	echo "Open your browser to http://localhost:8001"
	nodejs KernelViz.js
