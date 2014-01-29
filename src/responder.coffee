patternMatcher = require './pattern_matcher'
{each, extend, filter, map, size, sortBy} = require 'underscore'
url = require 'url'

stripExtension = (path) ->
  path.replace /\.json$/, ''

class ResponseSpecification
  constructor: ({@method, @path, @query, @content}) ->
    @path = stripExtension @path

  matches: (request) ->
    return false unless stripExtension(request.path) == @path
    return false unless request.method == @method
    @_matchesQuery request.query

  _matchesQuery: (query) ->
    matches = true
    each @query, (value, name) =>
      if !patternMatcher(value) query[name]
        matches = false
    matches

class Responder
  constructor: (fsHash) ->
    @responseList = @_buildResponseMap fsHash

  respondTo: (request) ->
    allowedEntries = filter @responseList, (entry) ->
      entry.matches request
    return undefined if allowedEntries.length == 0

    allowedEntries[0].content

  withResponseSpecification: (newSpec) ->
    modifiedResponder = new Responder({})
    modifiedResponder.responseList = @responseList.splice 0
    modifiedResponder.responseList.push newSpec
    modifiedResponder

  _extractMethod: (filename) ->
    method = filename.split('/')[1]
    path = filename.replace /\/[^\/]*/, ''
    {method,path}

  _buildResponseMap: (fsHash) ->
    responseList = map fsHash, (content, filename) =>
      @_buildStaticResponseEntry filename, content

    responseList = sortBy responseList, (entry) ->
      1e9 - size entry.query

    responseList

  _buildStaticResponseEntry: (filename, content) ->
    {pathname, query} = url.parse filename, true
    {method, path} = @_extractMethod stripExtension pathname
    new ResponseSpecification {content,method,path,query}

module.exports = {Responder, ResponseSpecification}
