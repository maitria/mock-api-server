'use strict'

{isObject} = require 'underscore'
{ResponseSpecification} = require './responder'

class Dsl
  constructor: (@_addResponseSpecification, [@_path]) ->
    @_withMode = 'replaceContent'

  byReplacing: (key) ->
    @_withMode = 'replaceKey'
    @_key = key
    this

  with: (what) ->
    if isObject what
      body = what.body
      statusCode = what.statusCode || 200
      method = what.method || 'GET'
    else
      body = what
      statusCode = 200
      method = 'GET'

    spec = switch @_withMode
      when 'replaceContent'
        path: @_path
        method: method
        query: {}
        body: body
        statusCode: statusCode
      when 'replaceKey'
        path: @_path
        method: method
        query: {}
        replaceKey: @_key
        replaceValue: what
    @_addResponseSpecification spec

module.exports = Dsl
