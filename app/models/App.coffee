Spine = require('spine')
NumberProperty = require('models/NumberProperty')

class App extends Spine.Model
  @configure 'App','currentNumber'
  #@hasMany 'numberProperties', NumberProperty
  
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

module.exports = App
