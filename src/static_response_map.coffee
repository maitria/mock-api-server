patternMatcher = require './pattern_matcher'
{each, filter, size, sortBy} = require 'underscore'
url = require 'url'

stripExtension = (path) ->
  path.replace /\.json$/, ''

buildStaticResponseEntry = (filename, content) ->
  {pathname, query} = url.parse filename, true
  path = stripExtension pathname
  {path,query,content}

buildResponseMap = (fsHash) ->
  responseMap = {}
  each fsHash, (content, filename) ->
    entry = buildStaticResponseEntry filename, content
    responseMap[entry.path] ?= []
    responseMap[entry.path].push entry

  each responseMap, (entries, path) ->
    responseMap[path] = sortBy entries, (entry) ->
      1e9 - size entry.query

  responseMap

entryAllowedForRequest = (request, responseMapEntry) ->
  matches = true
  each responseMapEntry.query, (value, name) ->
    if !patternMatcher(value) request.query[name]
      matches = false
  matches

module.exports = (fsHash) ->
  responseMap = buildResponseMap fsHash

  (request) ->
    entries = responseMap[stripExtension request.path]
    return undefined if entries == undefined

    allowedEntries = filter entries, (entry) ->
      entryAllowedForRequest request, entry
    return undefined if allowedEntries.length == 0

    allowedEntries[0].content
