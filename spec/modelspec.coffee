Spine = require 'spine'
NumberProperty = require 'models/NumberProperty'

describe 'NumberProperty', ->
  Spine.Model.Local = {}
  np.destroy() for np in NumberProperty.all()
  NumberProperty.create(name: 'Even', description: '', test: "result = n % 2 == 0",numbers: null)
  NumberProperty.create(name: 'Odd', description: '', test: "result = n % 2 != 0",numbers: null)
  NumberProperty.create(name: 'HardCoded', description: '', test: null,numbers: [1,2,3,5,7,11])

  it 'should have all its properties', -> expect(NumberProperty.all().length).toEqual(3)

  describe 'containsNumber', ->
    it 'would detect even numbers', ->
      even = NumberProperty.findByAttribute('name','Even')
      expect(even.containsNumber(1)).toBeFalsy()
      expect(even.containsNumber(2)).toBeTruthy()
      expect(even.containsNumber(4)).toBeTruthy()
    it 'would detect hard coded numbers', ->
      hardcoded = NumberProperty.findByAttribute('name','HardCoded')
      expect(hardcoded.containsNumber(1)).toBeTruthy()
      expect(hardcoded.containsNumber(11)).toBeTruthy()
      expect(hardcoded.containsNumber(8)).toBeFalsy()

  describe 'totalCount', ->
    it 'can count totals for one number', ->
      expect(NumberProperty.totalCount(5)).toEqual(2)
      expect(NumberProperty.totalCount(9)).toEqual(1)
    it 'can compute ranges of numbers', ->
      expect(NumberProperty.totalCount(2,3)).toEqual(4)
      expect(NumberProperty.totalCount(2,5)).toEqual(7)
    it 'should let you send a subset of properties', ->
      expect(NumberProperty.totalCount(5,5,[NumberProperty.first()])).toEqual(0)
      expect(NumberProperty.totalCount(8,8,[NumberProperty.first()])).toEqual(1)
      expect(NumberProperty.totalCount(2,3,[NumberProperty.first()])).toEqual(1)
      expect(NumberProperty.totalCount(2,5,[NumberProperty.first()])).toEqual(2)

  describe 'makeCountList', ->
    it 'should return the counts/numbers in a range', ->
      list = NumberProperty.makeCountList(1,5)
      expect(list.length).toEqual(5)
      expect(list[0].name).toEqual(1)
      expect(list[0].value).toEqual(2)
    it 'should let you send a subset of properties', ->
      list = NumberProperty.makeCountList(1,5,[NumberProperty.first()])
      expect(list.length).toEqual(5)
      expect(list[0].name).toEqual(1)
      expect(list[0].value).toEqual(0)
      expect(list[1].name).toEqual(2)
      expect(list[1].value).toEqual(1)

  describe 'makeDataView', ->
    data = NumberProperty.makeDataView(10,20)

    it 'will default to 1-size and will not move at the ends', ->
      expect(data.center).toEqual(1)
      expect(data.viewport).toEqual([1,10])
      expect(d.name for d in data.dataView()).toEqual( [1,2,3,4,5,6,7,8,9,10])
      expect(d.total for d in data.dataView()).toEqual([2,2,2,1,2,1,2,1,1,1])
      expect(data.dataView()[0].properties).toEqual(['Odd','HardCoded'])
      data.recenter(2)
      expect(data.center).toEqual(2)
      expect(data.viewport).toEqual([1,10])
      data.recenter(5)
      expect(data.center).toEqual(5)
      expect(data.viewport).toEqual([1,10])
      data.recenter(16)
      expect(data.center).toEqual(16)
      expect(data.viewport).toEqual([11,20])
      data.recenter(19)
      expect(data.center).toEqual(19)
      expect(data.viewport).toEqual([11,20])
      expect(d.name for d in data.dataView()).toEqual([11,12,13,14,15,16,17,18,19,20])

    it 'will move the viewport to center if possible', ->
      data.recenter(10)
      expect(data.center).toEqual(10)
      expect(data.viewport).toEqual([5,14])
      expect(d.name for d in data.dataView()).toEqual([5,6,7,8,9,10,11,12,13,14])

    it 'will move correctly if the viewport is odd', ->
      data = NumberProperty.makeDataView(11,20)
      data.recenter(10)
      expect(data.center).toEqual(10)
      expect(data.viewport).toEqual([5,15])
      expect(d.name for d in data.dataView()).toEqual([5,6,7,8,9,10,11,12,13,14,15])
      data.recenter(18)
      expect(data.viewport).toEqual([10,20])

  describe 'breakoutParts', ->
    data = NumberProperty.makeDataView(10,20)
    it 'a number with 2 props', ->
      part = NumberProperty.breakoutParts(data.dataView()[0])
      expect(part.length).toEqual(2)
      expect(part[0]).toEqual({
        name: 1
        count: 1
        offset: 0
        property: 'notaprop'
      })
      expect(part[1]).toEqual({
        name: 1
        count: 2
        offset: 1
        property: 'aprop'
      })
    it 'a number with 1 part', ->
      data.recenter(10)
      part = NumberProperty.breakoutParts(data.dataView()[7])
      expect(part.length).toEqual(2)
      expect(part[0]).toEqual({
        name: 12
        count: 2
        offset: 0
        property: 'notaprop'
      })
      expect(part[1]).toEqual({
        name: 12
        count: 1
        offset: 2
        property: 'aprop'
      })
