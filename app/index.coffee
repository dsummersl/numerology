require('lib/setup')

Spine = require('spine')

NumberProperty = require('models/NumberProperty')
#BloomFilter = require('bloomjs')

###
# This app has three interesting parts:
# - the main screen part. It shows the current number and also
#   probably does some resizing based upon the number of digits available.
# - the right hand screen part - this part shows all the property types and the
#   ones that the current number applies to
# - the bottom navigator: it lets you pick/filter the numbers. Would have a pause play option.

###
class App extends Spine.Controller
  constructor: ->
    super
    $.getJSON("data/computed.json", @dataloaded)
    #NumberProperty.create(name: 'Zeisel',description: 'A number that falls into the pattern Px = aPx-1 + b.', source: '')

  dataloaded: (d) ->
    #console.log("loaded my data: "+d)
    #$(@el).append("<br>#{k}") for k,v on d.tests
    console.log "found = "+ $(@el).find('#currentNumber')
    $(@el).find('#currentNumber').append("<ul><li>One</li></ul>")

module.exports = App
    
