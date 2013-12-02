assert = require 'assert'
patternMatcher = require '../lib/pattern_matcher.js'

describe 'pattern matcher', ->

  it 'matches identical strings', ->
    matcher = patternMatcher 'hello, world'
    assert matcher 'hello, world'

  it 'says different strings without wildcards do not match', ->
    matcher = patternMatcher 'hello, world'
    assert !matcher 'goodbye, world'

  it 'handles wildcards in the middle of the pattern', ->
    matcher = patternMatcher 'hello%world'
    assert matcher 'hello, -- world'
