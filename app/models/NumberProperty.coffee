Spine = require('spine')

class NumberProperty extends Spine.Model
  @configure 'NumberProperty','name','description','test','numbers'
  
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
 
module.exports = NumberProperty
