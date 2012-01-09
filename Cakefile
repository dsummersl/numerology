fs = require 'fs'
exec = require('child_process').exec
options = require './app/lib/genOptions'
primeBuilder = require './app/lib/genPrimes'
Filters = require('bloomfilters')

task 'test','Run unit tests', (o) ->
  exec 'NODE_PATH="app" ./node_modules/.bin/jasmine-node --coffee spec', (error,stdout,stderr) ->
    console.log stdout
    console.log stderr
    #console.log error if error != null

task 'nums','Make numbers for data files', (o)->
  exec 'NODE_PATH="app" coffee app/lib/generatesources.coffee > public/data/computed.json', (error,stdout,stderr) ->
    console.log stdout
    console.log stderr
    #console.log error if error != null

task 'primes','Make primes and bloom filters for it', (o)->
  # TODO its you! youwrite stream not being done!
  console.log "generating primes up to #{options.max}..."
  primestxt = fs.createWriteStream('public/data/primes.txt',{ flags: 'w'})
  totalprimes = primeBuilder(options.max,(p)=>
    primestxt.write "#{p}\n"
  )
  primestxt.end()
  primestxt.on 'close', ->
    console.log "making filter (for #{totalprimes} primes)..."
    bf = new Filters.StrictBloomFilter(totalprimes,0.01)
    #bf = new Filters.ScalableBloomFilter(totalprimes)
    cbitset = new Filters.ConciseBitSet()
    abitset = new Filters.ArrayBitSet(options.max / 32 + 1)
    count = 0
    lazy = require("lazy")
    new lazy(fs.createReadStream('public/data/primes.txt'))
       .lines
       .forEach (line) =>
         bf.add(line.toString())
         cbitset.add(parseInt(line))
         abitset.set(parseInt(line))
         count++
       .join((line) =>
         console.log "bit set size = #{cbitset.count} and count is #{count}"
         robf = bf.readOnlyInstance()
         fs.createWriteStream('public/data/primesbloom.json').write(JSON.stringify(bf))
         fs.createWriteStream('public/data/primesbloom2.json').write(JSON.stringify(robf))
         fs.createWriteStream('public/data/primesbitseta.json').write(JSON.stringify(abitset))
         fs.createWriteStream('public/data/primesbitsetc.json').write(JSON.stringify(cbitset))

         console.log "array bit set"
         abitset.printObject()

         console.log "console bit set"
         cbitset.printObject()
       )

task 'verify','Verify what we have', (o)->
  lazy = require("lazy")
  #bf = Filters.StrictBloomFilter.fromJSON(JSON.parse(fs.readFileSync('public/data/primesbloom2.json')))
  #bf = Filters.ArrayBitSet.fromJSON(JSON.parse(fs.readFileSync('public/data/primesbitseta.json')))
  bf = Filters.ConciseBitSet.fromJSON(JSON.parse(fs.readFileSync('public/data/primesbitsetc.json')))
  new lazy(fs.createReadStream('public/data/primes.txt'))
    .lines
    .forEach (line) =>
      v = parseInt(line)
      while lastPrime < v
        lastPrime++
        console.log "BF: Should NOT be in the set: #{lastPrime}" if lastPrime != v && bf.has(lastPrime.toString())
      console.log "BF: Should be IN the set: #{v}" if not bf.has(v.toString())
      lastPrime = v
