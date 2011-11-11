Spine = require('spine')

class App extends Spine.Model
  @configure 'App','currentNumber'
  
  @increment: ->
    current = @first()
    current.currentNumber++
    current.save()

  @decrement: ->
    current = @first()
    current.currentNumber--
    current.currentNumber = 1 if current.currentNumber < 1
    current.save()

  @set: (n) ->
    current = @first()
    current.currentNumber = n
    current.currentNumber = 1 if current.currentNumber < 1
    current.save()

  @num: -> @first().currentNumber

module.exports = App
