run = require '../../lib/realizer/run'
phrase = require 'phrase'
should = require 'should'

describe 'run', -> 

    beforeEach -> 
        @createRoot = phrase.createRoot

    afterEach -> 
        phrase.createRoot = @createRoot

    it 'has direction', -> throw 'direction'
    it 'has realize instead of event for control messages', -> throw 'realize'

    it 'is deferred', (done) -> 

        run
            uplink: 
                use: ->
                phrase: ->
            opts:
                title: 'Title'
                uuid:  'UUID'


        .then.should.be.an.instanceof Function
        done()


    it 'creates a phrase tree with uplink as the notifier', (done) -> 

        phrase.createRoot = (opts, linkFn) -> 
            opts.notice.should.equal 'uplink'
            done()
            throw 'go no further'

        try run
            uplink:     'uplink'
            opts:       {}
            realizerFn: ->


    context 'outbound messages', ->


    context 'inbound messages', -> 

        it 'rejects on reject', (done) -> 

            message = 
                direction: 'in'
                _type: 'realize'
                realize: 'reject'
                reason: 'REASON'
                other: 'STUFF'

            run 
                opts:       
                    title: 'TITLE'
                    uuid:  'UUID'
                realizerFn: ->
                uplink: 
                    phrase: ->
                    use: (opts, middleware) ->  
                        if opts.title == 'realizer control switch'
                            middleware (->), message

            .then(
                ->
                (error) -> 

                    error.should.match /reject/
                    error.code.should.equal 'ENO'
                    error.errno.should.equal 107
                    error.detail.reason.should.equal 'REASON'
                    done()

            )


        it 'recurses the phrase tree on load', (done) -> 

            message = 
                direction: 'in'
                _type: 'realize'
                realize: 'load'

            phrase.createRoot = (opts, linkFn) -> -> then: -> done()

            run
                opts:       
                    title: 'TITLE'
                    uuid:  'UUID'
                realizerFn: -> 
                uplink:  
                    use: (opts, middleware) ->  
                        if opts.title == 'realizer control switch'
                            middleware (->), message



        it 'sends the ready on load completed', (done) -> 

           message = 
                direction: 'in'
                _type: 'realize'
                realize: 'load'

            phrase.createRoot = (opts, linkFn) -> -> then: (resolve) -> resolve()

            run
                opts:       
                    title: 'TITLE'
                    uuid:  'UUID'
                realizerFn: ->  
                uplink:     
                    use: (opts, middleware) ->  
                        if opts.title == 'realizer control switch'
                            middleware (->), message
                    realize: (title) -> 
                        title.should.equal 'ready'
                        done()



        it 'calls a job into the phrase tree on run', (done) -> 

            message = 
                direction: 'in'
                realize: 'run'
                _type: 'realize'
                uuid:  'UUUUID'
                params: 
                    jobparameter: 1

            phrase.createRoot = (opts, linkFn) -> 
                linkFn token = run: (opts, params) -> 

                    opts.uuid.should.equal 'UUUUID'
                    params.should.eql jobparameter: 1
                    done()
                    then: ->

                -> then: ->

            run
                opts:       
                    title: 'TITLE'
                    uuid:  'UUID'
                realizerFn: ->  
                uplink:     
                    use: (opts, middleware) ->  
                        if opts.title == 'realizer control switch'
                            middleware (->), message


    context 'standalone mode (-x)', -> 

        it 'automatically loads the realizer phrase tree', (done) -> 

            #
            # by sending the load event that the objective 
            # would normally send
            #

            phrase.createRoot = (opts, linkFn) -> 
                return (title, realizerFn) -> 
                    title.should.equal 'realizer'
                    realizerFn().should.equal 'okgood'
                    done()
                    then: ->

            run 
                opts: 
                    standalone: true
                uplink: 
                    use: ->
                realizerFn: -> 'okgood'


        it 'call to run from the phrase root on ready', (done) -> 

            phrase.createRoot = (opts, linkFn) -> 

                linkFn 
                    on: (event, listener) -> 
                        if event == 'ready' then listener()
                    run: (opts) -> 

                        #
                        # it calls run with phrase uuid
                        #

                        opts.uuid.should.equal 'UUID'
                        done()
                        then: ->

                return (title, realizerFn) -> 
                    then: ->

            run 
                opts: 
                    uuid: 'UUID'
                    standalone: true
                uplink: 
                    use: ->
                realizerFn: -> 'okgood'
