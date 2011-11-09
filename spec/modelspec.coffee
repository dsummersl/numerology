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
