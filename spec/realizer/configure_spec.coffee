configure = require '../../lib/realizer/configure'

describe 'configure', -> 

    it 'is deferred', (done) -> 

        #
        # this means that the config step 
        # can breakout asynchronously
        # 

        configure().then.should.be.an.instanceof Function
        done()

    it 'rejects on unspecified realizer', (done) -> 

        configure().then (->), (error) -> 

            error.errno.should.equal 10001
            error.message.should.match /No realizer specified/
            error.code.should.equal 'ENOREALIZER'
            done()
        
    it 'rejects on missing file', (done) -> 

        configure

            filename: 'missing.coffee'

        .then (->), (error) -> 

            error.code.should.equal 'ENOENT'
            done()

    