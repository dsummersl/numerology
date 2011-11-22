Filters = require 'lib/BloomFilter'

describe 'BloomFilter', ->
  bf = new Filters.BloomFilter()

  it 'would have no elements in it with no data', ->
    expect(bf.count).toEqual(0)

  it 'adding one would be good', ->
    bf.add("one")
    expect(bf.count).toEqual(1)
    expect(bf.contains("one")).toBeTruthy()
    expect(bf.contains("two")).toBeFalsy()

  it 'test capacity of 10 - add 10 things', ->
    bf = new Filters.BloomFilter(10)
    cnt=0
    bf.add("k#{cnt++}") while cnt < 10
    cnt=0
    expect(bf.contains("k#{cnt++}")).toBeTruthy() while cnt < 10
    cnt=0
    bf.add("k-#{cnt++}") while cnt < 10
    cnt=0
    expect(bf.contains("k-#{cnt++}")).toBeTruthy() while cnt < 10
    cnt=0
    expect(bf.contains("k#{cnt++}")).toBeTruthy() while cnt < 10
    # TODO test a false positive...

  it 'has a copy constructor', ->
    bf2 = new Filters.BloomFilter(bf.capacity,bf.errorRate,bf.filter,bf.count)
    cnt=0
    expect(bf.contains("k#{cnt++}")).toBeTruthy() while cnt < 10
