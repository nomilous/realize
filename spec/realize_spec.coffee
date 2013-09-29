realize = require 'realize'

describe 'realize', -> 

    beforeEach -> 
        @marshal = realize.marshal
        @load    = realize.load
        @connect = realize.connect
        @run     = realize.run
        @exit    = realize.exit 

    afterEach -> 
        realize.marshal = @marshal
        realize.load    = @load
        realize.connect = @connect
        realize.run     = @run
        realize.exit    = @exit


    context 'exec()', -> 

        it 'pipelines the realizer initialization steps', (done) -> 

            realize.marshal = ->    
                return 'PARAMETERS'

            realize.load = (parameters) -> 
                parameters.should.equal 'PARAMETERS'
                return 'REALIZER'

            realize.connect = (realizer) -> 
                realizer.should.equal 'REALIZER'
                return 'CONTROLS'

            realize.run = (controls) -> 
                controls.should.equal 'CONTROLS'
                throw new realize.error 400, 'CODE', 'Error message'

            realize.exit = (error) -> 
                error.should.match /Error message/
                error.errno.should.equal 400
                error.code.should.equal 'CODE'
                done()

            realize.exec()

