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
var TopView = new Object;

var index = 0;

function runServer() {
  var http = require("http");
  var fs = require("fs");
  var url = require("url");
  var whitelist = [ "/index.html", "/toplevel.json", 
                    "/TopView.html", "/data/TopViewFG.json",
                    "/tux-with-dragon-wings-90.png"];

  http.createServer(function(request, response){
    var path = url.parse(request.url).pathname;
    console.log("request received "+path);
    if(path == "/getfiles"){
      console.log("files request received");
      var string = JSON.stringify(keys(Modules));
      response.writeHead(200, {"Content-Type": "text/plain"});
      response.end(string);
      console.log("string sent");
    }
    else if(path == "/getmodule"){
      console.log("module request received "+url.parse(request.url).query);
      var file = url.parse(request.url).query.substring("module=".length);
      console.log("file:"+file);
      //console.log(JSON.stringify(Modules[file]));
      var string = JSON.stringify(Modules[file]);
      response.writeHead(200, {"Content-Type": "text/plain"});
      response.end(string);
      console.log("string sent");
    }
    else if(path == "/getmoddeps"){
      console.log("modedeps request received");
      fs.readFile("./data/TopViewDG.json", function(err, file) {  
        if(err) {  
          showError(response, "getmoddeps request failed");
        }  
        response.writeHead(200, { 'Content-Type': 'text/html' });  
        response.end(file, "utf-8");  
      });
      console.log("string sent");
    }
    else if(path == "/favicon.ico"){
      response.writeHead(200, {'Content-Type': 'image/x-icon'} );
      response.end();
      console.log('favicon requested');
    }
    else {
      if (path == "/")
        path = "/index.html";
   
      console.log(whitelist.indexOf(path));
      if (whitelist.indexOf(path) >= 0) {
        fs.readFile('.'+path, function(err, file) {  
          if(err) {  
            showError(response, "Unable to read: "+path);
          } else {  
            response.writeHead(200, { 'Content-Type': 'text/html' });  
            response.end(file, "utf-8");  
          }
        });
      }
      else {
        showError(response, "No such file: "+path);
      }
    }
  }).listen(8001);
  console.log("server initialized");
}

function showError(response, text) {
  var Error = '<!DOCTYPE html> <meta charset="utf-8"> <body> <h1>Error</h1>'
              + "<pre>" + text + "</pre></body>";
  response.writeHead(200, { 'Content-Type': 'text/html' });  
  response.end(Error, "utf-8");  
}

// Reload the parsed data
console.log("Loading data");
if (process.argv.length != 2) {
  console.log("Usage: nodejs SWViz.js");
}
else {
  console.log("Loading cached data");
  fs.readFile("data/ModulesResolved.json", 'utf8', function (err, data) {
    if (err) {
      console.log(""+err);
      process.exit(1);
    }
    Modules = JSON.parse(data);
    runServer();
  });
}

