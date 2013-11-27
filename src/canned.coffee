
module.exports = (data) ->
  (request) ->
    data[request.path]
