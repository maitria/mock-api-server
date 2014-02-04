assert = require 'assert'
{Responder, ResponseSpecification} = require '../src/responder'

describe 'Responder', ->

  data =
    '/GET/v2/foo/bar.json': 'answer1'
    '/GET/v2/foo/bar.json?p=76': 'answer3'
    '/GET/v2/foo/bar.json?p=76&j=77': 'answer5'
    '/PUT/v2/foo/bar.json': 'answer6'
    '/GET/v2/foo/baz.json': 'answer2'
    '/GET/v2/foo/baz.json?x=hello*world*': 'answer4'
    '/GET/v2/data.json':
      one: 1
      two: 2
      fortyTwo: [
        { x: 69 },
        { y: { z: 96 } }
      ]

  doMethod = (method) ->
    (path, query) ->
      new Responder(data).respondTo
        method: method
        query: query || {}
        path: path

  get = doMethod 'GET'
  put = doMethod 'PUT'

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

  it 'handles other methods', ->
    assert.equal 'answer6', put '/v2/foo/bar'

  context 'with a run-time response spec', ->

    responderWith = (path) ->
      spec = new ResponseSpecification
        path: path
        method: 'GET'
        content: 'stuffed-in-response'
        query: {}
      new Responder(data).withResponseSpecification spec

    getRequest = (path, query) ->
      method: 'GET'
      query: query ? {}
      path: path

    it 'allows adding a response at run-time', ->
      responder = responderWith '/v2/foo/slime.json'
      response = responder.respondTo getRequest '/v2/foo/slime.json'
      assert.equal 'stuffed-in-response', response

    it 'does not modified the original responder', ->
      original = new Responder(data)
      newSpec = new ResponseSpecification
        path: '/v2/foo/slime.json'
        method: 'GET'
        content: 'stuffed-in-response'
        query: {}
      original.withResponseSpecification newSpec
      response = original.respondTo getRequest '/v2/foo/slime.json'
      assert.strictEqual undefined, response

    it 'allows overriding pre-existing entries', ->
      responder = responderWith '/v2/foo/bar.json'
      response = responder.respondTo getRequest '/v2/foo/bar.json'
      assert.equal 'stuffed-in-response', response

    it 'allows replacing a key in a response', ->
      spec = new ResponseSpecification
        path: '/v2/data.json'
        method: 'GET'
        query: {}
        replaceKey: 'fortyTwo[1].y'
        replaceValue: [ 88 ]

      expected =
        one: 1
        two: 2
        fortyTwo: [
          { x: 69 },
          { y: [ 88 ] }
        ]

      responder = new Responder(data).withResponseSpecification spec
      assert.deepEqual expected, responder.respondTo getRequest '/v2/data.json'
