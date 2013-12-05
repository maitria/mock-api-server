assert = require 'assert'
cannedMap = require '../src/static_response_map'

describe 'static response map', ->

  data =
    '/GET/v2/foo/bar.json': 'answer1'
    '/GET/v2/foo/bar.json?p=76': 'answer3'
    '/GET/v2/foo/bar.json?p=76&j=77': 'answer5'
    '/GET/v2/foo/baz.json': 'answer2'
    '/GET/v2/foo/baz.json?x=hello*world*': 'answer4'

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

  it 'uses query parameters to find a more specific response', ->
    assert.equal 'answer5', get '/v2/foo/bar', p: '76', j: '77'
    assert.equal 'answer3', get '/v2/foo/bar', p: '76'
    assert.equal 'answer1', get '/v2/foo/bar'

  it 'handles wildcards in the query value', ->
    assert.equal 'answer4', get '/v2/foo/baz', x: 'hello, world!!'
    assert.equal 'answer2', get '/v2/foo/baz', x: 'helloorld'
