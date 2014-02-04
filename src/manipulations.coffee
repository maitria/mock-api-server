{each} = require 'underscore'

keyReplacer = (options) ->
  (content) ->
    eval "content.#{options.replaceKey} = " + JSON.stringify(options.replaceValue)
    content

module.exports = {keyReplacer}
