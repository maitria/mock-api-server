ResponseMap = require './response_map'

class Responder
  constructor: (fileHash) ->
    @responseMap = new ResponseMap fileHash

  respond: (request) ->
    @responseMap.respondTo request

module.exports = Responder
