{deferred, pipeline} = require 'also'
fs         = require 'fs'
error      = require './error'
coffee     = require 'coffee-script'

module.exports = configure = 
    
    deferred (action, params = {}) ->

        {resolve, reject, notify} = action
        {filename, connect, port, https} = params

        #
        # TODO: some of the steps done here would be more usefull
        #       after connecting to objective, 
        # 
        #       because objective may like to know why the realizer
        #       did not start (which error?)
        #

        validate = deferred ({resolve, reject}) ->
            return resolve() if filename? 
            reject error
                errno:    101
                code:    'ENOARG'
                message: 'No realizer specified. (-f <file>)'


        read = deferred ({resolve, reject}) ->
            fs.readFile filename, 'utf8', (err, content) -> 
                return reject err if err? 
                resolve content


        compile = deferred ({resolve, reject}, source) -> 
            try resolve coffee.compile source, bare: true
            catch err
                reject error
                    errno:    102
                    code:    'ENOCOMPILE'
                    message: err.toString()
                    detail:  location: err.location


        interpret = deferred ({resolve, reject}, realizer) -> 
            try resolve eval realizer
            catch err
                reject error
                    errno:    103
                    code:    'ENOEVAL'
                    message: err.toString()


        marshal = deferred ({resolve, reject}, object) -> 
            return reject error(
                errno:    104
                code:    'ENOREALIZER'
                message: 'Realizer requires title, uuid and realize function'
            ) unless (
                object? and
                object.title? and typeof object.title is 'string' and
                object.uuid? and typeof object.uuid is 'string' and
                object.realize? and typeof object.realize and 'function'
            )

            realzerFn = object.realize

            if connect
                return reject error(
                    errno:    105
                    code:    'ENOPORT'
                    message: 'Realizer requires port'
                    suggest: 'use -p nnnn or realizer.connect.port'
                ) unless port? or (
                    object.connect? and object.connect.port? 
                )

                object.connect ||= {}
                object.connect.port = port if port?
                object.connect.hostname = hostname if hostname? 
                object.connect.hostname  ||= 'localhost'
                if https then object.connect.transport = 'https' 
                else object.connect.transport ||= 'http' 
                if process.env.REALIZER_SECRET? 
                    object.connect.secret = process.env.REALIZER_SECRET
                else
                    object.connect.secret ?= ''
            
            delete object.realize
            resolve opts: object, realizerFn: realzerFn

        pipeline([

            (        ) -> validate()
            (        ) -> read()
            ( source ) -> compile   source
            (realizer) -> interpret realizer
            ( object ) -> marshal   object

        ]).then resolve, reject, notify
