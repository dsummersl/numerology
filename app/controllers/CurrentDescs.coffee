Spine = require('spine')

App = require('models/App')
NumberProperty = require('models/NumberProperty')

class CurrentDescs extends Spine.Controller
  constructor: ->
    super
    App.bind("update",@render)
    @render()
    
  render: =>
    @html require('views/CurrentDescs')({
      app: App.first()
      numbers: NumberProperty.all()
    })

module.exports = CurrentDescs
