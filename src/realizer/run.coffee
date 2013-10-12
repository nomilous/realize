{deferred} = require 'also'
{hostname} = require 'os'
phrase     = require 'phrase'
error      = require './error'

module.exports = run = deferred (action, controls) ->

    {resolve, reject, notify}  = action
    {uplink, opts, realizerFn} = controls

    #
    # uplink     - connection to the objective (unless -x)
    # opts       - realizer title, uuid and such
    # realizerFn - realizer phrase function
    # 

    #
    # Initialize Realizer PhraseTree
    # ------------------------------
    #
    # * create the PhraseTree with objective uplink as message bus
    # 

    opts.notice    = uplink
    readyCount     = 0

    phraseRecursor = phrase.createRoot opts, (@token) => 

        if opts.standalone then @token.on 'ready', => 

            @token.run( uuid: opts.uuid ).then(

                (result) -> uplink.event 'result', result
                (error) -> uplink.event 'error',  error

            )
            

    load = -> 

        #
        # * nested load() loads the realizer phrase tree 
        # * the uplink to the objective is also the phrase tree 
        #   message bus, so all phrase assembly messages are received 
        #   by the local graph assembler and whatever middlewares are 
        #   listening at the objective
        # * this phraseRecursor returns a promise
        # 

        return phraseRecursor 'realizer', realizerFn


    if opts.standalone then return load()

        #
        # TODO: error to console if phrase falied to load
        #


    uplink.use 

        title: 'realizer control switch'

        (next, capsule, traverse) => 

            return next() unless capsule._type == 'realize'

            switch capsule.direction

                when 'out'

                    capsule.uuid     = opts.uuid
                    capsule.pid      = process.pid
                    capsule.hostname = hostname()

                    console.log SENDING: capsule.realize, capsule
                    return next()

                #when 'in'

            switch capsule.realize

                when 'reject'

                    err = error
                        errno:   107
                        code:    'ENO'
                        message: capsule.realize
                        detail:  {}

                    err.detail[key] = capsule[key] for key of capsule
                    reject err

                when 'load'

                    load().then(

                        (result) -> uplink.realize "ready::#{++readyCount}"  # , result
                        (error)  -> 

                            payload = error: error.toString()
                            try payload.stack = error.stack
                            uplink.realize 'error', payload

                        #(notify) -> console.log PHRASE_INIT_NOTIFY: notify

                    )

                when 'run'

                    return next() unless uuid = capsule.uuid
                    job    = uuid: uuid
                    params = capsule.params || {}

                    console.log RUN: uuid
                    console.log TODO: 'job.run() with optional input of JobUUID'
                    
                    @token.run( job, params ).then( 

                        (result) -> console.log JOB_RESULT: result
                        (error)  -> console.log JOB_ERROR:  error

                    )


            next()

