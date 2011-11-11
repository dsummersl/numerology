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
      .attr('transform', "translate(#{0},#{0})")
    bottomG = viz.data([0])
      .append('svg:g')
      .attr('transform', "translate(#{0},#{@height/2})")
    @numCounts = NumberProperty.makeCountList(1,1000)
    @top = new Timeline(@width,@height/2,topG,@numCounts,100,=> [1,100])
    @bottom = new Timeline(@width,@height/2,bottomG,@numCounts,1000,=> [@top.start,@top.end])
    @joinG = viz.data([0]).append('svg:g')
    @pathGen = (d)->
      # http://www.w3.org/TR/SVG/paths.html#PathElement
      yoffset = Math.abs(d.p1[1] - d.p2[1])/2
      return "M#{d.p1[0]},#{d.p1[1]} C#{d.p1[0]},#{d.p1[1]+yoffset} #{d.p2[0]},#{d.p1[1]+yoffset} #{d.p2[0]},#{d.p2[1]}"
    @joinG.selectAll('path')
      .data([{
        p1: [@top.x(0),@top.height/2]
        p2: [@bottom.x(0),@top.height+@bottom.yoffset]
      },{
        p1: [@top.x(@top.selectRange()[1]),@top.height/2]
        p2: [@bottom.x(@top.selectRange()[1]),@top.height+@bottom.yoffset]
      }])
      .enter()
      .append('svg:path')
      .attr('d',@pathGen)
      .attr('stroke','#888')
      .attr('fill','none')
      .attr('width','1.5px')

    ###
    #.attr('x1', (d) => if d==0 then @top.x(0) else @top.x(@top.numToShow))
    #.attr('x2', (d) => if d==0 then @bottom.x(0) else @bottom.x(@top.numToShow))
    #.attr('y1', @top.height/2)
    #.attr('y2', @top.height+@bottom.yoffset)
    ###
    
  updated3: =>
    @top.updated3()
    @bottom.updated3()
    @joinG.selectAll('path')
      .data([{
        p1: [@top.x(0),@top.height/2]
        p2: [@bottom.x(0),@top.height+@bottom.yoffset]
      },{
        p1: [@top.x(@top.selectRange()[1]),@top.height/2]
        p2: [@bottom.x(@top.selectRange()[1]),@top.height+@bottom.yoffset]
      }])
      .transition()
      .duration(1000)
      .attr('d',@pathGen)


class Timeline
  constructor: (@width,@height,@viz,@numCounts,@numToShow,@selectRange) ->
    @numProps = NumberProperty.all().length
    # TODO share this call - don't want to call it twice.
    @x = d3.scale.linear().domain([0,@numToShow]).range([0,@width])
    @colors = d3.scale.linear().domain([0,@numProps]).range([0,1])
    @yoffset = 5
    @doenter(@viz.selectAll('rect').data(@numCounts[@selectRange[0]-1..@selectRange[1]-1], (d) -> d.name ))
    ###
    @viz.selectAll('text')
      .data([@start,@end]) # first number goes to the left, the other goes to the right
      .enter()
      .append('svg:text')
      .attr("transform", (d,i) => "translate(#{if i == 0 then 0 else @width},#{@height/2+20})")
      .attr('class','numberbartext')
      .attr('text-anchor',(d,i) => if i == 0 then 'after' else 'end')
      .text(String)
    ###

  doenter: (rect,xtraval=1) =>
    rect.enter()
      .append('svg:rect')
      .attr('fill',(d) => d3.hsl(0,0,1-@colors(d.value-1)))
      .attr('x', (d) => @x(d.name-xtraval))
      .attr('y', (d) => if d.name == App.num() then 0 else @yoffset)
      .attr('width', @x(1)+0.5)
      .attr('height', (d) => if d.name == App.num() then @height/2 else @height/2 - @yoffset)
      .on('click', (d) => App.set(d.name))

  btwn: (num,range) -> return num >= range[0] and num <= range[1]

  updated3: =>
    rects = @viz.selectAll('rect')
      .data(@numCounts[@selectRange[0]-1..@selectRange[1]-1], (d) -> d.name )
      .transition()
      .duration(400)
      .attr('y', (d) => if d.name == App.num() then 0 else @yoffset)
      .attr('height', (d) => if d.name == App.num() then @height/2 else @height/2 - @yoffset)

  ###
  updated3: (parent) =>
    @viz.selectAll('rect')
      .data(@numCounts)
      .transition()
      .duration(200)
      .attr('y', (d) => if d.name == App.num() then 0 else @yoffset)
      .attr('height', (d) => if d.name == App.num() then @height/2 else @height/2 - @yoffset)
  ###

module.exports = NumberSelector
