assert = require 'assert'
http = require 'http'
mockApiServer = require '../lib/index.js'

describe 'a mock API server', ->

  it 'accepts requests on the specified port', (done) ->
    mockApiServer port: 41998, (err, server) ->
      requestOptions =
        port: 41998
        hostname: "localhost"
        method: "GET"
        path: "/"
      request = http.request requestOptions, (res) ->
        server.stop()
        done()
      request.end()

