require('lib/setup')

Spine = require('spine')

###
# This app has three interesting parts:
# - the main screen part. It shows the current number and also
#   probably does some resizing based upon the number of digits available.
# - 
###
class App extends Spine.Controller
  constructor: ->
    super

module.exports = App
    
