async = require 'async'
path = require 'path'
fs = require 'fs'
{each, extend, map} = require 'underscore'

recursivelyFindFiles = (root, resultPrefix, done) ->
  fs.readdir root, (err, filenames) ->
    return done err if err?

    files = map filenames, (filename) ->
      path: path.join root, filename
      resultPath: path.join resultPrefix, filename

    fileStat = (file, done) ->
      fs.stat file.path, done

    async.map files, fileStat, (err, statBuffers) ->
      return done err if err?

      results = []
      subActions = []

      each statBuffers, (statBuffer, i) ->
        file = files[i]
        if statBuffer.isDirectory()
          subActions.push (done) ->
            recursivelyFindFiles file.path, file.resultPath, done
        else
          results.push file.resultPath

      async.series subActions, (err, listOfSubResults) ->
        return done err if err?
        each listOfSubResults, (subResults) ->
          results = results.concat subResults
        done null, results

module.exports = (path, done) ->
  recursivelyFindFiles path, '/', (err, files) ->
    return done err if err?

    hash = {}
    each files, (file) ->
      hash[file] = 42

    done null, hash
