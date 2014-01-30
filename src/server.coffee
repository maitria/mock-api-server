mockApiServer = require './index'

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
    options = logToConsole: true

    while @argv.length > 0
      if '--help' == @argv[0]
        help = true
        @argv.shift()
      else if '--port' == @argv[0]
        @argv.shift()
        options.port = @argv.shift() | 0
      else
        console.log 'Unknown option `' + @argv[0] + '` (use --help).'
        process.exit 1

    if help
      console.log HELP_MESSAGE
      process.exit 0

    if !options.port
      console.log "mock-api-server: No PORT supplied (see --help)."
      process.exit 1

    mockApiServer options, (err, server) ->

module.exports = Server
