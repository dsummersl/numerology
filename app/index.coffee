require('lib/setup')

Spine = require('spine')

TApp = require('models/App')
NumberProperty = require('models/NumberProperty')
CurrentNumber = require('controllers/CurrentNumber')
CurrentDescs = require('controllers/CurrentDescs')
NumberSelector = require('controllers/NumberSelector')

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
  events:
    "keydown": "rightOrLeft"

  constructor: ->
    super
    $.getJSON("data/computed.json", @dataloaded)

  dataloaded: (d) =>
    TApp.create(currentNumber: 1)
    for k,v of d.tests
      NumberProperty.create(name: d.tests[k].name,description: d.tests[k].description, test: d.tests[k].test, numbers: d.tests[k].numbers)
    @cn = new CurrentNumber({el: $(@el).find('#currentNumber')})
    @cd = new CurrentDescs({el: $(@el).find('#currentDescs')})
    @ns = new NumberSelector({el: $(@el).find('#numberSelector')})
    @ns = new NumberSelector({el: $(@el).find('#numberSelector2'),start:1,end:1000})
   
  rightOrLeft: (evt) =>
    if (evt.keyCode == 37) # left
      current = TApp.first()
      if (current.currentNumber > 0)
        current.currentNumber--
        current.save()
    if (evt.keyCode == 39) # right
      current = TApp.first()
      current.currentNumber++
      current.save()

module.exports = App
    
