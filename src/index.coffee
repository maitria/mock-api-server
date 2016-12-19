'use strict'

child_process = require 'child_process'
Dsl = require './dsl'
request = require 'sync-request'

class MockApi
  constructor: (@options) ->
    @privateSettings =
      host: '127.0.0.1'

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

  stop: (done) ->
    @_sendCommand 'stop'
    if done
      setTimeout done, 500

  reset: ->
    @_sendCommand 'reset'

  respondTo: (args...) ->
    new Dsl @_addResponseSpecification, args

  _addResponseSpecification: (spec) =>
    request('POST', "http://#{@privateSettings.host}:#{@options.port}/mock-api/add-response", {
      json: spec
    })

  _sendCommand: (name) ->
    request('GET', "http://#{@privateSettings.host}:#{@options.port}/mock-api/#{name}")

module.exports = MockApi
