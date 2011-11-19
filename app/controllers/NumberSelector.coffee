App = require('models/App')
SubSelect = require('models/SubSelect')
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

    # TODO unset this - just for testing:
    SubSelect.setSelectedNumberProperty NumberProperty.findByAttribute('name','Prime')

    @width = 940
    @height = 100
    $(@el).empty()
    $(@el).append("<div id='topSelector'></div>")
    viz = d3.select('#topSelector')
      .append("svg:svg")
      .attr("width", @width)
      .attr("height", @height)
      .attr("class", "rangeSelector")
    @topMargin = 120
    @bottomMargin = 10
    topG = viz.data([0])
      .append('svg:g')
      .attr('transform', "translate(#{@topMargin},#{0})")
    bottomG = viz.data([0])
      .append('svg:g')
      .attr('transform', "translate(#{@bottomMargin},#{@height/2})")
    @top = new Timeline(@width-@topMargin*2,@height/2,topG,NumberProperty.makeDataView(10))
    @bottom = new Timeline(@width-@bottomMargin*2,@height/2,bottomG,NumberProperty.makeDataView(100),true)
    @connector = new TimelineConnector(@top,@bottom,@topMargin,@bottomMargin,viz.data([0]).append('svg:g'))
    App.bind("update",@updated3)
    SubSelect.bind("update",@updatesubselect)

  updatesubselect: => @updated3()
  updated3: => @connector.updated3()

class TimelineConnector# {{{
  constructor: (@top,@bottom,@topMargin,@bottomMargin,@viz) ->
    @pathGen = (d)->
      # http://www.w3.org/TR/SVG/paths.html#PathElement
      yoffset = Math.abs(d.p1[1] - d.p2[1])/3 + 3
      # assume point 1 is above point 2:
      return "M#{d.p1[0]},#{d.p1[1]} C#{d.p1[0]},#{d.p1[1]+yoffset} #{d.p2[0]},#{d.p1[1]-yoffset} #{d.p2[0]},#{d.p2[1]}"
    @joinData = => [{ # left border of top histogram
        p1: [@top.x(0)+@topMargin,0]
        p2: [@top.x(0)+@topMargin,@top.height/2]
      },{ # left connector between histograms
        p1: [@top.x(0)+@topMargin,@top.height/2]
        p2: [@bottom.x(@top.view.viewport[0]-@bottom.view.viewport[0])+@bottomMargin,@top.height+@bottom.yoffset]
      },{ # right connector
        p1: [@top.x(@top.view.size)+@topMargin,@top.height/2]
        p2: [@bottom.x(@top.view.viewport[1]-@bottom.view.viewport[0]+1)+@bottomMargin,@top.height+@bottom.yoffset]
      },{ # right border of top histogram
        p1: [@top.x(@top.view.size)+@topMargin,0]
        p2: [@top.x(@top.view.size)+@topMargin,@top.height/2]
      },{ # left border of bottom histogram
        p1: [@bottom.x(@top.view.viewport[0]-@bottom.view.viewport[0])+@bottomMargin,@top.height+@bottom.yoffset]
        p2: [@bottom.x(@top.view.viewport[0]-@bottom.view.viewport[0])+@bottomMargin,@top.height+@bottom.height/2+@bottom.yoffset]
      },{ # right border of bottom histogram
        p1: [@bottom.x(@top.view.viewport[1]-@bottom.view.viewport[0]+1)+@bottomMargin,@top.height+@bottom.yoffset]
        p2: [@bottom.x(@top.view.viewport[1]-@bottom.view.viewport[0]+1)+@bottomMargin,@top.height+@bottom.height/2+@bottom.yoffset]
      }]
    @viz.selectAll('path')
      .data(@joinData())
      .enter()
      .append('svg:path')
      .attr('d',@pathGen)
      .attr('stroke','#888')
      .attr('fill','none')
      .attr('width','1.5px')

  updated3: =>
    @top.updated3()
    @bottom.updated3()
    @viz.selectAll('path')
      .data(@joinData())
      .transition()
      .duration(400)
      .attr('d',@pathGen)
