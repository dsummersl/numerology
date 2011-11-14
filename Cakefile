fs = require 'fs'
exec = require('child_process').exec

task 'test','Run unit tests', (options) ->
  exec 'NODE_PATH="app" ./node_modules/.bin/jasmine-node --coffee spec', (error,stdout,stderr) ->
    console.log stdout
    console.log stderr
    #console.log error if error != null
