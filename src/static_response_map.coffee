{each, filter, keys, last, size, sortBy} = require 'underscore'

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

matchesPattern = (pattern, value) ->
  return false unless pattern

  # Compile a simple NFA matcher
  states = []

  FAIL = 0
  START = 1

  states[FAIL] = '%': FAIL

  currentState = START
  sawWildcard = false

  each pattern, (char) ->
    states[currentState] ?= '%': FAIL
    if char == '%'
      states[currentState]['%'] = currentState
    else
      states[currentState][char] = currentState + 1
      currentState += 1
      sawWildcard = false

  states[currentState] ?= '%': FAIL
  SUCCESS = currentState

  # Run it
  currentStates = {}
  currentStates[START] = true

  each value, (char) ->
    nextStates = {}
    each (keys currentStates), (state) ->
      nextStates[states[state]['%']] = true
      if states[state][char]?
        nextStates[states[state][char]] = true
    currentStates = nextStates

  currentStates[SUCCESS]?

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
