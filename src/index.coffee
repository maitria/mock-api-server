express = require 'express'
cannedFs = require './canned_fs'
staticResponseMap = require './static_response_map'
{pick} = require 'underscore'

class MockApiServer
  constructor: (@options) ->

  start: (done) ->
    @app = express()
    @app.use @_cannedResponses
    cannedFs 'test/mock-api', (err, hash) =>
      @staticResponseMap = staticResponseMap hash
      @server = @app.listen @options.port, done

  stop: ->
    @server.close()

  _cannedResponses: (req, res, next) =>
    response = @staticResponseMap(pick req, 'method', 'path', 'query')
    return next() if response == undefined
    res.send JSON.stringify response

module.exports = (options, cb) ->
  server = new MockApiServer options
  server.start (err) ->
    return unless cb?
    cb err, server
