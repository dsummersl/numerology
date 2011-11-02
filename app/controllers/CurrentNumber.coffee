Spine = require('spine')

App = require('models/App')

class CurrentNumber extends Spine.Controller
  constructor: ->
    super
    @render()

  render: ->
    @log "rendering #{App.first().currentNumber} for #{@el.attr('id')}"
    @html require('views/CurrentNumber')(App.first())
    
module.exports = CurrentNumber
