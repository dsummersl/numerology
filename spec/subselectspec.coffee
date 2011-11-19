Spine = require 'spine'
NumberProperty = require 'models/NumberProperty'
SubSelect = require 'models/SubSelect'

describe 'SubSelect', ->
  Spine.Model.Local = {}
  a.destroy() for a in SubSelect.all()
  np.destroy() for np in NumberProperty.all()
  SubSelect.create()
  NumberProperty.create(name: 'Even', description: '', test: "result = n % 2 == 0",numbers: null)
  NumberProperty.create(name: 'Odd', description: '', test: "result = n % 2 != 0",numbers: null)
  NumberProperty.create(name: 'HardCoded', description: '', test: null,numbers: [1,2,3,5,7,11])

  it 'has one property', -> expect(SubSelect.all().length).toEqual(1)

  describe 'selectAllNumberProperties', ->
    SubSelect.selectAllNumberProperties()
    expect(SubSelect.first().numProps.length).toEqual(3)
    SubSelect.setSelectedNumberProperty(NumberProperty.first())
    expect(SubSelect.first().numProps.length).toEqual(1)
    SubSelect.setSelectedNumberProperty(NumberProperty.all()[1])
    expect(SubSelect.first().numProps.length).toEqual(1)
    SubSelect.toggleSelectedNumberProperty(NumberProperty.first())
    expect(SubSelect.first().numProps.length).toEqual(2)
    SubSelect.toggleSelectedNumberProperty(NumberProperty.first())
    expect(SubSelect.first().numProps.length).toEqual(1)

  describe 'containsProp', ->
    SubSelect.selectAllNumberProperties()
    expect(SubSelect.first().containsProp(NumberProperty.first())).toBeTruthy()
    SubSelect.setSelectedNumberProperty(NumberProperty.first())
    expect(SubSelect.first().containsProp(NumberProperty.first())).toBeTruthy()
    expect(SubSelect.first().containsProp(NumberProperty.all()[1])).toBeFalsy()

  describe 'getNumberProperties', ->
    expect(el.id).toBeDefined() for el in SubSelect.getNumberProperties()

  describe 'containsNumber', ->
    it 'would return false if nothing is selected', ->
      SubSelect.selectNoNumberProperties()
      expect(SubSelect.containsNumber(1)).toBeFalsy()
      SubSelect.setSelectedNumberProperty(NumberProperty.first())
      expect(SubSelect.containsNumber(1)).toBeFalsy()
      expect(SubSelect.containsNumber(2)).toBeTruthy()
