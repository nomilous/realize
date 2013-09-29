configure = require '../../lib/realizer/configure'
fs = require 'fs'

describe 'configure', -> 

    beforeEach -> 
        @read = fs.readFile

    afterEach -> 
        fs.readFile = @read


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


    it 'compiles', (done) -> 

        fs.readFile = (filename, encoding, callback) ->

            if filename == 'missing.coffee'

                callback null, """

                    ok = false
                    test =

                """

        configure 

            filename: 'missing.coffee'

        .then (->), (error) -> 

            error.message.should.equal 'SyntaxError: unexpected end of input'
            error.code.should.equal 'ENOCOMPILE'
            error.errno.should.equal 10002
            error.detail.should.eql 
                location: 
                    first_line: 2
                    first_column: 6
                    last_line: 2
                    last_column: 6
            
            done()

    it 'evals', (done) -> 

        fs.readFile = (filename, encoding, callback) ->

            if filename == 'missing.coffee'

                callback null, """

                    ok: false
                    test: 1
                    missing()

                """

        configure 
        
            filename: 'missing.coffee'

        .then (->), (error) -> 

            error.message.should.equal 'ReferenceError: missing is not defined'
            error.code.should.equal 'ENOEVAL'
            error.errno.should.equal 10003
            done()
