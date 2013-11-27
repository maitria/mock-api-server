assert = require 'assert'
canned = require '../lib/canned.js'

describe 'canned response map', ->

  it 'finds a simple request in the map', ->
    data =
      'v2/foo/bar.json': 'answer1'
    request =
      method: "GET"
      path: "/v2/foo/bar.json"

    assert.equal 'answer1', (canned data) request
