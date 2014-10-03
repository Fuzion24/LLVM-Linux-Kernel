/**
 * Copyright (c) 2014 Mark Charlebois
 *
 * All rights reserved. 
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted (subject to the limitations in the disclaimer
 * below) provided that the following conditions are met:
 * 
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 *  
 * - Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * - Neither the name KernelViz nor the names of its contributors may be used
 *   to endorse or promote products derived from this software without 
 *   specific prior written permission.
 * 
 * NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE GRANTED BY
 * THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
 * CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT
 * NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

var fs = require('fs')
var S = require('string');
var dir = require('node-dir');
var dot = require('graphlib-dot');
var keys = Object.keys || require('object-keys');

var Modules = new Object;
var Globals = new Object;
var Symbols = new Object;
var Unresolved = [];

var index = 0;

function resolve() {
  // For all nodes in all modules
  keys(Modules).forEach(function (file) {
    keys(Modules[file].Nodes).forEach(function (nodeLabel) {
      
      Modules[file].Nodes[nodeLabel].isExported = false;
      var node = Modules[file].Nodes[nodeLabel];

      // See if the node is unused
      if (node.isExternal === false && node.isGlobal === false) {
        node.isUnused = true;
        // See if the node has outward edges, if so
        // it must be a locally defined function
        keys(Modules[file].Edges).some(function (edgeLabel) {
          if (Modules[file].Edges[edgeLabel].n1 === nodeLabel ||
             Modules[file].Edges[edgeLabel].n2 === nodeLabel) {
            node.isUnused = false;
            return !node.isExternal;
          }
        });
      }
      var funcname = nodeLabel.substring(1, nodeLabel.length-1);
      var symbolFiles = Symbols[funcname];
      var ksymFiles = Symbols["__ksymtab_"+funcname];

      if (symbolFiles && symbolFiles.lineno) {
        // Add global ksyms
        if (symbolFiles.symtype == "T" && Globals[nodeLabel] === undefined) {
          Globals[nodeLabel] = new Object;
          Globals[nodeLabel].lineno = [];
          Globals[nodeLabel].dotfile = [];
          symbolFiles.lineno.forEach(function (lineno) { 
            if (lineno) {
              var filename = lineno.split(":")[0];
              var dotfile = filename.substring(0, filename.length-2)+".dot";
              // verify the dot file exists
              if (Modules[dotfile] !== undefined) {
                Globals[nodeLabel].dotfile.push(dotfile);
              }
              Globals[nodeLabel].lineno.push(symbolFiles.lineno);
            }
          });
        // Add lineno info to local functions
        } else if (symbolFiles.symtype == "t") {
          // See if there is a matching lineno for the module
          Modules[file].Nodes[nodeLabel].lineno = [];
          symbolFiles.lineno.some(function (lineno) { 
            if (lineno) {
              var filename = lineno.split(":")[0];
              var dotfile = filename.substring(0, filename.length-2)+".dot";
              if (file == dotfile) {
                Modules[file].Nodes[nodeLabel].lineno.push(lineno);
                return true;
              }
            }
          });
        }
      // If the node/function is global but not in obj files, it must be exported
      } 
      if (node.isGlobal) {

	if (node.isExternal === true) {
	  // See if the node has outward edges, if so
	  // it must be a locally defined function
	  keys(Modules[file].Edges).forEach(function (edgeLabel) {
	    if (Modules[file].Edges[edgeLabel].n1 === nodeLabel)
	      Modules[file].Nodes[nodeLabel].isExternal = false;
          });
          // if the function is defined in the file and is global and there 
          // was no global symbol for it in the obj files then use this file 
          if ((symbolFiles === undefined || symbolFiles.symtype != "T") && 
              Modules[file].Nodes[nodeLabel].isExternal === false) {
            console.log("Externally referenced: "+nodeLabel+" "+file);
            Modules[file].Nodes[nodeLabel].isExported = true;
            Modules[file].Nodes[nodeLabel].isGlobal = false;
          } else if (ksymFiles === undefined) {
            Unresolved.push([nodeLabel, file, "External"]);
          }
        // If no global definition for function
        } else if (symbolFiles === undefined || symbolFiles.symtype != "T") {
          if (Globals[nodeLabel] === undefined)
            Globals[nodeLabel] = new Object;
          if (Globals[nodeLabel].dotfile === undefined)
            Globals[nodeLabel].dotfile = [];
          Globals[nodeLabel].dotfile.push(file);
          Globals[nodeLabel].fromDotfile = true;
        }
      }

      if (ksymFiles) {
        if (Modules[file].Nodes[nodeLabel].ksyms === undefined)
          Modules[file].Nodes[nodeLabel].ksyms = [];
        Modules[file].Nodes[nodeLabel].ksyms.push(ksymFiles.lineno);
        //Modules[file].Nodes[nodeLabel].isExported = true;
        // If no lineno for symbol, use ksym to try to guess dot file
        if (Modules[file].Nodes[nodeLabel].dotfile === undefined) {
          if (ksymFiles.lineno) {
            ksymFiles.lineno.forEach(function (lineno) {
              var filename = lineno.split(":")[0];
              var dotfile = filename.substring(0, filename.length-2)+".dot";
              // Add a dotfile unless it is for a node in current file
              if (Modules[dotfile] !== undefined && dotfile != file) {
                if (Modules[file].Nodes[nodeLabel].dotfile == undefined) {
                  Modules[file].Nodes[nodeLabel].dotfile = [];
                }
                Modules[file].Nodes[nodeLabel].dotfile.push(dotfile);
              }
            });
          }
        }
      }
    });
  }); 

  // Create cross-reference
  keys(Modules).forEach(function (file) {
    keys(Modules[file].Nodes).forEach(function (node) {
      if (Modules[file].Nodes[node].isExternal === true &&
          Modules[file].Nodes[node].isGlobal === true) {
          Modules[file].Globals[node] = Globals[node];
      }
    });
  });
  fs.writeFile("data/Globals.json", JSON.stringify(Globals, null, " "));
  fs.writeFile("data/ModulesResolved.json", JSON.stringify(Modules, null, " "));
  fs.writeFile("data/Unresolved.json", JSON.stringify(Unresolved, null, " "));
}

// Reload the parsed data
if (process.argv.length != 2) {
  console.log("Usage: nodejs Resolve.js");
}
else {
  console.log("Loading cached data");
  fs.readFile("data/Modules.json", 'utf8', function (err, data) {
    if (err) {
      console.log(""+err);
      process.exit(1);
    }
    Modules = JSON.parse(data);
    fs.readFile("data/Symbols.json", 'utf8', function (err, data) {
      if (err) {
        console.log("" + err);
        process.exit(1);
      }
      Symbols = JSON.parse(data);
      resolve();
    });
  });
}

