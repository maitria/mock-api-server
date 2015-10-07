child_process = require 'child_process'
Dsl = require './dsl'
httpSync = require 'http-sync'

class MockApi
  constructor: (@options) ->

  start: (done) ->
    args = ['--port', @options.port]
    args.push '--no-log-to-console' unless @options.logToConsole
    if @options.testPath
      args.push '--test-path'
      args.push @options.testPath
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
    request = httpSync.request
      method: 'POST'
      headers:
        'Content-Type': 'application/json'
      port: @options.port
      body: JSON.stringify(spec)
      path: '/mock-api/add-response'
    request.end()

  _sendCommand: (name) ->
    request = httpSync.request
      method: 'GET'
      port: @options.port
      path: "/mock-api/#{name}"
    request.end()

module.exports = MockApi
