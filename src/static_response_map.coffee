{each, filter, keys, last, size, sortBy} = require 'underscore'
matchesPattern = require './matches_pattern'

stripExtension = (path) ->
  path.replace /\.json$/, ''

extractQueryFromFilename = (filename) ->
  meta = (last filename.split '/').split(',')
  meta.splice(-1, 1)

  query = {}
  each meta, (part) ->
    [name, value] = part.split '='
    query[name] = value
  query

buildStaticResponseEntry = (filename, content) ->
  [dirname] = filename.match /^.*\//
  [basename] = filename.match /[^,/]*$/

  path = dirname + stripExtension basename
  query = extractQueryFromFilename filename

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
    if !matchesPattern value, request.query[name]
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
