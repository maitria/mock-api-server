patternMatcher = require './pattern_matcher'
{each, filter, size, sortBy} = require 'underscore'
url = require 'url'

class Responder
  constructor: (fsHash) ->
    @responseMap = @_buildResponseMap fsHash

  respondTo: (request) ->
    entries = @responseMap[@_stripExtension request.path]
    return undefined if entries == undefined

    allowedEntries = filter entries, (entry) =>
      @_entryAllowedForRequest request, entry
    return undefined if allowedEntries.length == 0

    allowedEntries[0].content

  _stripExtension: (path) ->
    path.replace /\.json$/, ''

  _extractMethod: (filename) ->
    method = filename.split('/')[1]
    path = filename.replace /\/[^\/]*/, ''
    {method,path}

  _buildResponseMap: (fsHash) ->
    responseMap = {}
    each fsHash, (content, filename) =>
      entry = @_buildStaticResponseEntry filename, content
      responseMap[entry.path] ?= []
      responseMap[entry.path].push entry

    each responseMap, (entries, path) ->
      responseMap[path] = sortBy entries, (entry) ->
        1e9 - size entry.query

    responseMap

  _buildStaticResponseEntry: (filename, content) ->
    {pathname, query} = url.parse filename, true
    {method, path} = @_extractMethod @_stripExtension pathname
    {content,method,path,query}

  _entryAllowedForRequest: (request, responseMapEntry) ->
    return false unless request.method == responseMapEntry.method
    matches = true
    each responseMapEntry.query, (value, name) ->
      if !patternMatcher(value) request.query[name]
        matches = false
    matches


module.exports = Responder
