// -------------------------------------------------------------
// TopDirView
// -------------------------------------------------------------
function TopDirView(svgclass, viewinfoclass) {
  var selectedNode = null;

  var _fg = new ForceGraph(true, true);

  // Override ForceGraph Node Click Handler
  _fg.clickNode = function (d, obj, nodes) {
    if (selectedNode == d.index) {
      selectedNode = null;
      d3.selectAll("div.nodeInfo").html("");
    } else {
      selectedNode = d.index;
    }
    nodes.classed("node-selected", function (d) { return (d.index == selectedNode); });
    _fg.updateNodeLinks(selectedNode);
  }

  function makeViewInfo() {
    var viewinfo = d3.select(viewinfoclass).html("");
    var key = viewinfo
      .append("div")
      .attr("class", "key");

    linkKey(key, linkColor);
  }

  this.resize = function(width, height) {
      height = width;
    //topdirForce.size(width, height);
  }

  function createGraph() {
    svg = d3.selectAll("svg");
    svg.selectAll("g").remove();
    xmlhttp = new XMLHttpRequest();
    xmlhttp.open("GET","data/TopViewFG.json", true);
    xmlhttp.onreadystatechange=function() {
      if (xmlhttp.readyState==4 && xmlhttp.status==200){
        graph = JSON.parse(xmlhttp.responseText);
        _fg.refresh(svg, graph, selectedNode);
      }
    }
    xmlhttp.send();
  }

  function clearGraph() {
    // Remove existing svg 
    // Can be used to get rid of zoom
    var div = d3.select("div.container");
    div.selectAll("svg").remove();
    div.append("svg");
    resize();
    graph = null;
  }

  this.setActive = function() {
    clearGraph();
    createGraph();
    makeViewInfo();
  }

  this.showLabels = function(show) {
    _fg.showLabels(show);
  }

  this.showLinks = function(show) {
    _fg.showLinks(show);
  }

  this.enableZoom = function(doZoom) {
    _fg.enableZoom(doZoom);
  }
}


