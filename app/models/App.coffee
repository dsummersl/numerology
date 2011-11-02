Spine = require('spine')

class App extends Spine.Model
  @configure 'App','currentNumber'
  
module.exports = App
