Spine = require('spine')
App = require('models/App')

class NumberProperty extends Spine.Model
  @configure 'NumberProperty','name','description','test','numbers'
  #@belongsTo 'app', App
  
  ###
  # Make a method that checks for the properties defined for a number
  # and return the list of properties
  ###

  containsNumber: (n) ->
    if @numbers and @numbers.length > 0
      return n in @numbers
    else
      eval(@test)
      return result

  # the total number of properties that this #
  # has. In the case of a range, it would give you
  # the total in the range
  @totalCount: (first,last = -1) ->
    if last < first
      last = first
    count = 0
    for el in @all()
      r = first
      while r <= last
        count++ if el.containsNumber(r++)
    return count
 
  # get a list of the number/count and group numbers into bins (in which case things would be averaged).
  # TODO un-implemented grouping
  @makeCountList: (first,last,grouping=1) ->
    n = first
    results = []
    while n <= last
      newval =
        name: n
        value: @totalCount(n)
      results.push(newval)
      n++
    return results

  @makeDataView: (data,size) -> new BoundedRange(data,size)

# A class that stores a list of data, and then gives you a 'view' of it, and provides a center
#
# Attributes:
#  - data: the underlying data.
#  - viewport: a range always equal to size.
#  - center: where the main view is in the middle of the viewport.
class BoundedRange
  # defaults the v
  constructor: (@data,@size) ->
    @viewport = [1,@size]
    @center = 1

  dataView: -> @data[@viewport[0]-1..@viewport[1]-1]

  recenter: (n) ->
    @center = n
    start = 1
    end = @size
    start = n-Math.floor(@size/2) if n > @size/2
    end = n+Math.ceil(@size/2)-1 if n > @size/2
    if end > @data.length
      start = @data.length - @size + 1
      end = @data.length
    @viewport = [start,end]

module.exports = NumberProperty
