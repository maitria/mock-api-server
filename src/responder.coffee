patternMatcher = require './pattern_matcher'
{each, extend, filter, map, size, sortBy} = require 'underscore'
url = require 'url'

stripExtension = (path) ->
  path.replace /\.json$/, ''

class ResponseSpecification
  constructor: ({@method, @path, @query, @content, @changeNumber}) ->
    @path = stripExtension @path
    @changeNumber ?= 0

  matches: (request) ->
    return false unless stripExtension(request.path) == @path
    return false unless request.method == @method
    @_matchesQuery request.query

  with: (params) ->
    new ResponseSpecification(extend {}, this, params)

  _matchesQuery: (query) ->
    matches = true
    each @query, (value, name) =>
      if !patternMatcher(value) query[name]
        matches = false
    matches

class Responder
  constructor: (fsHash) ->
    @specs = @_buildResponseMap fsHash
    @serialNumber = 0

  respondTo: (request) ->
    allowedEntries = filter @specs, (entry) ->
      entry.matches request
    return undefined if allowedEntries.length == 0

    allowedEntries[0].content

  withResponseSpecification: (newSpec) ->
    @_freshCopyWith
      specs: @_specsWith newSpec
      serialNumber: @serialNumber + 1

  _specsWith: (newSpec) ->
    specs = @specs.splice 0
    specs.push newSpec.with(changeNumber: @serialNumber + 1)
    @_sortSpecs specs

  _freshCopyWith: (parameters) ->
    extend new Responder({}), parameters

  _extractMethod: (filename) ->
    method = filename.split('/')[1]
    path = filename.replace /\/[^\/]*/, ''
    {method,path}

  _buildResponseMap: (fsHash) ->
    specs = map fsHash, (content, filename) =>
      @_buildStaticResponseEntry filename, content
    @_sortSpecs specs

  _sortSpecs: (specs) ->
    sortBy specs, (spec) ->
      1e9 - 1000 * (size spec.query) - spec.changeNumber

  _buildStaticResponseEntry: (filename, content) ->
    {pathname, query} = url.parse filename, true
    {method, path} = @_extractMethod stripExtension pathname
    new ResponseSpecification {content,method,path,query}

module.exports = {Responder, ResponseSpecification}
