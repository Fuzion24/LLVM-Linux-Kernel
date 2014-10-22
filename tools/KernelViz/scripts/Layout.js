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

    if (!isDirected) {
      var key = viewinfo
        .append("div")
        .classed("linkKey", true);
      linkKey(key, self.linkColor);
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

  this.getGraphElement = function () {
    var div = d3.select("div.container");
    return div.select("svg");
  }

  this.clearGraphElement = function() {
    var div = d3.select("div.container");
    div.select("svg").remove();
    div.append("svg");
  }

  this.addModuleSelector = function(files, callback) {
    var selector = document.getElementById("selector");
    selector.innerHTML="";
    moduleSelector = completely(selector, {
        fontFamily:"sans-serif", fontSize:"14px", promptInnerHTML : "Type in a Module or Select From List:&nbsp;"
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
  }

  this.setModuleSelectorText = function(text) {
    moduleSelector.setText(text);
  }

  this.addFunctionSelector = function(callback) {
    var button = document.getElementById("funcbutton");
    var funcname = document.getElementById("funcname");
    var depth = document.getElementById("funcdepth");
    button.onclick=function (d) { 
      callback(funcname.value, depth.value);
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
      d3.select("div.funcselector").style("display", "none");
      View = topDirView;
    } 
    else if (view == "func") {
      View = functionView;
      d3.select("div.labelbutton").style("display", null);
      d3.select("div.viewbuttons").style("display", null);
      d3.select("div.topviewcontrols").style("display", "none");
      d3.select("div.selector").style("display", "none");
      d3.select("div.funcselector").style("display", null);
    }
    else {
      View = moduleView;
      d3.select("div.labelbutton").style("display", null);
      d3.select("div.viewbuttons").style("display", null);
      d3.select("div.topviewcontrols").style("display", "none");
      d3.select("div.selector").style("display", null);
      d3.select("div.funcselector").style("display", "none");
    }

    View.setActive();
    this.resize();
  }

  this.resize = function() {
    var width = window.innerWidth - 290.0;
    var height = 1000;
    d3.select("svg")
      .attr("style", "width:"+ width + "px;height:"+ height + "px;");
    View.resize(width, height);
    var selector = document.getElementById("selector");
    selector.style.width = width+"px";
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

  function linkKey(element, linkColor) {
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
}
