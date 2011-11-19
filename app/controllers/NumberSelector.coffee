App = require('models/App')
SubSelect = require('models/SubSelect')
Spine = require('spine')
NumberProperty = require('models/NumberProperty')
timeline = require('lib/Timeline')
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
    @width = 940
    @height = 100
    $(@el).empty()
    $(@el).append("<div id='topSelector'></div>")
    viz = d3.select('#topSelector')
      .append("svg:svg")
      .attr("width", @width)
      .attr("height", @height)
      .attr("class", "rangeSelector")
    @topMargin = 225
    @bottomMargin = 100
    topG = viz.data([0])
      .append('svg:g')
      .attr('transform', "translate(#{@topMargin},#{0})")
    bottomG = viz.data([0])
      .append('svg:g')
      .attr('transform', "translate(#{@bottomMargin},#{@height/2})")
    @top = new timeline.Timeline(@width-@topMargin*2,@height/2,topG,NumberProperty.makeDataView(41))
    @bottom = new timeline.Timeline(@width-@bottomMargin*2,@height/2,bottomG,NumberProperty.makeDataView(400),true)
    @connector = new timeline.TimelineConnector(@top,@bottom,@topMargin,@bottomMargin,viz.data([0]).append('svg:g'))
    App.bind("update",@updateRanges)
    SubSelect.bind("update",@updateSelects)

  updateSelects: => @connector.updateSelects()
  updateRanges: => @connector.updateRanges()

module.exports = NumberSelector
# vim: set fdm=marker:
