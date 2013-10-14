
root = exports ? this

Plot = () ->
  # colors = {"me":"#8D040C","bap":"#322209","pres":"#3D605C","cat":"#2E050B","con":"#4B6655","epi":"#C84914","lut":"#C6581B","chr":"#87090D","oth":"#300809"}
  colors = {"me":"url(#lines_red)","bap":"#322209","pres":"#3D605C","cat":"#2E050B","con":"url(#lines_blue)","epi":"#C84914","lut":"#C6581B","chr":"#87090D","oth":"#300809"}
  width = 800
  height = 900
  bigSize = 400
  littleSize = 200
  data = []
  points = null
  margin = {top: 20, right: 20, bottom: 20, left: 20}
  xScale = d3.scale.linear().domain([0,10]).range([0,width])
  yScale = d3.scale.linear().domain([0,10]).range([0,height])
  xValue = (d) -> parseFloat(d.x)
  yValue = (d) -> parseFloat(d.y)
  treeScale = d3.scale.linear().domain([0,100]).range([0,bigSize])
  treemap = d3.layout.treemap()
    .sort((a,b) -> b.index - a.index)
    .children((d) -> d.churches)
    .value((d) -> d.percent)
    .mode('slice')

  processData = (rawData) ->
    rawData.forEach (treemap) ->
      # this is to keep them in order
      # cause i'm too lazy to use stack
      treemap.churches.forEach (c,i) ->
        c.index = i
    rawData

  chart = (selection) ->
    selection.each (rawData) ->

      data = processData(rawData)
      console.log(data)

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")

      defs = svg.append("defs")
      hatch1 = defs.append("pattern")
        .attr("id", "lines_red")
        .attr("patternUnits", "userSpaceOnUse")
        .attr("patternTransform", "rotate(#{-220})")
        .attr("x", 0)
        .attr("y", 2)
        .attr("width", 5)
        .attr("height", 3)
        .append("g")
      hatch1.append("rect")
        .attr("fill", "white")
        .attr("width", 5)
        .attr("height", 3)
      hatch1.append("path")
        .attr("d", "M0 0 H 5")
        .style("fill", "none")
        .style("stroke", "red")
        .style("stroke-width", 3.6)
      hatch2 = defs.append("pattern")
        .attr("id", "lines_blue")
        .attr("patternUnits", "userSpaceOnUse")
        .attr("patternTransform", "rotate(#{-220})")
        .attr("x", 0)
        .attr("y", 2)
        .attr("width", 5)
        .attr("height", 3)
        .append("g")
      hatch2.append("rect")
        .attr("fill", "white")
        .attr("width", 5)
        .attr("height", 3)
      hatch2.append("path")
        .attr("d", "M0 0 H 5")
        .style("fill", "none")
        .style("stroke", "#4B6655")
        .style("stroke-width", 3.6)

      diag = defs.append("pattern")
        .attr("id", "diag-pattern")
        .attr("patternUnits", "userSpaceOnUse")
        .attr("x", 0)
        .attr("y", 3)
        .attr("width", 5)
        .attr("height", 5)
      diag.append("path")
        .attr("d", "M0 0 l5 5")
        .style("fill", "none")
        .style("stroke", "blue")
        .style("stroke-width", 1)
      
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      points = g.append("g").attr("id", "vis_points")
      update()

  update = () ->

    treemap.size([bigSize, bigSize])
    tree = points.selectAll('.tree')
      .data(data).enter().append("g")
      .attr("class","tree")
    tree.append("rect")
      .attr("width", bigSize)
      .attr("height", bigSize)
      .attr("x", 0)
      .attr('y', 0)
      .attr('fill', '#524235')

    treeG = tree.append("g")
      .attr "transform", (d) ->
        scale = d.known / 100.0
        trans = (bigSize - (bigSize * scale)) / 2
        console.log(trans)
        "translate(#{trans},#{trans})scale(#{scale})"

    treeG.selectAll(".slice")
      .data((d) -> treemap(d)).enter()
      .append("rect")
      .attr('class', (d) -> "slice #{d.name}")
      .attr("x", (d) -> d.x)
      .attr("y", (d) -> d.y)
      .attr("width", (d) -> Math.max(0, d.dx))
      .attr("height", (d) -> Math.max(0, d.dy))
      .attr("fill", (d) -> colors[d.name])

  chart.height = (_) ->
    if !arguments.length
      return height
    height = _
    chart

  chart.width = (_) ->
    if !arguments.length
      return width
    width = _
    chart

  chart.margin = (_) ->
    if !arguments.length
      return margin
    margin = _
    chart

  chart.x = (_) ->
    if !arguments.length
      return xValue
    xValue = _
    chart

  chart.y = (_) ->
    if !arguments.length
      return yValue
    yValue = _
    chart

  return chart

root.Plot = Plot

root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)


$ ->

  plot = Plot()
  display = (error, data) ->
    console.log(error)
    plotData("#vis", data, plot)

  queue()
    .defer(d3.json, "data/treemap.json")
    .await(display)

