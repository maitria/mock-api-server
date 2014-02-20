express = require 'express'
loadJsonFiles = require './load_json_files'
lumber = require 'clumber'
mockApiServer = require './index'
{pick} = require 'underscore'
{Responder, ResponseSpecification} = require './responder'

HELP_MESSAGE = \
"mock-api-server: A stand-in for a real API server
Usage:

  mock-api-server --port PORT

Options:

  --port PORT           The port to listen on (required).
"

class Server
  constructor: (@argv) ->

  run: ->
    help = false
    @options = logToConsole: true

    while @argv.length > 0
      if '--help' == @argv[0]
        help = true
        @argv.shift()
      else if '--port' == @argv[0]
        @argv.shift()
        @options.port = @argv.shift() | 0
      else if '--no-log-to-console' == @argv[0]
        @argv.shift()
        @options.logToConsole = false
      else if '--log-to-file' == @argv[0]
        @argv.shift()
        @options.logToFile = @argv.shift()
      else
        console.log 'Unknown option `' + @argv[0] + '` (use --help).'
        process.exit 1

    if help
      console.log HELP_MESSAGE
      process.exit 0

    if !@options.port
      console.log "mock-api-server: No PORT supplied (see --help)."
      process.exit 1

    @start (err, server) ->

  start: (done) ->
    @logger = @_initLogger()
    @logger.info '[STARTING-SERVER]'

    @app = express()
    @app.use express.json()
    @app.use @_cannedResponses
    @app.get '/mock-api/stop', @_stop
    @app.get '/mock-api/reset', @_reset
    @app.post '/mock-api/add-response', @_addResponse

    loadJsonFiles 'test/mock-api', (err, hash) =>

      # Convert `hash` into new format expected by Responder.
      hashWithBodyAndStatus = {}
      for endpoint, responseBody of hash
        hashWithBodyAndStatus[endpoint] =
          status: 200
          body: responseBody

      @originalResponder = @responder = new Responder hashWithBodyAndStatus
      @server = @app.listen @options.port, done
 
  _stop: (req, res) =>
    @logger.info '[STOPPING-SERVER]'
    die = =>
      @server.close()
      process.exit 0
    setTimeout die, 50
    res.send 'OK'

  _reset: (req, res) =>
    @responder = @originalResponder
    res.send 'OK'

  _addResponse: (req, res) =>
    spec = new ResponseSpecification(req.body)
    @responder = @responder.withResponseSpecification spec
    res.send 'OK'

  _initLogger: () ->
    transports = []
    transports.push new lumber.transports.Console if @options.logToConsole

    if @options.logToFile?
      transports.push new lumber.transports.File
        filename: @options.logToFile
        level: 'info'

    new lumber.Logger(transports: transports)
 
  _cannedResponses: (req, res, next) =>
    request = pick req, 'method', 'path', 'query'
    @logger.info '[MOCK-REQUEST]', request
    response = @responder.respondTo request
    return next() if response == undefined
    @logger.info '[MOCK-RESPONSE]', response
    res.header 'Content-Type', 'application/json'
    res.send JSON.stringify response
 
module.exports = Server
