{each} = require 'underscore'

stripExtension = (path) ->
  path.replace /\.json$/, ''

stripFsExtensions = (fsHash) ->
  data = {}
  each fsHash, (value, key) ->
    data[stripExtension key] = value
  data

module.exports = (fsHash) ->
  data = stripFsExtensions fsHash

  (request) ->
    data[stripExtension request.path]
