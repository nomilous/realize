connect = require '../../lib/realizer/connect'
notice  = require 'notice'

describe 'connect', -> 

    beforeEach -> 
        @create = notice.create

    afterEach -> 
        notice.create = @create

    it 'is deferred', (done) -> 

        connect

            opts: uuid: 'UUID'

        .then.should.be.an.instanceof Function
        done()


    it 'starts standalone notifier if no connect spec', (done) ->

        notice.create = -> 'NOTICE'

        connect

            opts: uuid: 'UUID'
            realizerFn: -> 'okgood'

        .then ({uplink, opts, realizerFn}) -> 

            uplink.should.equal 'NOTICE'
            realizerFn().should.equal 'okgood'
            opts.should.eql uuid: 'UUID'
            done()

    it 'starts a connected notifier with connect spec', (done) -> 

        notice.connect = (originName, opts, callback) -> 

            callback null, 'NOTICE'

        connect
            opts: 
                uuid:'UUID'
                connect: 
                    port: 10101
            realizerFn: -> 'okgood'

        .then ({uplink, opts, realizerFn}) -> 

            uplink.should.equal 'NOTICE'
            realizerFn().should.equal 'okgood'
            done()


    it 'sets notice origin context with the realizer properties', (done) -> 

        notice.connect = (originName, {origin}, callback) -> 

            origin.should.eql
                title: 'Title'
                uuid: 'UUID'
                description: 'Description'
                other: 
                    stuff: 'also'
            done()

        connect
            opts: 
                title: 'Title'
                uuid: 'UUID'
                connect: 
                    port: 10101
                description: 'Description'
                other:  
                    stuff: 'also'
            realizerFn: -> 'okgood'

    it 'rejects on notice connect error', (done) -> 

        notice.connect = (originName, opts, callback) -> 

            callback new Error 'connect error'

        connect
            opts: 
                uuid:'UUID'
                connect: 
                    port: 10101
            realizerFn: -> 'okgood'

        .then (->), (error) -> 

            error.errno.should.equal 106
            error.code.should.equal 'ENOUPLINK'
            error.message.should.equal 'connect error'
            done()



