Spine = require('spine')
NumberProperty = require('models/NumberProperty')

class App extends Spine.Model
  @configure 'App','currentNumber', 'numProps'
  
  @increment: (n=1) ->
    current = @first()
    current.currentNumber += n
    current.save()

  @decrement: (n=1) ->
    current = @first()
    current.currentNumber -= n
    current.currentNumber = 1 if current.currentNumber < 1
    current.save()

  @set: (n) ->
    current = @first()
    current.currentNumber = n
    current.currentNumber = 1 if current.currentNumber < 1
    current.save()

  @num: -> @first().currentNumber

  @selectAllNumberProperties: ->
    f = @first()
    f.numProps = (n.id for n in NumberProperty.all())
    f.save()

  @setSelectedNumberProperty: (np) ->
    f = @first()
    f.numProps = [np.id]
    f.save()

  @addToSelectedNumberProperty: (np) ->
    f = @first()
    f.numProps.push np.id
    f.save()

module.exports = App
