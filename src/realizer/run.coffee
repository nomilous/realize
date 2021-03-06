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


    uplink.use (msg, next) => 

        ### realizer middleware 1 ###

        switch msg.direction

            when 'out' 
                # switch msg.event
                #     when 'connect', 'reconnect', 'error'
                #     else if msg.event.match /^ready::/

                msg.uuid     = opts.uuid
                msg.pid      = process.pid
                msg.hostname = hostname()

                console.log SENDING: msg.context, msg
                next()

            when 'in'

                console.log RECEIVING: msg.context, msg
                switch msg.event

                    when 'reject'

                        err = error
                            errno:   107
                            code:    'ENO'
                            message: msg.event
                            detail:  {}

                        err.detail[key] = msg[key] for key of msg
                        reject err
                        return next()

                    when 'load'

                        load().then(

                            (result) -> uplink.event.good "ready::#{++readyCount}"  # , result
                            (error)  -> 

                                payload = error: error.toString()
                                try payload.stack = error.stack
                                uplink.event.bad 'error', payload

                            #(notify) -> console.log PHRASE_INIT_NOTIFY: notify

                        )
                        return next()

                    when 'run'

                        return next() unless uuid = msg.uuid
                        job    = uuid: uuid
                        params = msg.params || {}

                        console.log RUN: uuid
                        console.log TODO: 'job.run() with optional input of JobUUID'
                        
                        @token.run( job, params ).then( 

                            (result) -> console.log JOB_RESULT: result
                            (error)  -> console.log JOB_ERROR:  error

                        )

                        return next()

                next()

