// -------------------------------------------------------------
// ModuleView
// -------------------------------------------------------------
function DualGraphView(viewinfoclass) {
  var graphData = null;
  var selectedNode = null;
  var graphTypeIsDirected = true;
  var showingGraph = false;
  var nodeColor = { "External": "#f77", "Global": "#177", "Local": "#fff", "Local Unused": "#771", "Exported": "#717" };

  function clickDGNode(label, obj) {
    if (label == selectedNode) {
      selectedNode = null;
      d3.selectAll("div.nodeInfo").html("");
    } else {
      // Select this node
      selectedNode = label;
      displayNodeInfo(obj);
    }
    _dg.selectedNode = selectedNode;
  }

  function DGNodeAttrFn(label, obj) { 
    var funcType = getFunctionType(label);
    var rect = obj.getElementsByTagName('rect');
    rect[0].style.fill = nodeColor[funcType];
    return funcType;
  }

  var _dg = new DirectedGraph(clickDGNode, "functype", DGNodeAttrFn);
  var _fg = new ForceGraph(false, false);

  // Override ForceGraph Node Click Handler
  _fg.clickNode = function (d, obj, nodes) {
    if (selectedNode == d.index) {
      selectedNode = null;
      d3.selectAll("div.nodeInfo").html("");
    } else {
      selectedNode = d.index;
      displayNodeInfo(obj);
    }
    nodes.classed("node-selected", function (d) { return (d.index == selectedNode); });
    _fg.updateNodeLinks(selectedNode);
  }

  // Override ForceGraph Node Attribute Handler
  _fg.setNodeAttributes = function() {
    var nodes = d3.selectAll("circle.node");

    nodes
      .attr("id",function(d) { return d.name; })
      .attr("functype", function (d) { return getFunctionType(d.name); })
      .attr("style", function (d) { return "fill:"+nodeColor[getFunctionType(d.name)]; })
      .on("click", function(d){ _fg.clickNode(d, this, nodes); });
  }

  function getFunctionType(label) {
    var funcType;
    if (graphData.Nodes[label].isGlobal) {
      if (graphData.Nodes[label].isExternal) {
        funcType = "External";
      } else {
        funcType = "Global";
      }
    } else if (graphData.Nodes[label].isUnused) {
      funcType = "Local Unused";
    } else if (graphData.Nodes[label].isExported) {
      funcType = "Exported";
    } else {
      funcType = "Local";
    }
    return funcType;
  }

  function getModule(module, nodeLabel) {
    xmlhttp = new XMLHttpRequest();
    xmlhttp.open("GET","getmodule?module="+module, true);
    xmlhttp.onreadystatechange=function() {
      if (xmlhttp.readyState==4 && xmlhttp.status==200){
        graphData = JSON.parse(xmlhttp.responseText);
        //graphTypeIsDirected = true;
        createGraph();
      }
    }
    xmlhttp.send();
  }

  this.setGraphType = function(type) {
    selectedNode = null;
    clearGraph();
    graphTypeIsDirected = (type == "directed");
    makeViewInfo();
    d3.select("div.labelbutton").style("display", graphTypeIsDirected ? "none" : null);
    if (showingGraph)
      createGraph();
  }

  this.showLabels = function(show) {
    _fg.showLabels(show);
  }

  this.enableZoom = function(doZoom) {
    _fg.enableZoom(doZoom);
  }

  function createGraph() {
    d3.select("div.labelbutton").style("display", graphTypeIsDirected ? "none" : null);
    svg = d3.selectAll("svg");
    svg.selectAll("g").remove();
    if (graphTypeIsDirected) {
      graph = _dg.createGraph(svg, graphData);
      showingGraph = true;
    } else {
      graph = new Object;
      graph.nodes = [];
      graph.links = [];
      var nodes = Object.keys(graphData.Nodes);

      nodes.forEach(function(n) { 
        graph.nodes.push({"name": n, "group": 1 });
      });
      Object.keys(graphData.Edges).forEach(function(edge) { 
        graph.links.push({ "source": nodes.indexOf(graphData.Edges[edge].n1), 
                           "target": nodes.indexOf(graphData.Edges[edge].n2)}); 
      });
      _fg.refresh(svg, graph, selectedNode);
      showingGraph = true;
    }
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
    if (showingGraph)
      createGraph();

    makeViewInfo();
  }

  this.resize = function(width, height) {
    if (!graphTypeIsDirected)
      height = width;
    //_fg._force.size(width, height);
  }
}

function ModuleView(viewinfoclass) {
  var moduleSelector;

  this.loadModule = function(fname, nodeLabel) {
    _loadModule(fname, nodeLabel);
  }

  function _loadModule(fname, nodeLabel) {
    moduleSelector.setText(fname);
    setTimeout(function() { getModule(fname, nodeLabel); },0);
  }

  function selectNewModule(module) {
    if (files.indexOf(module) >= 0) 
      _loadModule(module, null);
    else {
      if (showingGraph) {
        clearGraph();
        showingGraph=false;
      }
    }
  }

  this.addModuleSelector = function() {
    var selector = document.getElementById("selector");
    moduleSelector = completely(selector, {
        fontFamily:"sans-serif", fontSize:"14px", promptInnerHTML : "Type in a Module or Select From List:&nbsp;"
    });

    moduleSelector.options = files.sort();

    moduleSelector.onChange = function (text) {
      moduleSelector.startFrom = text.indexOf(',')+1;
        if (files.indexOf(text) >= 0) {
          selectNewModule(text);
        }
        moduleSelector.repaint();
    };
    moduleSelector.repaint();
  }
}

function FunctionView(viewinfoclass) {

  this.loadSubGraph = function(func, depth) {
    _loadSubGraph(func, depth);
  }

  function _loadModule(func, depth) {
    functionSelector.setText(func);
    setTimeout(function() { getSubGraph(func, depth); },0);
  }

  function selectNewSubGraph(funcname, 2) {
    if (files.indexOf(module) >= 0) 
      _loadModule(module, null);
    else {
      if (showingGraph) {
        clearGraph();
        showingGraph=false;
      }
    }
  }

  this.addFunctionSelector = function() {
    var selector = document.getElementById("funcselector");
  }
}

ModuleView.prototype = new DualGraphView();
ModuleView.prototype.constructor = ModuleView(viewinforclass);

FunctionView.prototype = new DualGraphView();
FunctionView.prototype.constructor = new FunctionView();
