express = require 'express'
loadJsonFiles = require './load_json_files'
staticResponseMap = require './static_response_map'
lumber = require 'clumber'

{pick} = require 'underscore'

class MockApiServer
  constructor: (@options) ->
    @logger = @initLogger()

  start: (done) ->
    @logger.info '[STARTING-SERVER]'

    @app = express()
    @app.use @_cannedResponses
    loadJsonFiles 'test/mock-api', (err, hash) =>
      @staticResponseMap = staticResponseMap hash
      @server = @app.listen @options.port, done
  
  stop: ->
    @logger.info '[STOPPING-SERVER]'
    @server.close()

  initLogger:  =>
    transports = []
    transports.push new lumber.transports.Console
    transports.push new lumber.transports.File
      filename: 'full.log'
      level: 'silly'
    new lumber.Logger(transports: transports)
 
  _cannedResponses: (req, res, next) =>
    request = pick req, 'method', 'path', 'query'
    response = @staticResponseMap(request)

    @logger.info '[MOCK-RESPONSE]', response
    return next() if response == undefined
    res.header 'Content-Type', 'application/json'
    res.send JSON.stringify response
  
module.exports = (options, cb) ->
  server = new MockApiServer options
  server.start (err) ->
    return unless cb?
    cb err, server
