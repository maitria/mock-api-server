assert = require 'assert'
cannedFs = require '../lib/canned_fs.js'

describe 'canned filesystem reader', ->

  result = undefined
  before (done) ->
    cannedFs './test/mock-api', (err, fsHash) =>
      assert !err
      result = fsHash
      done()

  it 'has entries for the files we know about', ->
    assert result['/v2/hello.json']

