'use strict'

assert = require 'assert'
{Responder, ResponseSpecification} = require '../src/responder'
Dsl = require '../src/dsl'

describe 'Responder', ->

  data =
    '/GET/v2/foo/bar.json':
      statusCode: 200
      body: 'answer1'
    '/GET/v2/foo/bar.json?p=76':
      statusCode: 200
      body: 'answer3'
    '/GET/v2/foo/bar.json?p=76&j=77':
      statusCode: 200
      body: 'answer5'
    '/PUT/v2/foo/bar.json':
      statusCode: 200
      body: 'answer6'
    '/GET/v2/foo/baz.json':
      statusCode: 200
      body: 'answer2'
    '/GET/v2/foo/baz.json?x=hello*world*':
      statusCode: 200
      body: 'answer4'
    '/GET/v2/data.json':
      statusCode: 200
      body:
        one: 1
        two: 2
        fortyTwo: [
          { x: 69 },
          { y: { z: 96 } }
        ]

  responder = undefined
  beforeEach ->
    responder = new Responder data

  saveSpec = (s) ->
    responder = responder.withResponseSpecification new ResponseSpecification s

  respondTo = (path) ->
    new Dsl saveSpec, [path]

  doMethod = (method) ->
    (path, query) ->
      responder.respondTo
        method: method
        query: query || {}
        path: path

  get = doMethod 'GET'
  put = doMethod 'PUT'

  it 'finds a simple request in the map', ->
    {body, statusCode} = get '/v2/foo/bar.json'
    assert.equal 'answer1', body
    assert.equal 200, statusCode

  it 'finds a different simple request in the map', ->
    {body, statusCode} = get '/v2/foo/baz.json'
    assert.equal 'answer2', body
    assert.equal 200, statusCode

  it 'answers undefined when no request is found', ->
    assert.strictEqual undefined, get '/v2/foo/quux.json'

  it 'finds a request without an extension', ->
    {body, statusCode} = get '/v2/foo/bar'
    assert.equal 'answer1', body
    assert.equal 200, statusCode

  it 'uses query parameters to find a more specific response', ->
    assert.equal 'answer5', get('/v2/foo/bar', p: '76', j: '77').body
    assert.equal 'answer3', get('/v2/foo/bar', p: '76').body
    assert.equal 'answer1', get('/v2/foo/bar').body

  it 'handles wildcards in the query value', ->
    assert.equal 'answer4', get('/v2/foo/baz', x: 'hello, world!!').body
    assert.equal 'answer2', get('/v2/foo/baz', x: 'helloorld').body

  it 'handles other methods', ->
    {body, statusCode} = put '/v2/foo/bar'
    assert.equal 'answer6', body

  context 'with a run-time response spec', ->

    it 'allows adding a response at run-time', ->
      respondTo('/v2/foo/slime.json').with
        statusCode: 200
        body: 'stuffed-in-response'

      {body, statusCode} = get '/v2/foo/slime.json'
      assert.equal 'stuffed-in-response', body
      assert.equal 200, statusCode

    it 'allows adding a response by providing a response body', ->
      respondTo('/v2/foo/goo.json').with('something-gooey')

      {body, statusCode} = get '/v2/foo/goo.json'
      assert.equal 'something-gooey', body
      assert.equal 200, statusCode

    it 'does not modified the original responder', ->
      original = responder
      respondTo('/v2/foo/slime.json').with
        statusCode: 200
        body: 'stuffed-in-response'
      responder = original
      assert.strictEqual undefined, get '/v2/foo/slime.json'

    it 'allows overriding pre-existing entries', ->
      respondTo('/v2/foo/bar.json').with
        statusCode: 200
        body: 'stuffed-in-response'

      {body, statusCode} = get '/v2/foo/bar.json'
      assert.equal 'stuffed-in-response', body
      assert.equal 200, statusCode

    it 'allows replacing a key in a response', ->
      respondTo('/v2/data.json').byReplacing('fortyTwo[1].y').with([ 88 ])
      expected =
        one: 1
        two: 2
        fortyTwo: [
          { x: 69 },
          { y: [ 88 ] }
        ]

      {body, statusCode} = get '/v2/data.json'
      assert.deepEqual expected, body
      assert.equal 200, statusCode
