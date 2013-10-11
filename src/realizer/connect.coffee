{deferred} = require 'also'
notice     = require 'notice'
error      = require './error'

module.exports = connect = deferred (action, realizer) ->

    {resolve, reject, notify} = action
    {opts, realizerFn} = realizer

    process.nextTick -> 

        noticeConfig = capsule: opts.capsules || {}
        noticeConfig.capsule.event ||= {}

        unless opts.connect? 
            opts.standalone = true
            return resolve
                realizerFn: realizerFn
                uplink: notice( noticeConfig ).create opts.uuid
                opts: opts

        opts.connect.address = opts.connect.hostname

        origin = {}
        for key of opts
            continue if key == 'connect'
            origin[key] = opts[key]
        opts.origin = origin

        notice.connect opts.uuid, opts, (err, uplink) -> 

            if err? then return reject error 
                errno:   err.errno || 106
                code:    err.code || 'ENOUPLINK'
                message: err.message
                
            resolve
                realizerFn: realizerFn
                uplink: uplink
                opts: opts
