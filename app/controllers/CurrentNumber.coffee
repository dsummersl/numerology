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

  render: =>
    @log "rendering #{App.first().currentNumber} for #{@el.attr('id')}"
    @html require('views/CurrentNumber')(App.first())

  backOne: (evt) =>
    @log "back one"
    current = App.first()
    current.currentNumber--
    current.save()

  forwardOne: (evt) =>
    @log "for one"
    current = App.first()
    current.currentNumber++
    current.save()

    
module.exports = CurrentNumber
