{deferred, pipeline} = require 'also'
fs         = require 'fs'
error      = require './error'
coffee     = require 'coffee-script'

module.exports = configure = 
    
    deferred (action, params = {}) ->

        {resolve, reject, notify} = action
        {filename} = params


        validate = deferred ({resolve, reject}) ->
            return resolve() if filename? 
            reject error
                errno:    10001
                code:    'ENOREALIZER'
                message: 'No realizer specified. (-f <file>)'


        read = deferred ({resolve, reject}) ->
            fs.readFile filename, 'utf8', (err, content) -> 
                return reject err if err? 
                resolve content


        compile = deferred ({resolve, reject}, source) -> 
            try return resolve coffee.compile source, bare: true
            catch err
                reject error
                    errno:    10002
                    code:    'ENOCOMPILE'
                    message: err.toString()
                    detail:  location: err.location

        pipeline([

            (        ) -> validate()
            (        ) -> read()
            ( source ) -> compile source
            (realizer) -> 

                console.log realizer

        ]).then resolve, reject, notify
