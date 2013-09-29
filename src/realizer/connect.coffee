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

        opts.connect.address = opts.connect.hostname

        origin = {}
        for key of opts
            continue if key == 'connect'
            origin[key] = opts[key]
        opts.origin = origin

        notice.connect opts.uuid, opts, (err, uplink) -> 
                
            resolve
                realizerFn: realizerFn
                uplink: uplink
                opts: opts
