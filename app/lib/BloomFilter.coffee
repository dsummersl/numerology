SHA1 = require('crypto/sha1').hex_sha1

###
# A bloom filter hash map (http://en.wikipedia.org/wiki/Bloom_filter).
###
class BloomFilter
  constructor: (@capacity=100,@errorRate=.01,@filter=null,@count=0)->
    bitsPerKey = Math.log(1/@errorRate)*Math.log(Math.E)
    filterLength = parseInt(bitsPerKey*@capacity)
    #console.log "error rate #{@errorRate} requires #{bitsPerKey} bits per key. Capacity #{@capacity} then needs: #{bitsPerKey*@capacity} bits"

    if not @filter
      #console.log("filter len = #{filterLength}")
      @filter = new Array(filterLength)

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
    return Math.abs(vec % @filter.length)

  add: (k) ->
    @count++
    @filter[@computeHash(k)] = true
    return this

  contains: (k) -> return @filter[ @computeHash( k ) ] == true

class VerifiableBloomFilter extends BloomFilter
  constructor: (@capacity=100,@errorRate=.01,@filter=null,@count=0,@keys=[])->
    super(@capacity,@errorRate,@filter,@count)

  add: (k) ->
    @keys.push(k)
    super(k)

  # return a list of keys that aren't in the bloom
  verify: -> return for k in @keys when not @contains(k)

  # convert this verifiable bloom into a normal one
  makeBloomFilter: -> new BloomFilter(@capacity,@errorRate,@filter,@count)

# TODO implement with bits instead of ints
class BitArray
  constructor: (size) ->
    cnt=0
    @data = (0 while cnt++ < size)
  size: -> @data.length
  set: (position,value) -> @data[position] = value

module.exports =
  BloomFilter: BloomFilter
  VerifiableBloomFilter: VerifiableBloomFilter
