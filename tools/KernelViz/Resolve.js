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
var path = require('path');
var dot = require('graphlib-dot');
var keys = Object.keys || require('object-keys');

var Modules = new Object;
var Symbols = new Object;
var Unresolved = [];

var index = 0;

function Node(node, nodeLabel, file, edges, isGlobal, ksymFiles) {

  // this.node will be sent to the client so all client info 
  // must be in this.node
  this.node = node;
  this.nodeLabel = nodeLabel;
  this.edges = edges;
  this.symIsGlobal = isGlobal;
  this.ksymFiles = ksymFiles;
  this.file = file;
  this.node.unused = true;
  this.unresolved = false;
  this.node.isExported = false;

  //console.log("Newnode: "+JSON.stringify(this.node));

  this.CheckIfUnused = function() {
    var self = this;
    // See if the node is unused
    if (this.node.isExternal === false && this.node.isGlobal === false) {
      this.node.isUnused = true;
      // See if the node has outward edges, if so
      // it must be a locally defined function
      keys(this.edges).some(function (edgeLabel) {
        if (self.edges[edgeLabel].n1 === self.nodeLabel ||
           self.edges[edgeLabel].n2 === self.nodeLabel) {
          self.node.isUnused = false;
          return !self.node.isExternal;
        }
      });
    }
  }

  this.CheckIfKsyms = function(Modules) {
    // If there are kysms for the function
    var self = this;
    if (this.ksymFiles) {
      this.AddKsym(this.ksymFiles.lineno);
      //Modules[file].Nodes[nodeLabel].isExported = true;
      // If no lineno for symbol, use ksym to try to guess dot file
      if (this.node.dotfile === undefined) {
        if (this.ksymFiles.lineno) {
          this.ksymFiles.lineno.forEach(function (lineno) {
            var filename = path.normalize(lineno.split(":")[0]);
            var dotfile = filename.substring(0, filename.length)+"_.dot";
            // Add a dotfile unless it is for a node in current file
            if (Modules[dotfile] !== undefined && dotfile != self.file) {
              if (self.node.dotfile == undefined) {
                self.node.dotfile = [];
              }
              self.node.dotfile.push(dotfile);
            }
          });
        }
      }
    }
  }

  this.CheckIfExported = function() {
    // If the node/function is global but not in obj files, it must be exported
    var self = this;
    if (this.node.isGlobal) {
      if (this.node.isExternal === true) {
        // See if the node has outward edges, if so
        // it must be a locally defined function
        keys(this.edges).forEach(function (edgeLabel) {
          if (self.edges[edgeLabel].n1 === self.nodeLabel)
            self.node.isExternal = false;
        });
        // if the function is defined in the file and is global and there 
        // was no global symbol for it in the obj files then use this file 
        if (this.symIsGlobal && this.node.isExternal === false) {
          //console.log("Externally referenced: "+this.nodeLabel+" "+this.file);
          this.node.isExported = true;
          this.node.isGlobal = false;
        } 
        else if (this.ksymFiles === undefined) {
          this.unresolved = true;
        }
      } 
    }
  }

  this.AddLineno = function(lineno) {
    if (!this.lineno)
      this.lineno = [];
    this.lineno = this.lineno.concat(lineno);
  }

  this.AddDotFile = function(dotfile) {
    if (!this.dotfile)
      this.dotfile = [];
    this.dotfile = this.dotfile.concat(dotfile);
  }

  this.AddKsym = function(ksym) {
    if (!this.node.ksyms)
      this.node.ksyms = [];
    this.node.ksyms = this.node.ksyms.push(ksym);
  }
}

function resolve() {
  // For all nodes in all modules
  keys(Modules).forEach(function (file) {
    keys(Modules[file].Nodes).forEach(function (nodeLabel) {
      
      var funcname = nodeLabel.substring(1, nodeLabel.length-1);
      var symbolFiles = Symbols[funcname];
      var ksymFiles = Symbols["__ksymtab_"+funcname];

      var isGlobal = (symbolFiles === undefined) ? false : (symbolFiles.symType == "T") ? true : false;
      //console.log("Node: "+JSON.stringify(Modules[file].Nodes[nodeLabel]));
      var node = new Node(Modules[file].Nodes[nodeLabel], nodeLabel, file, Modules[file].Edges, isGlobal, ksymFiles);

      node.CheckIfUnused();

      // If there is a global symbol and lineno for the function
      if (symbolFiles && symbolFiles.lineno) {
        // Add global ksyms
        if (isGlobal && Globals[nodeLabel] === undefined) {
          symbolFiles.lineno.forEach(function (lineno) { 
            if (lineno) {
              var filename = path.normalize(lineno.split(":")[0]);
              var dotfile = filename.substring(0, filename.length)+"_.dot";
                
              // verify the dot file exists
              if (Modules[dotfile] !== undefined) {
                node.AddDotFile(dotfile);
              }
              node.AddLineno(symbolFiles.lineno);
            }
          });
        // Add lineno info to local functions
        } else if (isGlobal) {
          // See if there is a matching lineno for the module
          symbolFiles.lineno.some(function (lineno) { 
            if (lineno) {
              var filename = lineno.split(":")[0];
              var dotfile = filename.substring(0, filename.length)+"_.dot";
              if (file == dotfile) {
                node.AddLineno(lineno);
                return true;
              }
            }
          });
        }
      } 
      node.CheckIfExported();
      if (node.unresolved) 
        Unresolved.push([nodeLabel, file, "External"]);
      //console.log(node);
      node.CheckIfKsyms(Modules);
    });
  }); 

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

