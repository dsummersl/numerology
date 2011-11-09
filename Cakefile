fs = require 'fs'
colors = require 'colors'
exec = require('child_process').exec

task 'test','Run unit tests', (options) ->
  console.log "Testing...".bold.underline
  console.log ""
  exec './node_modules/.bin/jasmine-node --coffee spec', (error,stdout,stderr) ->
    console.log stdout
    console.log stderr
    #console.log error if error != null
