{ResponseSpecification} = require './responder'

class Dsl
  constructor: (@_addResponseSpecification, [@_path]) ->
    @_withMode = 'replaceContent'

  byReplacing: (key) ->
    @_withMode = 'replaceKey'
    @_key = key
    this

  with: (what) ->
    spec = switch @_withMode
      when 'replaceContent'
        path: @_path
        method: 'GET'
        query: {}
        body: what.body
        status: what.status
      when 'replaceKey'
        path: @_path
        method: 'GET'
        query: {}
        replaceKey: @_key
        replaceValue: what
    @_addResponseSpecification spec

module.exports = Dsl
