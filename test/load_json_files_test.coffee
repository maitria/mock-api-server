assert = require 'assert'
cannedFs = require '../src/load_json_files'

describe 'loading json files', ->

  result = undefined
  before (done) ->
    cannedFs './test/mock-api', (err, fsHash) =>
      assert !err
      result = fsHash
      done()

  it 'has entries for the files we know about', ->
    assert result['/GET/v2/hello.json']

  it 'has parsed the contents', ->
    assert.equal "Hello, World!", result['/GET/v2/hello.json'].answer

