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

