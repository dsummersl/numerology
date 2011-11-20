Spine = require('spine')
App = require('models/App')
SubSelect = require('models/SubSelect')
NumberProperty = require('models/NumberProperty')
require('d3/d3')

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

  updateSelects: =>
    @top.updateSelects()
    @bottom.updateSelects()

  updateRanges: =>
    @top.updateRanges()
    @bottom.updateRanges()
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
    @yoffset = 5
    @delay = 400
    @oldSS = SubSelect.getNumberProperties()
    @oldDV = @view.dataView()
    @doenter(@viz.selectAll('g').data(@oldDV, @datafunction))
    if @showNumbers
      @viz.selectAll('text')
        .data(@view.viewport) # first number goes to the left, the other goes to the right
        .enter()
        .append('svg:text')
        .attr("transform", (d,i) => "translate(#{if i == 0 then 0 else @width},#{@height/2+15})")
        .attr('class','numberbartext')
        .attr('text-anchor',(d,i) => if i == 0 then 'after' else 'end')
        .text(String)

  datafunction: (d) -> d.name

  makeFill: (d) ->
    lum = 1
    lum = .98-@colors(d.count) if d.property != 'notaprop'
    sat = 0
    hue = 60
    numContains = SubSelect.numberOfContains(d.name)
    if numContains > 0 && numContains == SubSelect.first().numProps.length
      numContains = 2
      lum = (lum - .04*numContains) if d.offset == 0
      sat = .09*numContains
      hue = 240
    return d3.hsl(hue,sat,lum)

  doenter: (rect,delta=0) =>
    # assuming that 1 has the most properties:
    rect.enter()
      .append('svg:g')
      .selectAll('rect')
      .data((d)=> NumberProperty.breakoutParts(d,@oldSS))
      .enter()
      .append('svg:rect')
      .attr('fill',(d,i) => @makeFill(d))
      .attr('x', (d) => @x(d.name-@view.viewport[0]+delta))
      .attr('y', (d) => (@yoffset+d.offset))
      .attr('class', (d) => if d.name == App.num() then 'selectedWedge' else 'unselectedWedge')
      .attr('width', @x(1))
      .attr('height', (d) => d.count)
      .on('click', (d) => App.set(d.name))

  updateSelects: =>
    # make a number range that just corresponds to the selected numbers
    # then do a transition on their color only
    toUpdate = []
    for i in @oldDV
      toUpdate.push(i) if SubSelect.containsNumber(i.name,(s.id for s in @oldSS)) or SubSelect.containsNumber(i.name)
    #console.log "after looking things over I need to update #{toUpdate.length}: #{p.name for p in toUpdate}"
    @oldSS = SubSelect.getNumberProperties()
    rects = @viz.selectAll('g')
      .data(toUpdate,@datafunction)
    rects.selectAll('rect')
      .data((d)=> NumberProperty.breakoutParts(d,@oldSS))
      .transition()
      .duration(@delay)
      .attr('fill',(d) => @makeFill(d))

  updateRanges: =>
    oldstart = @view.viewport[0]
    @view.recenter(App.num())
    @oldDV = @view.dataView()
    delta = Math.abs(@view.viewport[0] - oldstart)
    change = if oldstart < @view.viewport[0] then delta else -delta
    medelay = if change > @view.size then @delay * 2 else @delay

    if @showNumbers
      @viz.selectAll('text')
        .data(@view.viewport)
        .transition()
        .text(String)

    rects = @viz.selectAll('g')
      .data(@oldDV,@datafunction)

    rects.selectAll('rect')
      .data((d)=> NumberProperty.breakoutParts(d,@oldSS))
      .transition()
      .duration(medelay)
      .attr('x', (d) => @x(d.name-@view.viewport[0]))
      .attr('y', (d) => (@yoffset+d.offset))
      .attr('height', (d) => d.count)
      .attr('class', (d) => if d.name == App.num() then 'selectedWedge' else 'unselectedWedge')

    if change != 0
      rects.exit()
        .selectAll('rect')
        .data((d)=> NumberProperty.breakoutParts(d,@oldSS))
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

module.exports =
  Timeline: Timeline
  TimelineConnector: TimelineConnector
