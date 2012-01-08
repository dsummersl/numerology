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
  console.log "generating primes up to #{options.max}..."
  primestxt = fs.createWriteStream('public/data/primes.txt',{ flags: 'w'})
  totalprimes = primeBuilder(options.max,(p)=>
    primestxt.write "#{p}\n"
  )
  primestxt.end()

  console.log "making filter..."
  bf = new Filters.StrictBloomFilter(totalprimes,0.3)
  lazy = require("lazy")
  new lazy(fs.createReadStream('public/data/primes.txt'))
     .lines
     .forEach((line) => bf.add(line.toString()))
     #.join((line) => console.log bf.has("5"))
     .join((line) =>
       console.log "filter size: #{bf.count}"
       console.log "filters : #{bf.slices.length} #{bf.sliceLen}"
       #console.log "#{i} slices: #{f.slices.length} of len #{f.sliceLen}" for f,i in bf.filters
       fs.createWriteStream('public/data/primesbloom.json').write(JSON.stringify(bf))
     )
