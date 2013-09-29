{deferred} = require 'also'
{error}    = require './'

module.exports = configure = deferred (action, params) ->

    action.resolve 'pending realizer'
