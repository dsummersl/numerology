Spine = require('spine')

App = require('models/App')

class CurrentNumber extends Spine.Controller
  events:
    "click #previousNumber": "backOne"
    "click #nextNumber": "forwardOne"

  constructor: ->
    super
    App.bind("update",@render)
    @render()

  render: => @html require('views/CurrentNumber')(App.first())
  backOne: (evt) => App.decrement()
  forwardOne: (evt) => App.increment()
    
module.exports = CurrentNumber
