Dsl = require './dsl'

class MockApiServer
  constructor: (@options) ->

  start: (done) ->
    #
 
  stop: ->
    #

  reset: ->
    #

  respondTo: (args...) ->
    new Dsl @_addResponseSpecification, args

  _addResponseSpecification: (spec) =>
    #

module.exports = (options, cb) ->
  server = new MockApiServer options
  server.start (err) ->
    return unless cb?
    cb err, server
