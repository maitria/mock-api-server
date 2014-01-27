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

  it 'has parsed the contents', ->
    assert.equal "Hello, World!", result['/GET/v2/hello.json'].answer

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

