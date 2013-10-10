realize = require '../lib/realize'
{error} = require '../lib/realizer'

describe 'realize', -> 

    beforeEach -> 
        @marshal   = realize.marshal
        @configure = realize.load
        @connect   = realize.connect
        @run       = realize.run
        @exit      = realize.exit 

    afterEach -> 
        realize.marshal   = @marshal
        realize.configure = @configure
        realize.connect   = @connect
        realize.run       = @run
        realize.exit      = @exit


    context 'exec()', -> 

        it 'pipelines the realizer initialization steps', (done) -> 

            realize.marshal = ->    
                return 'PARAMETERS'

            realize.configure = (parameters) -> 
                parameters.should.equal 'PARAMETERS'
                return 'REALIZER'

            realize.connect = (realizer) -> 
                realizer.should.equal 'REALIZER'
                return 'CONTROLS'

            realize.run = (controls) -> 
                controls.should.equal 'CONTROLS'
                throw new error 
                    errno:    400
                    code:    'CODE'
                    message: 'Error message'
                    detail:   
                        other: 'stuff'

            realize.exit = (error) -> 
                error.should.match /Error message/
                error.errno.should.equal 400
                error.code.should.equal 'CODE'
                error.detail.should.eql other: 'stuff'
                done()

            realize.exec()

