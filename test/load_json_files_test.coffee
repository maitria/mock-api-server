assert = require 'assert'
cannedFs = require '../src/load_json_files'
fs = require 'fs'

describe 'loading json files', ->

  result = undefined
  before (done) ->
    cannedFs './test/mock-api', (err, fsHash) =>
      assert !err
      result = fsHash
      done()

  it 'has entries for the files we know about', ->
    assert result['/GET/v2/hello.json']

  it 'has the status code', ->
    assert.equal 200, result['/GET/v2/hello.json'].status

  it 'supports non 200 status codes', ->
    assert.equal 404, result['/GET/v2/junk.json'].status

  it 'has parsed the body', ->
    assert.equal "Hello, World!", result['/GET/v2/hello.json'].body.answer

  context 'when we have .DS_Store files', ->
    before ->
      fs.writeFileSync 'test/mock-api/GET/v2/.DS_Store', ''

    after ->
      try
        fs.unlinkSync 'test/mock-api/GET/v2/.DS_Store'
      catch error
        null

    it 'ignores .DS_Store', ->
      assert !result['/GET/v2/.DS_Store']

