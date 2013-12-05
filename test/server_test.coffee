assert = require 'assert'
http = require 'http'
mockApiServer = require '../lib/index.js'

describe 'a mock API server', ->

  it 'accepts requests on the specified port', (done) ->
    mockApiServer port: 7000, (err, server) ->
      requestOptions =
        port: 7000
        hostname: "localhost"
        method: "GET"
        path: "/"
      request = http.request requestOptions, (res) ->
        server.stop()
        done()
      request.end()

  it 'serves static API responses', (done) ->
    mockApiServer port: 7001, (err, server) ->
      requestOptions =
        port: 7001
        hostname: "localhost"
        method: "GET"
        path: "/v2/hello"
      request = http.request requestOptions, (res) ->
        assert.equal 200, res.statusCode
        pageContents = ""
        res.on 'data', (chunk) ->
          pageContents += chunk
        res.on 'end', ->
          assert.equal JSON.parse(pageContents).answer, "Hello, World!"
          server.stop()
          done()
      request.end()
