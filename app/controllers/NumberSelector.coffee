App = require('models/App')
Spine = require('spine')
NumberProperty = require('models/NumberProperty')
require('d3/d3')

###
two horizontal histograms:
- zoomed in: a 500 number block that makes it easy to select a specific number and see the current number in context.
- zoomed out: a 1-10billion (or whatever) with a logarithmic scale.
   - TODO why logarithmic? Well, we kinda operate intuitively that way. I'm dealing with a huge # of #s.
     in a way this gives a macro level view of the numbers - vastly over simplified.
   - cons: its not intuitive to a lay persion I'd say. Its perhaps overly simplifying especially at high high values.
###
class NumberSelector extends Spine.Controller
  constructor: ->
    super
    App.bind("update",@updated3)
    @width = 940
    @height = 100
    $(@el).empty()
    $(@el).append("<div id='topSelector'></div>")
    viz = d3.select('#topSelector')
      .append("svg:svg")
      .attr("width", @width)
      .attr("height", @height)
      .attr("class", "rangeSelector")
    topG = viz.data([0])
      .append('svg:g')
      .attr('transform', "translate(#{100},#{0})")
    bottomG = viz.data([0])
      .append('svg:g')
      .attr('transform', "translate(#{0},#{@height/2})")
    @numCounts = NumberProperty.makeCountList(1,10000)
    @top = new Timeline(@width-200,@height/2,topG,@numCounts,NumberProperty.makeDataView(@numCounts,100))
    @bottom = new Timeline(@width,@height/2,bottomG,@numCounts,NumberProperty.makeDataView(@numCounts,600))
    @joinG = viz.data([0]).append('svg:g')
    @pathGen = (d)->
      # http://www.w3.org/TR/SVG/paths.html#PathElement
      yoffset = Math.abs(d.p1[1] - d.p2[1])/2
      return "M#{d.p1[0]},#{d.p1[1]} C#{d.p1[0]},#{d.p1[1]+yoffset} #{d.p2[0]},#{d.p1[1]+yoffset} #{d.p2[0]},#{d.p2[1]}"
    @joinData = => [{
        p1: [@top.x(0)+100,@top.height/2]
        p2: [@bottom.x(@top.view.viewport[0]-1-@bottom.view.viewport[0]),@top.height+@bottom.yoffset]
      },{
        p1: [@top.x(@top.view.size)+100,@top.height/2]
        p2: [@bottom.x(@top.view.viewport[1]-@bottom.view.viewport[0]),@top.height+@bottom.yoffset]
      }]
    @joinG.selectAll('path')
      .data(@joinData())
      .enter()
      .append('svg:path')
      .attr('d',@pathGen)
      .attr('stroke','#888')
      .attr('fill','none')
      .attr('width','1.5px')

    ###
    #.attr('x1', (d) => if d==0 then @top.x(0) else @top.x(@top.view.size))
    #.attr('x2', (d) => if d==0 then @bottom.x(0) else @bottom.x(@top.view.size))
    #.attr('y1', @top.height/2)
    #.attr('y2', @top.height+@bottom.yoffset)
    ###
    
  updated3: =>
    @top.updated3()
    @bottom.updated3()
    @joinG.selectAll('path')
      .data(@joinData())
      .transition()
      .duration(400)
      .attr('d',@pathGen)


class Timeline
  constructor: (@width,@height,@viz,@numCounts,@view) ->
    @numProps = NumberProperty.all().length
    @x = d3.scale.linear().domain([0,@view.size]).range([0,@width])
    @colors = d3.scale.linear().domain([0,@numProps]).range([0,1])
    @yoffset = 5
    @delay = 400
    @doenter(@viz.selectAll('rect').data(@view.dataView(), (d) -> d.name ))
    @viz.selectAll('text')
      .data(@view.viewport) # first number goes to the left, the other goes to the right
      .enter()
      .append('svg:text')
      .attr("transform", (d,i) => "translate(#{if i == 0 then 0 else @width},#{@height/2+15})")
      .attr('class','numberbartext')
      .attr('text-anchor',(d,i) => if i == 0 then 'after' else 'end')
      .text(String)

  doenter: (rect,delta=0) =>
    rect.enter()
      .append('svg:rect')
      .attr('fill',(d) => d3.hsl(0,0,1-@colors(d.value-1)))
      .attr('x', (d) => @x(d.name-@view.viewport[0]+delta))
      .attr('y', (d) => if d.name == App.num() then 0 else @yoffset)
      .attr('width', @x(1)+0.5)
      .attr('height', (d) => if d.name == App.num() then @height/2 else @height/2 - @yoffset)
      .on('click', (d) => App.set(d.name))

  updated3: =>
    oldstart = @view.viewport[0]
    @view.recenter(App.num())
    delta = Math.abs(@view.viewport[0] - oldstart)
    change = if oldstart < @view.viewport[0] then delta else -delta
    medelay = if change > @view.size then @delay * 3 else @delay

    @viz.selectAll('text')
      .data(@view.viewport) # first number goes to the left, the other goes to the right
      .transition()
      .text(String)

    rects = @viz.selectAll('rect')
      .data(@view.dataView(), (d) -> d.name )

    rects.transition()
      .duration(medelay)
      .attr('x', (d) => @x(d.name-@view.viewport[0]))
      .attr('y', (d) => if d.name == App.num() then 0 else @yoffset)
      .attr('height', (d) => if d.name == App.num() then @height/2 else @height/2 - @yoffset)

    if change != 0
      rects.exit()
        .transition()
        .duration(medelay)
        .attr('x', (d) => @x(d.name-@view.viewport[0]))
        .style('opacity',.4)
        .transition()
        .delay(medelay)
        .duration(@delay)
        .style('opacity',0)
        .remove()

      @doenter(rects,change)
        .style('opacity',.1)
        .transition()
        .duration(medelay)
        .attr('x', (d) => @x(d.name-@view.viewport[0]))
        .transition()
        .delay(medelay)
        .duration(@delay)
        .style('opacity',1)

module.exports = NumberSelector
