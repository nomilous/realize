fs       = require 'fs'
program  = require 'commander'
pipeline = require 'when/pipeline'

module.exports = realize = 

    marshalArgs: (program) -> 

        program.version JSON.parse( 
            fs.readFileSync __dirname + '/../package.json'
            'utf8'
        ).version

        program.usage '[options] [realizer]'
        program.option '-p, --port  <num>      ', 'Connect to Objective at port'
        program.option '-X, --no-https         ', 'Connect insecurely', false
        program.parse process.argv

        return {
            filename: program.args[0]
            connect:  true
            https:    program.https
            port:     program.port
        }

    exitWithError: (error) ->

        process.stderr.write error.toString()
        process.exit error.errno || 100

    withError: (errno, code, message) -> 

        error       = new Error message
        error.errno = errno
        error.code  = code
        return error

    exec: -> 

        pipeline([

            (        ) -> realize.marshalArgs program
            ( params ) -> 

        ]).then(

            (resolve) ->
            realize.exitWithError
            (notify)  ->

        )
