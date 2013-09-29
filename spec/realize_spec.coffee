realize = require 'realize'

describe 'realize', -> 

    beforeEach -> 

        @marshal = realize.marshalArgs

    afterEach -> 

        realize.marshalArgs = @marshal

    context 'exec()', -> 

        it 'calls marshalArgs to manage commandline options', (done) -> 

            realize.marshalArgs = -> 
                done()
                then: ->

            realize.exec()


