Spine = require('spine')

class NumberProperty extends Spine.Model
  @configure 'NumberProperty','name','description','test','numbers'
  
  ###
  # Make a method that checks for the properties defined for a number
  # and return the list of properties
  ###

  containsNumber: (n) ->
    if @numbers.length > 0
      return n in @numbers
    else
      eval(@test)
      return result

  # the total number of properties that this #
  # has. In the case of a range, it would give you
  # the average over a range.
  @totalCount: (first,last = -1) ->
    # TODO implement a range.
    count = 0
    for el in @all
      count++ if el.containsNumber(first)
    return count
 
module.exports = NumberProperty
