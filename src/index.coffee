express = require 'express'
cannedFs = require './canned_fs'
cannedMap = require './canned_map'

class MockApiServer
  constructor: (@options) ->

  start: (done) ->
    @app = express()
    @app.use @_cannedResponses
    cannedFs 'test/mock-api', (err, hash) =>
      @cannedMap = cannedMap hash
      @server = @app.listen @options.port, done

  stop: ->
    @server.close()

  _cannedResponses: (req, res, next) =>
    response = @cannedMap method: req.method, path: req.path
    return next() if response == undefined
    res.send JSON.stringify response

module.exports = (options, cb) ->
  server = new MockApiServer options
  server.start (err) ->
    return unless cb?
    cb err, server
