{deferred} = require 'also'
error      = require './error'

module.exports = connect = deferred (action, realizer) ->

    action.resolve 'pending controls'
