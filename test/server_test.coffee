assert = require 'assert'
http = require 'http'
mockApiServer = require '../lib/index.js'
{readFile, unlink} = require 'fs'
{findWhere, map} = require 'underscore'

describe 'a mock API server', ->

  it 'accepts requests on the specified port', (done) ->
    options =
      port: 7000

    mockApiServer options, (err, server) ->
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
    options =
      port: 7001

    mockApiServer options, (err, server) ->
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

  it 'logs to a file when configured', (done) ->
    unlink './tmp/foo.log', ->
      options =
        port: 7002
        logToFile: "./tmp/foo.log"

      mockApiServer options, (err, server) ->
        requestOptions =
          port: 7002
          hostname: "localhost"
          method: "GET"
          path: "/v2/hello"

        request = http.request requestOptions, (res) ->
          assert.equal 200, res.statusCode
          pageContents = ""
          res.on 'data', (chunk) ->
            pageContents += chunk
          res.on 'end', ->
            readFile './tmp/foo.log', (err, buffer) ->
              throw err if err?

              logLines = map buffer.toString().split(/\n/), (s) ->
                if s == ""
                  null
                else
                  JSON.parse s

              requestLogLine = findWhere logLines, message: '[MOCK-REQUEST]'
              assert.equal '/v2/hello', requestLogLine.meta.path

              server.stop()
              done()
        request.end()
