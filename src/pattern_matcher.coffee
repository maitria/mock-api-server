'use strict'

{each, keys} = require 'underscore'

WILDCARD = '*'

FAIL = 0
START = 1

failOnAny = ->
  state = {}
  state[WILDCARD] = FAIL
  state

compileNFA = (pattern) ->
  states = []

  states[FAIL] = failOnAny()

  currentState = START

  each pattern, (char) ->
    states[currentState] ?= failOnAny()
    if char == WILDCARD
      states[currentState][WILDCARD] = currentState
    else
      states[currentState][char] = currentState + 1
      currentState += 1

  states[currentState] ?= failOnAny()
  successState = currentState

  {states, successState}

module.exports =
patternMatcher = (pattern) ->
  return false unless pattern

  {states, successState} = compileNFA pattern

  (value) ->
    currentStates = {}
    currentStates[START] = true

    each value, (char) ->
      nextStates = {}
      each (keys currentStates), (state) ->
        nextStates[states[state][WILDCARD]] = true
        if states[state][char]?
          nextStates[states[state][char]] = true
      currentStates = nextStates

    currentStates[successState]?
