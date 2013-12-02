assert = require 'assert'
patternMatcher = require '../lib/pattern_matcher.js'

describe 'pattern matcher', ->

  it 'matches identical strings', ->
    matcher = patternMatcher 'hello, world'
    assert matcher 'hello, world'

