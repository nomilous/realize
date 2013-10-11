{deferred} = require 'also'
notice     = require 'notice'
error      = require './error'

module.exports = connect = deferred (action, realizer) ->

    {resolve, reject, notify} = action
    {opts, realizerFn} = realizer

    process.nextTick -> 

        noticeConfig = capsule: opts.capsules || {}

        #
        # realizer message bus builtin capsule types
        # ------------------------------------------
        # 
        # * `notice.realize()` - realize control messages
        # * `notice.phrase()`  - required by phrase submodule
        #

        noticeConfig.capsule.realize ||= {}
        noticeConfig.capsule.phrase  ||= {}

        unless opts.connect? 
            opts.standalone = true
            return resolve
                realizerFn: realizerFn
                uplink: notice( noticeConfig ).create opts.uuid
                opts: opts


        context = {}
        for key of opts
            continue if key == 'connect'
            context[key] = opts[key]
        opts.context = context

        MessageBus = notice.client noticeConfig
        MessageBus.create opts.uuid, opts, (err, uplink) -> 

            if err? then return reject error 
                errno:   err.errno || 106
                code:    err.code || 'ENOUPLINK'
                message: err.message
                
            resolve
                realizerFn: realizerFn
                uplink: uplink
                opts: opts
