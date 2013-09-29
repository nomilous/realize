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
                code:    'ENOREALIZER'
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

            console.log object

        pipeline([

            (        ) -> validate()
            (        ) -> read()
            ( source ) -> compile   source
            (realizer) -> interpret realizer
            ( object ) -> marshal   object

        ]).then resolve, reject, notify
