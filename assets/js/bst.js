import * as d3 from "d3";

const Canvas= {
  mounted(){
    // this.pushEvent("search_for_closest_value", 7)

    this.handleEvent("current_value", (params) => {
      console.log("CURR VLAUE PARAMS", params)

      params.list.forEach(function(number, i) {
        setTimeout(function(){
          d3.selectAll('circle.node')
              .attr('r', 5)
              .style("fill", function(d){
                  return number === d.data.data ? 'yellow' : 'blue';
              })
        }, i * 1000);
      })
    })
    this.handleEvent("scores", (params) => {
      let tree = JSON.parse(params.tree)
      // console.log("tree:", tree)
      let treeData = tree

      // Set dimensions and margins for diagram
      var margin = {top: 80, bottom: 80},
          width = 600,
          height = 400 - margin.top - margin.bottom;
          
      // append the svg object to the body of the page
      // appends a 'group' element to 'svg'
      // moves the 'group' element to the top left margin   
      var svg = d3.select("#graph_canvas")
          .attr("viewBox","0 0 600 350")
          .append("g")
          .attr("transform", "translate(0," + margin.top + ")");
                      
      var i = 0,      
          duration = 750,
          root;

      // Declares a tree layout and assigns the size
      var treemap = d3.tree().size([width, height]);

      function myXOR(a,b) {
          return ( a || b ) && !( a && b );
      }

      // Assigns parent, children, height, depth
      root = d3.hierarchy(treeData, function(d){
              d.children=[];
              if (d.left){
                  d.children.push(d.left);
                  if (myXOR(d.left, d.right)){
                      d.children.push({data: 'e'});
                  }
              }
              if (d.right){
                  if (myXOR(d.left, d.right)){
                      d.children.push({data: 'e'});
                  }
                  d.children.push(d.right);
              }
              return d.children; 
          });

      root.x0 = width / 2;
      root.y0 = 0;


      update(root);

      // Collapse the node and all it's children
      function collapse(d){
          if(d.children){
              d._children = d.children
              d._children.forEach(collapse)
              d.children = null;
          }
      }

      // Update
      function update(source){
          // Assigns the x and y position for the nodes
          var treeData = treemap(root);
          
          // Compute the new tree layout.
          var nodes = treeData.descendants(),
              links = treeData.descendants().slice(1);
              
          // Normalize for fixed-depth
          nodes.forEach(function(d){ d.y = d.depth*50; });    
          
          // **************** Nodes Section ****************
          
          // Update the nodes...
          var node = svg.selectAll('g.node')
               .data(nodes, function(d) {return d.id || (d.id = ++i); });
               
          // Enter any new nodes at the parent's previous position.
          var nodeEnter = node.enter().append('g')
                           .attr('class', 'node')
                           .attr("transform", function(d){
                               return "translate(" + source.x0 + "," + source.y0 + ")";
                           })
                           .on('click', click);
                           
          // Add Circle for the nodes
          nodeEnter.append('circle')
                      .attr('class', function(d) {
                          if (isNaN(d.data.data)) {
                              return "node hidden";
                          }
                          return 'node';
                      })
                      .attr('r', 1e-6)
                      .style("fill", function(d) {
                          return d._children ? "lightsteelblue" : "#fff";
                      });
          
          // Add labels for the nodes
          nodeEnter.append('text')
              .attr("dy", ".35em")
              .attr("x", function(d){
                  return d.children || d._children ? -13 : 13;
              })
              .attr("text-anchor", function(d){
                  return d.children || d._children ? "end" : "start";
              })
              .text(function(d){ return isNaN(d.data.data) ? '' : d.data.data; });
          
          // Update
          var nodeUpdate = nodeEnter.merge(node);
          
          // Transition to the proper position for the nodes
          nodeUpdate.transition()
              .duration(duration)
              .attr("transform", function(d) {
                  return "translate(" + d.x + "," + d.y + ")";
              });
          
          // Update the node attributes and style
          nodeUpdate.select('circle.node')
              .attr('r', 5)
              .style("fill", function(d){
                  return d._children ? "lightsteelblue" : "#fff";
              })
              .attr('cursor', 'pointer');
              
          // Remove any exiting nodes
          let nodeExit = node.exit().transition()
              .duration(duration)
              .attr("transform", function(d){
                  return "translate(" + source.x +","+ source.y +")";
              })
              .remove();
              
          // On exit reduce the node circles size to 0
          nodeExit.select('circle')
              .attr('r', 1e-6);
          
          // On exit reduce the opacity of text lables  
          nodeExit.select('text')
              .style('fill-opacity', 1e-6)
              
          // **************** Links Section ****************
          
          // Update the links...
          var link = svg.selectAll('path.link')
              .data(links, function(d){ return d.id; });
              
          // Enter any new links at the parent's previous position
          var linkEnter = link.enter().insert('path', "g")
              .attr("class", function(d) {
                  if (isNaN(d.data.data)) {
                      return "link hidden "
                  }
                  return "link";
              })  
          
          // Update
          var linkUpdate = linkEnter.merge(link);
          
          // Transition back to the parent element position
          linkUpdate.transition()
              .duration(duration)
              .attr('d', function(d){ return diagonal(d, d.parent) });
          
          // Remove any existing links
              var linkExit = link.exit().transition()
                  .duration(duration)
                  .attr('d', function(d){
                      var o = {x: source.x, y: source.y};
                  })
                  .remove();
          
          // Store the old positions for transition.
          nodes.forEach(function(d){
              d.x0 = d.x;
              d.y0 = d.y;
          });
          
          // Create a curved (diagonal) path from parent to the child nodes
          function diagonal(s,d){
              let path = `M ${s.x} ${s.y}
              C ${(s.x + d.x) / 2} ${s.y},
                ${(s.x + d.x) / 2} ${d.y},
                ${d.x} ${d.y}`

              return path;
          }

          // Toggle children on click
          function click(d){
              if (d.children){
                  d._children = d.children;
                  d.children = null;
              }
              else{
                  d.children = d._children;
                  d._children = null;
              }
              update(d);
          }
      }
    })
  }
}

export default Canvas