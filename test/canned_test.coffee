assert = require 'assert'
canned = require '../lib/canned.js'

describe 'canned response map', ->

  data =
    '/v2/foo/bar.json': 'answer1'
    '/v2/foo/baz.json': 'answer2'

  get = (path) ->
    (canned data)
      method: "GET"
      path: path

  it 'finds a simple request in the map', ->
    assert.equal 'answer1', get '/v2/foo/bar.json'

  it 'finds a different simple request in the map', ->
    assert.equal 'answer2', get '/v2/foo/baz.json'

  it 'answers undefined when no request is found', ->
    assert.strictEqual undefined, get '/v2/foo/quux.json'
