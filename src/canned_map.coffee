{each, filter, last, sortBy} = require 'underscore'

stripExtension = (path) ->
  path.replace /\.json$/, ''

parseFilename = (filename) ->
  [dirname] = filename.match /^.*\//
  [basename] = filename.match /[^,/]*$/
  path = dirname + stripExtension basename
  meta = (last filename.split '/').split(',')
  meta.splice(-1, 1)

  query = {}
  each meta, (part) ->
    [name, value] = part.split '='
    query[name] = value

  {path,query}

parseFilenames = (fsHash) ->
  responseMap = {}
  each fsHash, (content, filename) ->
    fsPath = parseFilename filename
    responseMap[fsPath.path] ?= []
    responseMap[fsPath.path].push
      query: fsPath.query
      content: content
  responseMap

entryAllowedForRequest = (request, responseMapEntry) ->
  matches = true
  each responseMapEntry.query, (value, name) ->
    matches = false unless request.query[name] == value
  matches

entryScore = (request, responseMapEntry) ->
  score = 0
  each responseMapEntry.query, (value, name) ->
    score += 1 if request.query[name] == value
  score

module.exports = (fsHash) ->
  responseMap = parseFilenames fsHash

  (request) ->
    entries = responseMap[stripExtension request.path]
    return undefined if entries == undefined

    allowedEntries = filter entries, (entry) ->
      entryAllowedForRequest request, entry
    return undefined if allowedEntries.length == 0

    prioritizedEntries = sortBy allowedEntries, entryScore
    (last prioritizedEntries).content
