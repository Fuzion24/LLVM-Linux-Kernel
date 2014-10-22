// -------------------------------------------------------------
//
// Requires: d3
// -------------------------------------------------------------
function InfoView(nodeColor, linkColor) {

  this.displayColorKey = function(isDirected) {
    d3.select("div.labelbutton").style("display", isDirected ? "none" : null);

    var viewinfo = d3.select("div.nodeInfo").html("");
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
      .data(Object.keys(nodeColor)) 
      .enter()
      .append("tr");

    row
      .append("td")
      .attr("width", "100px")
      .text(function (d) { return d; });

    row
      .append("td")
      .attr("width", "50px")
      .attr("style", function (d) { return "background-color:"+nodeColor[d]+";"; } );

    if (!isDirected) {
      var key = viewinfo
        .append("div")
        .classed("linkKey", true);
      linkKey(key, linkColor);
    }

    viewinfo
      .append("div")
      .classed("nodeInfo", true);
  }

  this.displayNodeInfo = function(nodename, lineno, dotfile, ksyms, functype) {
    var nodeinfo = d3.selectAll("div.nodeInfo")
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
      .text(ftype);

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
    d3.selectAll("div.nodeInfo").html("");
  }
}
