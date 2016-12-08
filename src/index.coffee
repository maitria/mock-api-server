'use strict'

child_process = require 'child_process'
Dsl = require './dsl'
request = require 'sync-request'

class MockApi
  constructor: (@options) ->

  start: (done) ->
    args = ['--port', @options.port]
    args.push '--no-log-to-console' unless @options.logToConsole
    if @options.logToFile
      args.push '--log-to-file'
      args.push @options.logToFile

    child_process.spawn "#{__dirname}/../bin/mock-api-server", args
    setTimeout done, 500

  stop: ->
    @_sendCommand 'stop'

  reset: ->
    @_sendCommand 'reset'

  respondTo: (args...) ->
    new Dsl @_addResponseSpecification, args

  _addResponseSpecification: (spec) =>
    request('POST', "http://127.0.0.1:#{@options.port}/mock-api/add-response", {
      json: spec
    })

  _sendCommand: (name) ->
    request('POST', "http://127.0.0.1:#{@options.port}/mock-api/#{name}")

module.exports = MockApi
