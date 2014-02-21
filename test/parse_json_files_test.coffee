assert = require 'assert'
parseJsonFiles = require '../src/parse_json_files'
fs = require 'fs'

describe 'loading json files', ->

  before ->
    @fileHash =
      '/GET/v2/hello.json': '200 OK\n\n{"answer": "Hello, World!"}\n'
      '/GET/v2/junk.json': '404 NOT FOUND\n\n{"answer": "Not Found"}\n'
      '/POST/v2/hello.json': '200 OK\n\n{"answer": "Goodbye Cruel World"}\n'

  it 'has the status code', ->
    responseHash = parseJsonFiles @fileHash

    assert.equal 200, responseHash['/GET/v2/hello.json'].statusCode
    assert.equal 404, responseHash['/GET/v2/junk.json'].statusCode
    assert.equal 200, responseHash['/POST/v2/hello.json'].statusCode

  it 'has the parsed body', ->
    responseHash = parseJsonFiles @fileHash

    assert.equal "Hello, World!", responseHash['/GET/v2/hello.json'].body.answer
    assert.equal "Not Found", responseHash['/GET/v2/junk.json'].body.answer
    assert.equal "Goodbye Cruel World", responseHash['/POST/v2/hello.json'].body.answer
