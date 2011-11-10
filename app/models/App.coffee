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
    current.save()

  @set: (n) ->
    current = @first()
    current.currentNumber = n
    current.save()

module.exports = App
