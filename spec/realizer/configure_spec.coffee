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

            error.errno.should.equal 101
            error.message.should.match /No realizer specified/
            error.code.should.equal 'ENOARG'
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
            error.errno.should.equal 102
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
            error.errno.should.equal 103
            done()

    it 'rejects on missing title, uuid, realize()', (done) -> 

        fs.readFile = (filename, encoding, callback) ->
            if filename == 'missing.coffee'
                callback null, """
                    titel: 'Misspelled'
                """
        configure 
        
            filename: 'missing.coffee'

        .then (->), (error) -> 

            error.message.should.equal 'Realizer requires title, uuid and realize function'
            error.code.should.equal 'ENOREALIZER'
            error.errno.should.equal 104
            done()


    it 'rejects on missing port if connect is enabled', (done) -> 

        fs.readFile = (filename, encoding, callback) ->
            if filename == 'missing.coffee'
                callback null, """
                    title: 'Title'
                    uuid:  '1234234213123'
                    realize: ->
                """

        configure 

            filename:  'missing.coffee'
            connect: true

        .then (->), (error) -> 

            error.code.should.equal 'ENOPORT'
            error.errno.should.equal 105
            error.message.should.match /Realizer requires port/
            done()


    it 'will override from -p', (done) -> 

        fs.readFile = (filename, encoding, callback) ->
            if filename == 'missing.coffee'
                callback null, """
                    title: 'Title'
                    uuid:  '1234234213123'
                    connect: 
                        port: 10101
                    realize: ->
                """

        configure 

            filename:  'missing.coffee'
            connect: true
            port:    20202
            https:   true

        .then ({opts}) -> 

            opts.connect.url.should.equal 'https://localhost:20202'
            done()


    it 'will override secret from environment variable', (done) -> 

        process.env.NODE_SECRET = '∑'

        fs.readFile = (filename, encoding, callback) ->
            if filename == 'missing.coffee'
                callback null, """
                    title: 'Title'
                    uuid:  '1234234213123'
                    connect: 
                        port:   10101
                        secret: 'x'
                    realize: ->
                """

        configure 

            filename:  'missing.coffee'
            connect: true
            port:    20202
            https:   true

        .then ({opts}) -> 

            opts.connect.secret.should.equal '∑'
            done()

    it 'resolves with opts and realizerFn', (done) -> 

        delete process.env.NODE_SECRET

        fs.readFile = (filename, encoding, callback) ->
            if filename == 'missing.coffee'
                callback null, """
                    title: 'Title'
                    uuid:  '1234234213123'
                    connect: 
                        secret:    'x'
                        adaptor:   'socket.io'
                        url:       'https://host.name:10101'

                    realize: -> 'okgood'
                """

        configure 

            filename:  'missing.coffee'
            connect: true

        .then ({opts, realizerFn}) -> 

            opts.should.eql 

                title: 'Title'
                uuid: '1234234213123'
                connect: 
                    secret:    'x'
                    adaptor:   'socket.io'
                    url:       'https://host.name:10101'

            realizerFn().should.equal 'okgood'

            done()

