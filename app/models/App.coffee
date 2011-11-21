Spine = require('spine')

class App extends Spine.Model
  @configure 'App','currentNumber','bloom'

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
