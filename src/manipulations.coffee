'use strict'

{each} = require 'underscore'

parseKeyPath = (path) ->

  upToIndex = (string, character) ->
    index = string.indexOf character
    if index == -1
      string.length
    else
      index

  parseKeySegment = (path) ->
    if path[0] == '['
      endOffset = restOffset = path.indexOf ']', 1
      restOffset += 1 if path[restOffset + 1] == '.'
      [ path.substring(restOffset + 1), path.substring(1, endOffset) ]
    else if path.length > 0
      dot = upToIndex path, '.'
      bracket = upToIndex path, '['
      if dot < bracket
        [ path.substring(dot + 1), path.substring(0, dot) ]
      else
        [ path.substring(bracket), path.substring(0, bracket) ]
    else
      null

  keySegments = []
  while result = parseKeySegment path
    [path, keySegment] = result
    keySegments.push keySegment

  keySegments

keyReplacer = (options) ->
  (content) ->
    keyPath = parseKeyPath options.replaceKey
    p = content
    while keyPath.length > 1
      p = p[keyPath.shift()]
    p[keyPath[0]] = options.replaceValue
    content

module.exports = {keyReplacer}
