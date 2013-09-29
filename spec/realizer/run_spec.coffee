run = require '../../lib/realizer/run'
phrase = require 'phrase'
should = require 'should'

describe 'run', -> 

    beforeEach -> 
        @createRoot = phrase.createRoot

    afterEach -> 
        phrase.createRoot = @createRoot

    it 'is deferred', (done) -> 

        run
            uplink: 
                use: ->
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

        context 'connect, reconnect, ready, error', -> 

            it 'includes uuid, pid and hostname', (done) -> 

                message = 
                    direction: 'out'
                    event: 'connect'

                run
                    opts:       
                        title: 'TITLE'
                        uuid:  'UUID'
                    realizerFn: ->
                    uplink:     
                        use: (middleware) ->  
                            if middleware.toString().match /realizer middleware 1/
                                middleware message, ->

                process.nextTick -> 
                    should.exist message.hostname
                    should.exist message.uuid
                    should.exist message.hostname
                    done()

        context 'inbound messages', -> 

            it 'rejects on reject', (done) -> 

                message = 
                    direction: 'in'
                    event: 'reject'
                    reason: 'REASON'
                    other: 'STUFF'

                run 
                    opts:       
                        title: 'TITLE'
                        uuid:  'UUID'
                    realizerFn: ->
                    uplink:     
                        use: (middleware) ->  
                            if middleware.toString().match /realizer middleware 1/
                                middleware message, ->

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
                    event: 'load'

                phrase.createRoot = (opts, linkFn) -> -> then: -> done()

                run
                    opts:       
                        title: 'TITLE'
                        uuid:  'UUID'
                    realizerFn: -> 
                    uplink:     
                        use: (middleware) ->  
                            if middleware.toString().match /realizer middleware 1/
                                middleware message, ->



            it 'sends the ready::N on load completed', (done) -> 

               message = 
                    direction: 'in'
                    event: 'load'

                phrase.createRoot = (opts, linkFn) -> -> then: (resolve) -> resolve()

                run
                    opts:       
                        title: 'TITLE'
                        uuid:  'UUID'
                    realizerFn: ->  
                    uplink:     
                        use: (middleware) ->  
                            if middleware.toString().match /realizer middleware 1/
                                middleware message, ->
                        event: good: (title) -> 
                            title.should.equal 'ready::1'
                            done()



