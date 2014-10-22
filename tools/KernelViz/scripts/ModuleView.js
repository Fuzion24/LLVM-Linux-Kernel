// -------------------------------------------------------------
// ModuleView
// -------------------------------------------------------------
function ModuleView(svgclass, viewinfoclass, selectorclass) {
  var moduleData = null;
  var selectedNode = null;
  var graphTypeIsDirected = true;
  var showingGraph = false;
  var nodeColor = { "External": "#f77", "Global": "#177", "Local": "#fff", "Local Unused": "#771", "Exported": "#717" };
  var moduleSelector;

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

  function makeViewInfo() {
    d3.select("div.labelbutton").style("display", graphTypeIsDirected ? "none" : null);

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

    if (!graphTypeIsDirected) {
      var key = viewinfo
        .append("div")
        .classed("linkKey", true);
      linkKey(key, linkColor);
    }

    viewinfo
      .append("div")
      .classed("nodeInfo", true);

  }

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

  function displayNodeInfo(node) {
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

    if (moduleData.Nodes[node.id].lineno) {
      nodeinfo
        .append("h4")
        .text("Defined in:");
      nodeinfo
        .append("p")
        .text(moduleData.Nodes[node.id].lineno);
    }
    if (moduleData.Nodes[node.id].dotfile) {
      var link = "";
      moduleData.Nodes[node.id].dotfile.forEach(function (dotfile) {
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
    if (moduleData.Nodes[node.id].ksyms) {
      nodeinfo
        .append("h4")
        .text("KSymtab defined at:");
      nodeinfo
        .append("p")
        .text(moduleData.Nodes[node.id].ksyms);
    }
  }

  function getFunctionType(label) {
    var funcType;
    if (moduleData.Nodes[label].isGlobal) {
      if (moduleData.Nodes[label].isExternal) {
        funcType = "External";
      } else {
        funcType = "Global";
      }
    } else if (moduleData.Nodes[label].isUnused) {
      funcType = "Local Unused";
    } else if (moduleData.Nodes[label].isExported) {
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
        moduleData = JSON.parse(xmlhttp.responseText);
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
      graph = _dg.createGraph(svg, moduleData);
      showingGraph = true;
    } else {
      graph = new Object;
      graph.nodes = [];
      graph.links = [];
      var nodes = Object.keys(moduleData.Nodes);

      nodes.forEach(function(n) { 
        graph.nodes.push({"name": n, "group": 1 });
      });
      Object.keys(moduleData.Edges).forEach(function(edge) { 
        graph.links.push({ "source": nodes.indexOf(moduleData.Edges[edge].n1), 
                           "target": nodes.indexOf(moduleData.Edges[edge].n2)}); 
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
};


