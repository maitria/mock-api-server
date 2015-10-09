'use strict'

assert = require 'assert'
cannedFs = require '../src/load_files'
fs = require 'fs'

describe 'loading json files', ->

  result = undefined
  before (done) ->
    cannedFs './test/mock-api', (err, fsHash) ->
      assert !err
      result = fsHash
      done()

  it 'has entries for the files we know about', ->
    assert.equal result['/GET/v2/hello.json'].toString('utf-8'), '200 OK\n\n{"answer": "Hello, World!"}\n'
    assert.equal result['/POST/v2/hello.json'].toString('utf-8'), '200 OK\n\n{"answer": "Goodbye Cruel World"}\n'

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

