NumberProperty = require '../app/models/NumberProperty'

describe 'NumberProperty', ->
  it 'can count totals for one number', ->
    expect(NumberProperty.totalCount(5)).toEqual(4)
