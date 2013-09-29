fs          = require 'fs'
program     = require 'commander'
{pipeline}  = require 'also'

{configure, connect, run} = require './realizer'

module.exports = realize = 

    exit: (error) ->

        process.exit 0 unless error?
        process.stderr.write error.toString()
        process.exit error.errno || 100

    marshal: (program) -> 

        program.version JSON.parse( 
            fs.readFileSync __dirname + '/../package.json'
            'utf8'
        ).version

        program.usage '[options]'

        program.option '-f, --file <filename>  ', 'Run realizer from file.'
        program.option '-x, --no-connect       ', 'Run without connection to Objective.', false
        program.option '-p, --port <num>       ', 'Connect to Objective at port.'
        program.option '-X, --no-https         ', 'Connect insecurely.', false

        program.parse process.argv

        return {
            filename: program.file
            connect:  program.connect
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


module.exports.configure = configure
