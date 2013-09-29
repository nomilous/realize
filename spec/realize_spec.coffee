realize = require 'realize'

describe 'realize', -> 

    beforeEach -> 
        @marshal = realize.marshal
        @load    = realize.load
        @connect = realize.connect
        @run     = realize.run 

    afterEach -> 
        realize.marshal = @marshal
        realize.load    = @load
        realize.connect = @connect
        realize.run     = @run


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

            realize.exec().then done


