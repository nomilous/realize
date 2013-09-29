{deferred, pipeline} = require 'also'
fs         = require 'fs'
error      = require './error'
coffee     = require 'coffee-script'

module.exports = configure = 
    
    deferred (action, params = {}) ->

        {resolve, reject, notify} = action
        {filename} = params

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

            reject error(

                errno:   104
                code:    'ENOREALIZER'
                message: 'Realizer requires title, uuid and realize function'


            ) unless (

                object? and 
                object.title? and typeof object.title is 'string' and
                object.uuid? and typeof object.uuid is 'string' and
                object.realize? and typeof object.realize is 'function'
            )

            # unless typeof realizer.realize is 'function'
            #     return reject error
            #         errno:    103
            #         code:    'ENOFN'
            #         message: 'Realizer missing realize()'



        pipeline([

            (        ) -> validate()
            (        ) -> read()
            ( source ) -> compile   source
            (realizer) -> interpret realizer
            ( object ) -> marshal   object

        ]).then resolve, reject, notify
