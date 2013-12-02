{each, keys} = require 'underscore'

FAIL = 0
START = 1

compileNFA = (pattern) ->
  states = []

  states[FAIL] = '%': FAIL

  currentState = START
  sawWildcard = false

  each pattern, (char) ->
    states[currentState] ?= '%': FAIL
    if char == '%'
      states[currentState]['%'] = currentState
    else
      states[currentState][char] = currentState + 1
      currentState += 1
      sawWildcard = false

  states[currentState] ?= '%': FAIL
  successState = currentState

  {states,successState}

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
        nextStates[states[state]['%']] = true
        if states[state][char]?
          nextStates[states[state][char]] = true
      currentStates = nextStates

    currentStates[successState]?
