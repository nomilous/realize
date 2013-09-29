fs       = require 'fs'
program  = require 'commander'
pipeline = require 'when/pipeline'
{configure, connect, run} = require './realizer'

module.exports = realize = 

    exit: (error) ->

        process.exit 0 unless error?
        process.stderr.write error.toString()
        process.exit error.errno || 100

    error: (errno, code, message) -> 

        error       = new Error message
        error.errno = errno
        error.code  = code
        return error

    marshal: (program) -> 

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

    configure: configure
    connect: connect
    run: run
    
    exec: -> 

        pipeline([

            (        ) -> realize.marshal   program
            ( params ) -> realize.configure params
            (realizer) -> realize.connect   realizer
            (controls) -> realize.run       controls

        ]).then(

            (resolve) ->
            realize.exit
            (notify)  ->

        )
