Spine = require('spine')

App = require('models/App')
NumberProperty = require('models/NumberProperty')

List = require('spine/lib/list')

class CurrentDescs extends Spine.Controller
  constructor: ->
    super
    @list = new List
      el: @el
      template: require('views/description')
    @render()
    
  render: ->
    @log "paint properties"
    @list.render(NumberProperty.all())

module.exports = CurrentDescs
