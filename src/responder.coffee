responseMap = require './response_map'

class Responder
  constructor: (fileHash) ->
    @responseMap = responseMap fileHash

  respond: (request) ->
    @responseMap request

module.exports = Responder
