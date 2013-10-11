connect = require '../../lib/realizer/connect'
notice  = require 'notice'
should  = require 'should'

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

        connect

            opts: uuid: 'UUID'
            realizerFn: -> 'okgood'

        .then ({uplink, opts, realizerFn}) -> 

            uplink.use.should.be.an.instanceof Function
            realizerFn().should.equal 'okgood'
            opts.should.eql 
                uuid: 'UUID'
                standalone: true
            done()

    it 'allows definition of additional capsules', (done) -> 

        connect
            opts: 
                uuid: 'UUID'
                capsules: 
                    flotsam:  {} 
                    jetsum:   {}
                    lagan:    {}
                    derelict: {}
            realizerFn: -> 

        .then ({uplink}) -> 

            uplink.flotsam .should.be.an.instanceof Function
            uplink.jetsum  .should.be.an.instanceof Function
            uplink.lagan   .should.be.an.instanceof Function
            uplink.derelict.should.be.an.instanceof Function

            uplink.event   .should.be.an.instanceof Function
            done()



    it 'starts a connected notifier with connect spec', (done) -> 

        notice.client = -> create: (title, opts, callback) -> 

            opts.connect.should.eql 
                adaptor: 'socket.io'
                url: 'https://localhost:11111'

            callback null, 'NOTICE'

        connect
            opts: 
                uuid:'UUID'
                connect: 
                    adaptor: 'socket.io'
                    url: 'https://localhost:11111'

            realizerFn: -> 'okgood'

        .then ({uplink, opts, realizerFn}) -> 

            uplink.should.equal 'NOTICE'
            realizerFn().should.equal 'okgood'
            done()


    it 'sets notice origin context with the realizer properties', (done) -> 

        notice.client = -> create: (title, {context}, callback) -> 

            context.should.eql
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

        notice.client = -> create: (title, {context}, callback) -> 

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

    it 'sets opts.standalone if no connect spec', (done) -> 

        notice.create = ->
        connect
            opts: 
                uuid:'UUID'
        .then ({opts}) -> 

            opts.standalone.should.equal true
            done()

