{each, keys} = require 'underscore'

module.exports =
mtachesPattern = (pattern, value) ->
  return false unless pattern

  # Compile a simple NFA matcher
  states = []

  FAIL = 0
  START = 1

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
  SUCCESS = currentState

  # Run it
  currentStates = {}
  currentStates[START] = true

  each value, (char) ->
    nextStates = {}
    each (keys currentStates), (state) ->
      nextStates[states[state]['%']] = true
      if states[state][char]?
        nextStates[states[state][char]] = true
    currentStates = nextStates

  currentStates[SUCCESS]?

