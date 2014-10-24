// -------------------------------------------------------------
// Layout
// Requires: d3
// -------------------------------------------------------------
var View = null;
var layout = new Layout;

function Layout() {

  window.addEventListener('resize', this.resize);
  var moduleSelector;
  var functionView;
  var moduleView;
  var topDirView;

  this.nodeColor = { "External": "#f77", "Global": "#177", "Local": "#fff", "Local Unused": "#771", "Exported": "#717" };
  this.linkColor = { "Call Out": "#d62728", "Call In": "#2ca02c" };

  this.init = function() {
    functionView = new FunctionView(this);
    moduleView = new ModuleView(this);
    topDirView = new TopDirView(this);
  }

  this.updateLayout = function() {
    var self = this;
    var isDirected = (View.isDirected === undefined) ? false : View.isDirected();
    d3.select("div.labelbutton").style("display", isDirected ? "none" : null);
    var viewinfo = d3.select("div.viewInfo").html("");

    createNodeKey(this, viewinfo);

    if (!isDirected) {
      var key = viewinfo
        .append("div")
        .classed("linkKey", true);
      createLinkKey(key, self.linkColor);
    }

    viewinfo
      .append("div")
      .classed("nodeInfo", true);
  }

  this.displayNodeInfo = function(nodename, lineno, dotfile, ksyms, functype) {
    var nodeinfo = d3.select("div.nodeInfo")
      .html("<h3>Node Information</h3>");
      
      nodeinfo
      .append("h4")
      .text("Selected function:");

      nodeinfo
      .append("p")
      .text(nodename);

      nodeinfo
      .append("h4")
      .text("Function type:");

      nodeinfo
      .append("p")
      .text(functype);

    if (lineno) {
      nodeinfo
        .append("h4")
        .text("Defined in:");
      nodeinfo
        .append("p")
        .text(lineno);
    }
    if (dotfile) {
      var link = "";
      dotfile.forEach(function (dotfile) {
        link += "<a href='' onclick='moduleView.loadModule(\""+dotfile+"\", \""
             +nodename+"\");return false;'>"+dotfile+"</a><section/>";
      });
      nodeinfo
        .append("h4")
        .text("Link:");
      nodeinfo
        .append("p")
        .html(link);
    }
    if (ksyms) {
      nodeinfo
        .append("h4")
        .text("KSymtab defined at:");
      nodeinfo
        .append("p")
        .text(ksyms);
    }
  }

  this.clearNodeInfo = function () {
    d3.select("div.nodeInfo").html("");
  }

  this.getD3SvgGraphElement = function () {
    var div = d3.select("div.container");
    return div.select("svg");
  }

  this.clearGraphElement = function() {
    var div = d3.select("div.container");
    div.select("svg").remove();
    div.append("svg");
  }

  this.addModuleSelector = function(files, callback) {
    d3.select("div.selectortxt")
    .append("div")
    .style("border", "1px solid #999")
    .each(function () {
      moduleSelector = completely(this, {
          fontFamily:"sans-serif", fontSize:"14px"
      });

      moduleSelector.options = files.sort();

      moduleSelector.onChange = function (text) {
        moduleSelector.startFrom = text.indexOf(',')+1;
        if (files.indexOf(text) >= 0) {
          callback(text);
        }
        moduleSelector.repaint();
      };
      moduleSelector.repaint();
    });
  }

  this.setModuleSelectorText = function(text) {
    moduleSelector.setText(text);
  }

  this.createFunctionSelector = function(callback) {
    var depth = document.getElementById("funcdepth");
    var textbox = d3.select(".fsearch");
    this.funcCallback = callback;
    
    var searchtext = document.getElementById("funcsearchtext");
    searchtext.oninput = function () { 
      callback(searchtext.value, depth.value); 
    };
  }

  this.updateFunctionList = function(options) {
    var self = this;
    var functext = document.getElementById("funcname");
    var funcfile = document.getElementById("funcfile");
    var selector = d3.select(".fselector");
    if (options == null || options.length == 0) {
      selector.html("");
    }
    else {
      selector.html("");
      selector
        .append("select")
        .attr("size", options.length > 10 ? 10 : options.length)
        .selectAll("option")
        .data(options)
        .enter()
        .append("option")
        .on("click", function (d) {
          var depth = document.getElementById("funcdepth");
          var name = d.split("@");
          functext.innerHTML = name[0];
          funcfile.innerHTML = (name.length == 2) ? name[1] : "";
          self.funcCallback(d, depth.value);
          selector.html("");
        })
        .text(function (d) { 
          return d; 
        });
    }
  }

  this.getGraphSize = function(width, height) {
    width = window.innerWidth - 290.0;
    height = 1000;
  }

  this.setView = function(view) {
    if (view == "toplevel") {
      d3.select("div.labelbutton").style("display", null);
      d3.select("div.viewbuttons").style("display", "none");
      d3.select("div.topviewcontrols").style("display", null);
      d3.select("div.selector").style("display", "none");
      d3.selectAll("div.funcoption").style("display", "none");
      View = topDirView;
    } 
    else if (view == "func") {
      View = functionView;
      d3.select("div.labelbutton").style("display", null);
      d3.select("div.viewbuttons").style("display", null);
      d3.select("div.topviewcontrols").style("display", "none");
      d3.select("div.selector").style("display", "none");
      d3.selectAll("div.funcoption").style("display", null);
    }
    else {
      View = moduleView;
      d3.select("div.labelbutton").style("display", null);
      d3.select("div.viewbuttons").style("display", null);
      d3.select("div.topviewcontrols").style("display", "none");
      d3.select("div.selector").style("display", null);
      d3.selectAll("div.funcoption").style("display", "none");
    }

    View.setActive();
    this.resize();
  }

  this.resize = function() {
    var width = window.innerWidth - 290.0;
    var height = 1000;
    d3.select("div.container svg")
      .attr("style", "width:"+ width + "px;height:"+ height + "px;");
    View.resize(width, height);
  };

  this.setGraphType = function(graphtype) {
    View.setGraphType(graphtype);
  }

  this.showLabels = function(show) {
    View.showLabels(show);
  }

  this.showLinks = function(show) {
    topDirView.showLinks(show);
  }

  function createLinkKey(element, linkColor) {
    var table = element
      .append("table");

    var tablehead = table.append("tr");
    var tablebody = table.append("tbody");

    tablehead
      .append("th")
      .text("Link Type");

    tablehead
      .append("th")
      .text("Color");

    row = tablebody
      .selectAll("tr")
      .data(Object.keys(linkColor)) 
      .enter()
      .append("tr");

    row
      .append("td")
      .attr("width", "100px")
      .text(function (d) { return d; });

    row
      .append("td")
      .attr("width", "50px")
      .attr("style", function (d) { return "background-color:"+linkColor[d]+";"; } );
  }

  function createNodeKey(self, viewinfo) {
    if (View != topDirView) {
      var table = viewinfo
        .append("div")
        .attr("class", "key")
        .append("table");

      var tablehead = table.append("tr");
      var tablebody = table.append("tbody");

      tablehead
        .append("th")
        .text("Function Type");

      tablehead
        .append("th")
        .text("Color");

      row = tablebody
        .selectAll("tr")
        .data(Object.keys(self.nodeColor)) 
        .enter()
        .append("tr");

      row
        .append("td")
        .attr("width", "100px")
        .text(function (d) { return d; });

      row
        .append("td")
        .attr("width", "50px")
        .attr("style", function (d) { return "background-color:"+self.nodeColor[d]+";"; } );
    }
  }

  this.enableZoom = function(doZoom) {
    if (View.enableZoom !== undefined)
      View.enableZoom(doZoom);
  }
}
