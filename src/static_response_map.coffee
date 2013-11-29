{each, filter, last, size, sortBy} = require 'underscore'

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

parseFilename = (filename) ->
  [dirname] = filename.match /^.*\//
  [basename] = filename.match /[^,/]*$/

  path = dirname + stripExtension basename
  query = extractQueryFromFilename filename

  {path,query}

buildResponseMap = (fsHash) ->
  responseMap = {}
  each fsHash, (content, filename) ->
    fsPath = parseFilename filename
    responseMap[fsPath.path] ?= []
    responseMap[fsPath.path].push
      query: fsPath.query
      content: content

  each responseMap, (entries, path) ->
    responseMap[path] = sortBy entries, (entry) ->
      1e9 - size entry.query

  responseMap

entryAllowedForRequest = (request, responseMapEntry) ->
  matches = true
  each responseMapEntry.query, (value, name) ->
    matches = false unless request.query[name] == value
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
