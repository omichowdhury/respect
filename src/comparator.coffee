
_ = require 'lodash/lang'


class Comparator

  ###
  METHODS
  ###

  @DEFAULT_OPTIONS:
    partial: yes
    regex: yes
    types: yes

  constructor: (@expected, @actual, options) ->
    @options = {}
    for optionName, defaultValue of @constructor.DEFAULT_OPTIONS
      @options[optionName] = options?[optionName]
      @options[optionName] ?= defaultValue
    @discrepency = []
    @displayActual = {}
    @conform = yes
    @comparePartial()
    if not @options.partial
      @checkForMissingKeys()

  comparePartial: =>
    for key, value of @expected
      @compareKey(key, value)

  checkForMissingKeys: =>
    for key of @actual when not (key of @expected)
      @compareKey key, undefined

  compareKey: (key, expected) =>
    actual = @actual[key]
    @displayActual[key] = actual
    if !@compareValues(expected, actual)
      @discrepency.push(key)
      @conform = no

  compareValues: (expected, actual) ->
    if _.isEqual expected, actual
      return yes
    if _.isPlainObject expected
      return @compareNested expected, actual
    if _.isArray expected
      if not ((_.isArray actual) and (actual.length is expected.length))
        return no
      return @compareNested expected, actual
    if @options.regex and _.isRegExp expected
      return (_.isString actual) and (actual.match expected)
    if @options.types and expected?.prototype?.hasOwnProperty('constructor')
      return actual?.constructor is expected
    return no

  compareNested: (expected, actual) ->
    subComparator = new @constructor expected, actual, @options
    return subComparator.conform

module.exports = Comparator
