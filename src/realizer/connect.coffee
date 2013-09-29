{deferred} = require 'also'
error      = require './error'

module.exports = connect = deferred (action, realizer) ->

    {resolve, reject, notify} = action
    {opts, realizerFn} = realizer

    console.log OPTS: opts