# }}}
class Timeline# {{{
  constructor: (@width,@height,@viz,@view,@showNumbers=false) ->
    @view.recenter(App.num())
    @numProps = NumberProperty.all().length
    @x = d3.scale.linear().domain([0,@view.size]).range([0,@width])
    @colors = d3.scale.linear().domain([0,@numProps]).range([0,1])
    # number property colors:
    #@npcolors = d3.scale.linear().domain(np.name for np in NumberProperty.all()).range([0,1])
    @yoffset = 5
    @delay = 400
    @doenter(@viz.selectAll('g').data(@view.dataView(), @datafunction))
    if @showNumbers
      @viz.selectAll('text')
        .data(@view.viewport) # first number goes to the left, the other goes to the right
        .enter()
        .append('svg:text')
        .attr("transform", (d,i) => "translate(#{if i == 0 then 0 else @width},#{@height/2+15})")
        .attr('class','numberbartext')
        .attr('text-anchor',(d,i) => if i == 0 then 'after' else 'end')
        .text(String)

  # TODO I have to redraw the entire thing most likely...it would be nice if
  # I could still do the association somehow...  OH....I could do something
  # creative with the keys: make a composite key that is both the number and
  # whether it is 'in' the last selection or not.
  #
  # An index key might be... <thenumber>-<thecategoryname>-<thecountforthecategory>
  datafunction: (d) -> d.name

  doenter: (rect,delta=0) =>
    ss = SubSelect.getNumberProperties()
    heightPerNP = Math.floor((@height/2-@yoffset) / NumberProperty.all().length)
    rect.enter()
      .append('svg:g')
      .selectAll('rect')
      .data((d)=> NumberProperty.breakoutParts(d,ss))
      .enter()
      .append('svg:rect')
      .attr('fill',(d,i) => if d.offset == 0 then d3.hsl(0,0,1) else d3.hsl(0,0,1-@colors(d.count)))
      #.attr('name', (d) => "#{d.name} - #{d.property} - #{d.count} - #{d.offset} - #{heightPerNP}")
      .attr('x', (d) => @x(d.name-@view.viewport[0]+delta))
      .attr('y', (d) => (@yoffset+d.offset*heightPerNP))
      .attr('class', (d) => if d.name == App.num() then 'selectedWedge' else 'unselectedWedge')
      .attr('width', @x(1))
      .attr('height', (d) => heightPerNP*d.count)
      .on('click', (d) => App.set(d.name))

  updated3: =>
    ss = SubSelect.getNumberProperties()
    heightPerNP = Math.floor((@height/2-@yoffset) / NumberProperty.all().length)
    oldstart = @view.viewport[0]
    @view.recenter(App.num())
    delta = Math.abs(@view.viewport[0] - oldstart)
    change = if oldstart < @view.viewport[0] then delta else -delta
    medelay = if change > @view.size then @delay * 2 else @delay

    if @showNumbers
      @viz.selectAll('text')
        .data(@view.viewport)
        .transition()
        .text(String)

    rects = @viz.selectAll('g')
      .data(@view.dataView(),@datafunction)

    rects.selectAll('rect')
      .data((d)=> NumberProperty.breakoutParts(d,ss))
      .transition()
      .duration(medelay)
      .attr('x', (d) => @x(d.name-@view.viewport[0]))
      .attr('y', (d) => (@yoffset+d.offset*heightPerNP))
      .attr('height', (d) => heightPerNP*d.count)
      .attr('class', (d) => if d.name == App.num() then 'selectedWedge' else 'unselectedWedge')

    if change != 0
      rects.exit()
        .selectAll('rect')
        .data((d)=> NumberProperty.breakoutParts(d,ss))
        .transition()
        .duration(medelay)
        .attr('x', (d) => @x(d.name-@view.viewport[0]))
        .style('opacity',.4)
        .transition()
        .delay(medelay)
        .duration(@delay)
        .style('opacity',0)
        .remove()
      rects.exit()
        .transition()
        .duration(medelay*2+@delay)
        .remove()
      @doenter(rects,change)
        .style('opacity',.3)
        .transition()
        .duration(medelay)
        .attr('x', (d) => @x(d.name-@view.viewport[0]))
        .transition()
        .delay(medelay)
        .duration(@delay)
        .style('opacity',1)
# }}}
module.exports = NumberSelector
# vim: set fdm=marker:
