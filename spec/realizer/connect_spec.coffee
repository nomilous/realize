connect = require '../../lib/realizer/connect'

describe 'connect', -> 

    it 'is deferred', (done) -> 

        connect({}).then.should.be.an.instanceof Function
        done()
