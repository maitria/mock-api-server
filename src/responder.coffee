'use strict'

patternMatcher = require './pattern_matcher'
{compose, each, extend, filter, identity, map, size, sortBy} = require 'underscore'
url = require 'url'
{keyReplacer} = require './manipulations'

stripExtension = (path) ->
  path.replace /\.json$/, ''

class ResponseSpecification
  constructor: (options) ->
    {@method, @path, @query, @body, @statusCode, @changeNumber, @headers} = options

    @path = stripExtension @path
    @changeNumber ?= 0

    if options.replaceKey?
      @body = keyReplacer options

  matches: (request) ->
    return false unless stripExtension(request.path) == @path
    return false unless request.method == @method
    @_matchesQuery request.query

  with: (params) ->
    new ResponseSpecification(extend {}, this, params)

  _matchesQuery: (query) ->
    matches = true
    each @query, (value, name) ->
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

    bodyTransform = identity
    body = undefined
    statusCode = undefined
    headers = undefined

    each allowedEntries, (entry) ->
      if typeof entry.body == 'function'
        bodyTransform = compose entry.body, bodyTransform
      else if typeof body == 'undefined'
        body = bodyTransform entry.body

      statusCode ?= entry.statusCode
      headers ?= entry.headers

    {statusCode, body, headers}

  withResponseSpecification: (newSpec) ->
    answer = @_freshCopyWith
      specs: @_specsWith newSpec
      serialNumber: @serialNumber + 1
    answer

  _specsWith: (newSpec) ->
    specs = @specs.slice 0
    specs.push newSpec.with(changeNumber: @serialNumber + 1)
    @_sortSpecs specs

  _freshCopyWith: (parameters) ->
    extend new Responder({}), parameters

  _extractMethod: (filename) ->
    method = filename.split('/')[1]
    path = filename.replace /\/[^\/]*/, ''
    {method, path}

  _buildResponseMap: (fsHash) ->
    specs = map fsHash, (response, filename) =>
      @_buildStaticResponseEntry filename, response
    @_sortSpecs specs

  _sortSpecs: (specs) ->
    sortBy specs, (spec) ->
      1e9 - 1000 * (size spec.query) - spec.changeNumber

  _buildStaticResponseEntry: (filename, {body, statusCode, headers}) ->
    {pathname, query} = url.parse filename, true
    {method, path} = @_extractMethod stripExtension pathname
    new ResponseSpecification {body, statusCode, method, path, query, headers}

module.exports = {Responder, ResponseSpecification}
