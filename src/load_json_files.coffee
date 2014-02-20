async = require 'async'
path = require 'path'
fs = require 'fs'
{each, filter, map} = require 'underscore'

safeFilenames = (filenames) ->
  filter filenames, (filename) ->
    filename != '.DS_Store'

fileStat = (file, done) ->
  fs.stat file.path, done

recursivelyFindFiles = (root, resultPrefix, done) ->
  fs.readdir root, (err, filenames) ->
    return done err if err?

    files = map safeFilenames(filenames), (filename) ->
      path: path.join root, filename
      resultPath: path.join resultPrefix, filename

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
          results.push file

      async.series subActions, (err, listOfSubResults) ->
        return done err if err?
        each listOfSubResults, (subResults) ->
          results = results.concat subResults
        done null, results

jsonLoadingActions = (files) ->
  actions = {}
  each files, (file) ->
    actions[file.resultPath] = (done) ->
      fs.readFile file.path, (err, contents) ->
        return done err if err?

        # Grab all lines.
        lines = contents.toString('utf-8').split("\n")

        # Ignore the first line of the file.
        firstLine = lines.shift()

        # Ignore the second line of the file.
        secondLine = lines.shift()

        # Build JSON back up from the rest of the lines.
        json = lines.join("\n")

        done null, JSON.parse json
  actions

module.exports = (path, done) ->
  recursivelyFindFiles path, '/', (err, files) ->
    return done err if err?
    async.parallel jsonLoadingActions(files), done
