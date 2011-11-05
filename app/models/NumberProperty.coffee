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
 
module.exports = NumberProperty
