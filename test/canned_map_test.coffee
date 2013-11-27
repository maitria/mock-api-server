assert = require 'assert'
cannedMap = require '../lib/canned_map.js'

describe 'canned response map', ->

  data =
    '/v2/foo/bar.json': 'answer1'
    '/v2/foo/p=76,bar.json': 'answer3'
    '/v2/foo/baz.json': 'answer2'

  get = (path, query) ->
    (cannedMap data)
      method: "GET"
      query: query || {}
      path: path

  it 'finds a simple request in the map', ->
    assert.equal 'answer1', get '/v2/foo/bar.json'

  it 'finds a different simple request in the map', ->
    assert.equal 'answer2', get '/v2/foo/baz.json'

  it 'answers undefined when no request is found', ->
    assert.strictEqual undefined, get '/v2/foo/quux.json'

  it 'finds a request without an extension', ->
    assert.equal 'answer1', get '/v2/foo/bar'

  it 'can use query parameters to find a more specific response', ->
    assert.equal 'answer3', get '/v2/foo/bar', p: '76'
    assert.equal 'answer1', get '/v2/foo/bar', p: '77'
