Spine = require 'spine'
NumberProperty = require '../app/models/NumberProperty'

describe 'NumberProperty', ->
  Spine.Model.Local = {}
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

  describe 'makeCountList', ->
    it 'should return the counts/numbers in a range', ->
      list = NumberProperty.makeCountList(1,5)
      expect(list.length).toEqual(5)
      expect(list[0].name).toEqual(1)
      expect(list[0].value).toEqual(2)

  describe 'makeData', ->
    list = NumberProperty.makeCountList(1,20)
    data = NumberProperty.makeData(list,10)

    it 'will default to 1-size and will not move at the ends', ->
      expect(data.center).toEqual(1)
      expect(data.viewport).toEqual([1,10])
      expect(d.name for d in data.dataView()).toEqual([1,2,3,4,5,6,7,8,9,10])
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
      data = NumberProperty.makeData(list,11)
      data.recenter(10)
      expect(data.center).toEqual(10)
      expect(data.viewport).toEqual([5,15])
      expect(d.name for d in data.dataView()).toEqual([5,6,7,8,9,10,11,12,13,14,15])
      data.recenter(18)
      expect(data.viewport).toEqual([10,20])

