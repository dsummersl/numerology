Spine = require 'spine'
NumberProperty = require 'models/NumberProperty'
App = require 'models/App'

describe 'App', ->
  Spine.Model.Local = {}
  a.destroy() for a in App.all()
  np.destroy() for np in NumberProperty.all()
  App.create(currentNumber:5,numProps:[])
  NumberProperty.create(name: 'Even', description: '', test: "result = n % 2 == 0",numbers: null)
  NumberProperty.create(name: 'Odd', description: '', test: "result = n % 2 != 0",numbers: null)
  NumberProperty.create(name: 'HardCoded', description: '', test: null,numbers: [1,2,3,5,7,11])

  it 'has one property', -> expect(App.all().length).toEqual(1)

  describe 'selectAllNumberProperties', ->
    App.selectAllNumberProperties()
    expect(App.first().numProps.length).toEqual(3)
    App.setSelectedNumberProperty(NumberProperty.first().id)
    expect(App.first().numProps.length).toEqual(1)
    App.setSelectedNumberProperty(NumberProperty.all()[1].id)
    expect(App.first().numProps.length).toEqual(1)
    App.addToSelectedNumberProperty(NumberProperty.first().id)
    expect(App.first().numProps.length).toEqual(2)
