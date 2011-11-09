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
    @width = 940
    @height = 100
    @start = 1 if not @start
    @end = 100 if not @end
    @numProps = NumberProperty.all().length
    @x = d3.scale.linear().domain([0,@end]).range([0,@width])
    @log "num props = #{@numProps}"
    @colors = d3.scale.linear().domain([0,@numProps]).range([0,1])
    @render()

  render: =>
    $(@el).empty()
    $(@el).append("<div id='topSelector'></div>")
    numCounts = NumberProperty.makeCountList(@start,@end)
    viz = d3.select('#topSelector')
      .append("svg:svg")
      .attr("width", @width)
      .attr("height", @height)
      .attr("class", "rangeSelector")
    viz.selectAll('rect')
      .data(numCounts)
      .enter()
      .append('svg:rect')
      .attr('fill',(d) => d3.hsl(0,0,1-@colors(d.value-1)))
      .attr('x', (d) => @x(d.name-1))
      .attr('y', 0)
      .attr('width', @x(1)+1 )
      .attr('height', @height/2)
    viz.selectAll('text')
      .data([@start,@end])
      .enter()
      .append('svg:text')
      .attr("transform", (d,i) => "translate(#{if i == 0 then 0 else @width},#{@height/2+20})")
      .attr('class','numberbartext')
      .attr('text-anchor',(d,i) => if i == 0 then 'after' else 'end')
      .text(String)
    
module.exports = NumberSelector
    
module.exports = NumberSelector
