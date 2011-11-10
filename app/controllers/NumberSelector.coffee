App = require('models/App')
Spine = require('spine')
D3 = require('d3/d3')
NumberProperty = require('models/NumberProperty')

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
    @top = new Timeline(1,100,@width,@height/2,topG)
    @bottom = new Timeline(1,1000,@width,@height/2,bottomG)
    
  updated3: =>
    @top.updated3(this)
    @bottom.updated3(this)


class Timeline
  constructor: (@start,@end,@width,@height,@viz) ->
    @numProps = NumberProperty.all().length
    numCounts = NumberProperty.makeCountList(@start,@end)
    @x = d3.scale.linear().domain([0,@end]).range([0,@width])
    @colors = d3.scale.linear().domain([0,@numProps]).range([0,1])
    @viz.data([0]).selectAll('rect')
      .data(numCounts)
      .enter()
      .append('svg:rect')
      .attr('fill',(d) => d3.hsl(0,0,1-@colors(d.value-1)))
      .attr('x', (d) => @x(d.name-1))
      .attr('y', 0)
      .attr('width', @x(1)+1 )
      .attr('height', @height/2)
    @viz.data([0]).selectAll('text')
      .data([@start,@end])
      .enter()
      .append('svg:text')
      .attr("transform", (d,i) => "translate(#{if i == 0 then 0 else @width},#{@height/2+20})")
      .attr('class','numberbartext')
      .attr('text-anchor',(d,i) => if i == 0 then 'after' else 'end')
      .text(String)

  updated3: (parent) =>
    parent.log 'updating d3'

module.exports = NumberSelector
    
module.exports = NumberSelector
