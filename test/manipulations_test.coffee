assert = require 'assert'
{keyReplacer} = require '../src/manipulations'

describe '#keyReplacer', ->

  it 'handles dot-separated keys', ->
    options =
      replaceKey: 'foo.bar.baz'
      replaceValue: 69
    result = keyReplacer(options)(foo: bar: baz: quux: 42)
    assert.deepEqual(foo: bar: baz: 69, result)

  it 'handles square-braced keys', ->
    options =
      replaceKey: 'foo[1].baz'
      replaceValue: 69
    result = keyReplacer(options)(foo: [79, baz: quux: 42])
    assert.deepEqual(foo: [79, baz: 69], result)
