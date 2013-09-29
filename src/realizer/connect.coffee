{deferred} = require 'also'
notice     = require 'notice'
error      = require './error'

module.exports = connect = deferred (action, realizer) ->

    {resolve, reject, notify} = action
    {opts, realizerFn} = realizer

    process.nextTick -> 

        unless opts.connect? 
            return resolve
                realizerFn: realizerFn
                uplink: notice.create opts.uuid
                opts: opts
                
        
