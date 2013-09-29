{deferred} = require 'also'
{error}    = require './'

module.exports = connect = deferred (action, realizer) ->

    action.resolve 'pending controls'
