express = require 'express'

class MockApiServer
  constructor: (@options) ->

  start: (cb) ->
    @app = express()
    @server = @app.listen @options.port, cb

  stop: ->
    @server.close()

module.exports = (options, cb) ->
  server = new MockApiServer options
  server.start (err) ->
    return unless cb?
    cb err, server
