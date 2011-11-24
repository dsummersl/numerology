require('lib/setup')

Spine = require('spine')

TApp = require('models/App')
SubSelect = require('models/SubSelect')
NumberProperty = require('models/NumberProperty')
CurrentNumber = require('controllers/CurrentNumber')
CurrentDescs = require('controllers/CurrentDescs')
NumberSelector = require('controllers/NumberSelector')
Filters = require('lib/BloomFilter')

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
    filters = []
    for f in d.bloom.filters
      filters.push(new Filters.StrictBloomFilter(f.capacity,f.errorRate,f.slices,f.count))
    TApp.create(currentNumber: 29,bloom: new Filters.ScalableBloomFilter(d.bloom.startcapacity,d.bloom.errorRate,filters,d.bloom.stages,d.bloom.r,d.bloom.count))
    SubSelect.create()
    for k,v of d.tests
      NumberProperty.create(name: d.tests[k].name,description: d.tests[k].description, test: d.tests[k].test, numbers: d.tests[k].numbers)
    @cn = new CurrentNumber({el: $(@el).find('#currentNumber')})
    @cd = new CurrentDescs({el: $(@el).find('#currentDescs')})
    @ns = new NumberSelector({el: $(@el).find('#numberSelector')})

  rightOrLeft: (evt) =>
    before = TApp.num()
    TApp.decrement() if (evt.keyCode == 37) # left
    TApp.increment() if (evt.keyCode == 39) # right
    TApp.increment(25) if (evt.keyCode == 34) # page down
    TApp.decrement(25) if (evt.keyCode == 33) # page up
    return before == TApp.num()

module.exports = App

