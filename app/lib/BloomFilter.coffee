SHA1 = require('crypto/sha1').hex_hmac_sha1
MD5 = require('crypto/md5').hex_hmac_md5

###
# A bloom filter hash map (http://en.wikipedia.org/wiki/Bloom_filter).
###
class BloomFilter
  constructor: (@capacity=100,@errorRate=.01,@filter=null,@count=0)->
    bitsPerKey = Math.log(1/@errorRate)*Math.log(Math.E)
    #This says something crazy:
    #@bitsPerInt = Math.log(Number.MAX_VALUE)/Math.log(2)
    #pragmatically testing manually appears to show it to be a 32 bit number Is this true for all platforms?
    @bitsPerInt = 32
    @totalBits = parseInt(bitsPerKey*@capacity/@bitsPerInt)
    #console.log "error rate #{@errorRate} requires #{bitsPerKey} bits per key. Capacity #{@capacity} then needs: #{bitsPerKey*@capacity} bits"
    @hash = new HashGenerator(SHA1)

    if not @filter
      #console.log("filter len = #{totalBits+1}")
      @filter = new Array(@totalBits+1)
      cnt = 0
      @filter[cnt] = 0 while cnt++ < @totalBits+1
      #console.log("filter = #{@filter}")

  computeIndexes: (bit) ->
    targetint = Math.floor(bit / @bitsPerInt)
    targetbit = Math.ceil(bit % @bitsPerInt)
    #console.log "bit = #{bit} and #{@bitsPerInt}"
    #console.log "bit = #{bit}"
    #console.log "targetint = #{targetint}"
    #console.log "targetbit = #{targetbit}"
    return [targetint,targetbit]

  setBit: (k) ->
    parts = @computeIndexes(@hash.getIndex(k,@filter.length*@bitsPerInt))
    mask = 1 << parts[1]-1
    #console.log "setBit #{k} before? #{@bitSet(k)}"
    @filter[parts[0]] = @filter[parts[0]] | mask
    #console.log "setBit #{k} @filter[#{parts[0]}] #{parts[1]} = #{@filter[parts[0]]} | #{mask} == #{@filter[parts[0]]}"
    #console.log "setBit #{k} after? #{@bitSet(k)}"

  bitSet: (k) ->
    parts = @computeIndexes(@hash.getIndex(k,@filter.length*@bitsPerInt))
    mask = 1 << parts[1]-1
    #console.log "bitSet? #{k} @filter[#{parts[0]}] = #{@filter[parts[0]]} & #{mask} = #{(@filter[parts[0]] & mask) != 0} of #{@filter}"
    return (@filter[parts[0]] & mask) != 0

  add: (k) ->
    @count++
    @setBit(k)
    return this

  has: (k) -> @bitSet(k)

class HashGenerator
  constructor: (@hashFunction) ->
  # For a target length 'len', and a key, generate the hash, and then return
  # an index (0-based) sized to 'len'.
  getIndex: (key,len) ->
    hash=@hashFunction(key)
    vec = 0
    console.log("WARNING: watch out, I think this is too big.") if (len > Math.pow(2,16))
    # (2^4)^8
    hexCharsNeeded = parseInt(len / 4)
    c = parseInt(hash.slice(0, 8), 16)
    #console.log "making hash of '#{key}' for target length #{len}: #{hash} -- #{c} (#{hexCharsNeeded})"
    return c % len

###
# The sliced bloom filter optimizes the filter by partitioning the bit array into a segment
# that is reserved for each hash function.
#
# This implementation is derived from 'Scalable Bloom Filters', http://en.wikipedia.org/wiki/Bloom_filter#CITEREFAlmeidaBaqueroPreguicaHutchison2007
###
class SlicedBloomFilter
  constructor: (@capacity=100,@errorRate=.001,@slices=null,@count=0)->
    @bitsPerInt = 32
    # P = p^k = @errorRate
    # n = @capacity
    # p = 1/2
    # M = @limit
    # M = n abs(ln P) / (ln2)^2
    @limit = Math.floor(@capacity * Math.abs(Math.log(@errorRate)) / Math.pow(Math.log(2),2))
    # k = @slices
    # k = log2(1/P)
    @numSlices = Math.ceil(Math.log(1/@errorRate)/Math.log(2))
    cnt = 0
    @allhashes = []
    while cnt++ < @numSlices
      fnc = (cnt,k) -> (k)=>SHA1("h#{cnt}",k)
      @allhashes.push(new HashGenerator(fnc(cnt)))
    #console.log("num slices = #{@numSlices} - #{@limit}")
    # m = M / k
    @sliceLen = Math.ceil(@limit / @numSlices)
    if not @slices
      @slices = []
      for i in [0..@numSlices-1]
        slice = []
        cnt = 0
        while cnt < @sliceLen
          slice.push(0)
          cnt += @bitsPerInt
        @slices.push(slice)
    throw "numSlices doesn't match slices" if @slices.length != @numSlices
    throw "sliceLen doesn't match slice lengths: #{@sliceLen} !< #{@slices[0].length*@bitsPerInt}" if @slices[0].length*@bitsPerInt < @sliceLen


  computeIndexes: (bit) -> [Math.floor(bit / @bitsPerInt), Math.ceil(bit % @bitsPerInt)]

  add: (k) ->
    for i in [0..@numSlices-1]
      parts = @computeIndexes(@allhashes[i].getIndex(k,@sliceLen))
      mask = 1 << parts[1]-1
      #console.log "setBit #{k} before? #{@has(k)}"
      @slices[i][parts[0]] = @slices[i][parts[0]] | mask
      #console.log "setBit #{k} @slices[i][#{parts[0]}] #{parts[1]} = #{@slices[i][parts[0]]} | #{mask} == #{@slices[i][parts[0]]}"
      #console.log "setBit #{k} after? #{@has(k)}"
    @count++
    return this

  has: (k) ->
    allTrue = true
    for i in [0..@numSlices-1]
      parts = @computeIndexes(@allhashes[i].getIndex(k,@sliceLen))
      mask = 1 << parts[1]-1
      allTrue = allTrue && (@slices[i][parts[0]] & mask) != 0
      #console.log "bitSet? #{k} @slices[#{i}][#{parts[0]}] = #{@slices[i][parts[0]]} & #{mask} = #{(@slices[i][parts[0]] & mask) != 0} of #{@slices[i]}"
    return allTrue

###
# Consists of several SlicedBloomFilter's to ensure that the
# filter maintains its % error.
###
class ScalableBloomFilter
  constructor: (@capacity=100,@errorRate=.01,@filter=null,@count=0)->
  add: (k) ->
  has: (k) ->

module.exports =
  BloomFilter: SlicedBloomFilter
  ScalableBloomFilter: ScalableBloomFilter
