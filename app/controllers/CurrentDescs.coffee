Spine = require('spine')
App = require('models/App')
SubSelect = require('models/SubSelect')
NumberProperty = require('models/NumberProperty')

class CurrentDescs extends Spine.Controller
  events:
    "click .numberType": "toggleSelected"

  constructor: ->
    super
    App.bind("update",@render)
    @render()
    
  render: =>
    @html require('views/CurrentDescs')({
      app: App.first()
      subselect: SubSelect.first()
      numbers: NumberProperty.all()
    })

  toggleSelected: (el) =>
    # TODO sometimes I can pick not the child but the parent. figure that out.
    if $(el.target).attr('id')
      npid = $(el.target).attr('id')
    else
      npid = $(el.target).parent().attr('id')
    if SubSelect.first().numProps.length < NumberProperty.all().length
      SubSelect.toggleSelectedNumberProperty(NumberProperty.find(npid))
    else
      SubSelect.setSelectedNumberProperty(NumberProperty.find(npid))
    @render()

module.exports = CurrentDescs
