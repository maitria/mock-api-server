assert = require 'assert'
http = require 'http'
MockApi = require '../lib/index.js'
#MockApi = require '../src/index'
{readFile, unlink} = require 'fs'
{extend, findWhere, identity, map, pick} = require 'underscore'

doRequest = (options, configureServer, testFn) ->
  apiServerOptions = pick options, 'port', 'logToFile', 'testPath'

  server = new MockApi apiServerOptions
  server.start (err) ->
    configureServer server

    requestOptions =
      port: options.port
      hostname: 'localhost'
      method: 'GET'
      path: '/v2/hello'

    request = http.request requestOptions, (res) ->
      pageContents = ""
      res.on 'data', (chunk) ->
        pageContents += chunk
      res.on 'end', ->
        server.stop()
        testFn {statusCode: res.statusCode, body: pageContents}
    request.end()

describe 'a mock API server', ->

  it 'serves static API responses', (done) ->
    options =
      port: 7001

    doRequest options, identity, ({body, statusCode}) ->
      assert.equal JSON.parse(body).answer, "Hello, World!"
      assert.equal 200, statusCode
      done()

  it 'logs to a file when configured', (done) ->
    unlink './tmp/foo.log', ->
      options =
        port: 7002
        logToFile: "./tmp/foo.log"

      doRequest options, identity, ->
        readFile './tmp/foo.log', (err, buffer) ->
          throw err if err?

          logLines = map buffer.toString().split(/\n/), (s) ->
            if s == ""
              null
            else
              JSON.parse s

          requestLogLine = findWhere logLines, message: '[MOCK-REQUEST]'
          assert.equal '/v2/hello', requestLogLine.meta.path
          done()

  it 'allows for modified responses', (done) ->
    options =
      port: 7003

    configureServer = (server) ->
      server.respondTo('/v2/hello').with
        statusCode: 200
        body:
          answer: "Modified Hello, World!"

    doRequest options, configureServer, ({body, statusCode}) ->
      assert.equal JSON.parse(body).answer, "Modified Hello, World!"
      assert.equal 200, statusCode
      done()

  it 'can reset the state', (done) ->
    options =
      port: 7004

    configureServer = (server) ->
      server.respondTo('/v2/hello').with
        statusCode: 200
        body:
          answer: "Modified Hello, World!"
      server.reset()

    doRequest options, configureServer, ({body, statusCode}) ->
      assert.equal JSON.parse(body).answer, "Hello, World!"
      assert.equal 200, statusCode
      done()

  it 'supports non-200 responses', (done) ->
    options =
      port: 7005

    configureServer = (server) ->
      server.respondTo('/v2/hello').with
        statusCode: 404
        body:
          answer: "Not Found"

    doRequest options, configureServer, ({body, statusCode}) ->
      assert.equal JSON.parse(body).answer, "Not Found"
      assert.equal 404, statusCode
      done()

  it 'supports configurable test-path', ->
    options =
      testPath: 'test/mock-api-custom-path2'

    doRequest options, identity, ({body, statusCode}) ->
      assert.equal JSON.parse(body).answer, "Hello, World!"
      assert.equal 200, statusCode
      done()
