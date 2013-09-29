configure = require '../../lib/realizer/configure'

describe 'configure', -> 

    it 'is deferred', (done) -> 

        #
        # this means that the config step 
        # can breakout asynchronously
        # 

        configure().then.should.be.an.instanceof Function
        done()
