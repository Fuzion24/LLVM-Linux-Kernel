function InfoView(viewinfoclass, nodeColor, linkColor) {

  this.makeViewInfo = function(isDirected) {
    d3.select("div.labelbutton").style("display", isDirected ? "none" : null);

    var viewinfo = d3.select(viewinfoclass).html("");
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

  this.displayNodeInfo = function(node, graphData) {
    var ftype = node.getAttribute("functype");

    var nodeinfo = d3.selectAll("div.nodeInfo")
      .html("<h3>Node Information</h3>");
      
      nodeinfo
      .append("h4")
      .text("Selected function:");

      nodeinfo
      .append("p")
      .text(node.id);

      nodeinfo
      .append("h4")
      .text("Function type:");

      nodeinfo
      .append("p")
      .text(ftype);

    if (graphData.Nodes[node.id].lineno) {
      nodeinfo
        .append("h4")
        .text("Defined in:");
      nodeinfo
        .append("p")
        .text(graphData.Nodes[node.id].lineno);
    }
    if (graphData.Nodes[node.id].dotfile) {
      var link = "";
      graphData.Nodes[node.id].dotfile.forEach(function (dotfile) {
        link += "<a href='' onclick='moduleView.loadModule(\""+dotfile+"\", \""
             +node.id+"\");return false;'>"+dotfile+"</a><section/>";
      });
      nodeinfo
        .append("h4")
        .text("Link:");
      nodeinfo
        .append("p")
        .html(link);
    }
    if (graphData.Nodes[node.id].ksyms) {
      nodeinfo
        .append("h4")
        .text("KSymtab defined at:");
      nodeinfo
        .append("p")
        .text(graphData.Nodes[node.id].ksyms);
    }
  }
}
