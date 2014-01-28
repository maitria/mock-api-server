staticResponseMap = require './static_response_map'

class Responder
  constructor: (fileHash) ->
    @staticResponseMap = staticResponseMap fileHash

  respond: (request) ->
    @staticResponseMap request

module.exports = Responder
