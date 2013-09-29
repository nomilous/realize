{deferred, pipeline} = require 'also'
fs         = require 'fs'
error      = require './error'

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


        load = deferred ({resolve, reject}) ->
            fs.readFile filename, 'utf8', (err, content) -> 
                if err? then return reject err
                resolve content



        pipeline([

            (   ) -> validate()
            (   ) -> load()
            (raw) -> console.log raw

        ]).then resolve, reject, notify
