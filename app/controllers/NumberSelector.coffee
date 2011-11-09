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
    @height = 50
    @numProps = NumberProperty.all().length
    @upper =
      start: 1
      end: 100
    @x = d3.scale.linear().domain([0,@upper.end]).range([0,@width])
    @log "num props = #{@numProps}"
    @colors = d3.scale.linear().domain([@numProps,0]).range([1,0])
    @render()

  render: =>
    $(@el).empty()
    $(@el).append("<div id='topSelector'></div>")
    numCounts = NumberProperty.makeCountList(@upper.start,@upper.end)
    viz = d3.select('#topSelector')
      .append("svg:svg")
      .attr("width", @width)
      .attr("height", @height)
      .attr("class", "rangeSelector")
   
   #.attr('class',function(d) { return d.foodCat +" "+ d.cluster})
    
    viz.selectAll('rect')
      .data(numCounts)
      .enter()
      .append('svg:rect')
      .attr('fill',(d) => d3.hsl(0,0,@colors(d.value)))
      .attr('x', (d) => @x(d.name-1))
      .attr('y', 0)
      .attr('width', @x(1)+1 )
      .attr('height', @height)
    
module.exports = NumberSelector
