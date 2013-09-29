run = require '../../lib/realizer/run'

describe 'run', -> 

    it 'is deferred', (done) -> 

        run().then.should.be.an.instanceof Function
        done()
