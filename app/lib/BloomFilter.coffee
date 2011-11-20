SHA1 = require 'sha1'

###
# A bloom filter hash map (http://en.wikipedia.org/wiki/Bloom_filter).
###
class BloomFilter
  constructor: (@capacity=100,@errorRate=.01)->
    bitsPerKey = Math.log(1/@errorRate)*Math.log(Math.E)
    #console.log "error rate #{@errorRate} requires #{bitsPerKey} bits per key. Capacity #{@capacity} then needs: #{bitsPerKey*@capacity} bits"
    @count = 0

    ###
    lowest_m = null
    best_k = 1
    k = 1
    while k <= 100
      m = (-1 * k * @capacity) / ( Math.log( 1 - Math.pow(@errorRate, (1/k)) ))
      if lowest_m == null || (m < lowest_m)
        lowest_m = m
        best_k   = k
      k++
    lowest_m = Math.floor(lowest_m) + 1
    ###

    @filterLength = parseInt(bitsPerKey*@capacity)
    #console.log("filter len = #{@filterLength}")
    @filter = new Array(@filterLength)

  computeHash: (k) ->
    hash=SHA1(k)
    #console.log("message = #{hash} - #{hash.length}")
    intParts = []
    vec = 0
    j=0
    while j < hash.length
      c = parseInt(hash.slice(j, j + 8), 16)
      vec = vec ^ c
      j=j+8
    #console.log "vec = #{vec}"
    return Math.abs(vec % @filterLength)

  add: (k) ->
    # and int has 2^54 = 2^9*6
    # total hash digits 2^4*40 = 2^160
    # So with this hash of 40 digits we and 5 bits per key == 32 keys would maintain 1 percent error
    # How many keys do I think I'll add? Well...there are maybe 30 properties times a billion numbers
    #  k = # keys (1 billion * 30)
    #  bitmap size = 30billion keys * 4.6 bits per key = 121 billion bits = 15 billion bytes = yikes
    #  oh but hold on these keys will only be added if they exist for the number...
    #  and most numbers appear to only have like 3 properties:
    #  k = 1 billion * 3 => 3billion keys * 4.6 bit/key = 15 billion bits / 8 = 2 billion bytes. still yikes
    #  what if it were really only 1 on average?
    #  k = 1 billion * 1 => 1billion keys * 4.6 bit/key = 5 billion bits / 8 = 500 Mbytes. still yikes
    # 8 hex digits = 2^4*8 = 2^32 ... 9 digits = 2^36, 10 digits = 2^40 ...
    # STICK TO THE WIKI PAGE - its got lots of reference papers.
    @count++
    @filter[@computeHash(k)] = true
    return this

  contains: (k) -> return @filter[ @computeHash( k ) ] == true

# TODO implement with bits instead of ints
class BitArray
  constructor: (size) ->
    cnt=0
    @data = (0 while cnt++ < size)
  size: -> @data.length
  set: (position,value) -> @data[position] = value

module.exports = BloomFilter
