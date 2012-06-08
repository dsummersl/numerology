Spine = require('spine')
Util = require('lib/util')
App = require('models/App')
BloomFilters = require('bloomfilters')
#ConciseBitSet: ConciseBitSet
#ArrayBitSet: ArrayBitSet

###
# Represents a type of property that a number can have. It'll tell you if the number has that property, what
# numbers do, etc.
###
class NumberProperty extends Spine.Model
	###
	#
	# 'name' - name of the property set
	# 'description' - html description of the property for print.
	# 'test' - if this exists, a simple test to ferret out numbers that belong to the set.
	# 'numbers' - if its not easy to compute, a list of numbers.
	# TODO convert 'numbers' to a BitSet - and all properties will have a 'test'
	###
  @configure 'NumberProperty','name','description','test','numbers'
  
  ###
  # Make a method that checks for the properties defined for a number
  # and return the list of properties
  ###
  containsNumber: (n) ->
    if App.first().bloom
      #console.log "#{@name}-#{n} = #{App.first().bloom.has("#{@name}-#{n}")}"
      return App.first().bloom.has("#{@name}-#{n}")

    if @numbers and @numbers.length > 0
      return n in @numbers
    else
      eval(@test)
      return result

  # the total number of properties that this #
  # has. In the case of a range, it would give you
  # the total in the range
  @totalCount: (first,last = -1,nps=@all()) ->
    if last < first
      last = first
    count = 0
    for el in nps
      r = first
      while r <= last
        count++ if el.containsNumber(r++)
    return count

  # get a list of the number/count and group numbers into bins (in which case things would be averaged).
  # TODO un-implemented grouping
  @makeCountList: (first,last,nps=@all()) ->
    n = first
    results = []
    while n <= last
      newval =
        name: n
        value: @totalCount(n,n,nps)
      results.push(newval)
      n++
    return results

  # make a view that is 'size' points wide, and looks over a total data of length 'len'.
  @makeDataView: (size,len) -> new BoundedRange(size,len)

  # provide a dictionary of a numer, and its total number of properties, and what they are.
  @makeTotalView: (n,nps=@all()) ->
    result = {}
    result.name = n
    result.total=0
    result.properties=[]
    for np in nps
      if np.containsNumber(n)
        result.total++
        result.properties.push(np.name)
    return result

  # takes a dictionary that would have come from the makeDataView.dataView array (and makeTotalView):
  @breakoutParts: (d) ->
    count = 0
    count++ for ss in NumberProperty.all() when ss.containsNumber(d.name)

    # count = count of this bucket
    # offset = bucket number
    results = []
    count = if count*2 > NumberProperty.all().length then NumberProperty.all().length else count*2
    results.push({name:d.name, count:NumberProperty.all().length-count, offset: 0, property:'notaprop'})
    results.push({name:d.name, count:count, offset: results[0].count, property:'aprop'})
    return results


# A class that stores a list of data, and then gives you a 'view' of it, and provides a center
#
# Attributes:
#  - data: the underlying data.
#  - viewport: a range always equal to size.
#  - size: the size of the viewport.
#  - length: the max length that can be displayed at all (end of the sidewalk)
#  - center: where the main view is in the middle of the viewport.
class BoundedRange
  constructor: (@size,@length) ->
    @viewport = [1,@size]
    @center = 1

  # return a list of views, each list is the count for each individual property
  # keys:
  #   name: the number
  #   total: total count
  #   properties: list of the NumberProperty name fields that are applicable to this number
  dataView: -> NumberProperty.makeTotalView(el) for el in Util.range(@viewport[0],@viewport[1])

  recenter: (n) ->
    @center = n
    start = 1
    end = @size
    start = n-Math.floor(@size/2) if n > @size/2
    end = n+Math.ceil(@size/2)-1 if n > @size/2
    if end > @length
      start = @length - @size + 1
      end = @length
    @viewport = [start,end]


module.exports = NumberProperty
