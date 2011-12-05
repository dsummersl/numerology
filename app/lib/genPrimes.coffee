options = require 'lib/genOptions'
Filters = require('bloomfilters')

primeBuilder = (max) ->
  bf = new Filters.ScalableBloomFilter(max/4)
  #console.log "slices = #{bf.filters[0].sliceLen} && #{bf.filters[0].totalSize}"
  nextPrime = (bf,prevPrime,max) ->
    prevPrime += 2
    prevPrime += 2 while not bf.has(prevPrime) and prevPrime < max
    return prevPrime
  bf.add(1)
  bf.add(2)
  bf.add(3)
  console.log "1"
  console.log "2"
  console.log "3"
  potential = 3
  while potential < max
    potential += 2
    sqrt_potential = Math.sqrt(potential)
    isprime = true
    a = 3
    while a < potential
      #console.log "trying #{a}"
      break if a>sqrt_potential
      if potential % a == 0
        isprime = false
        break
      a = nextPrime(bf,a,potential+1)
    console.log "#{potential}" if isprime

primeBuilder(options.max)
