#
# ../bin/realize -xf generic.coffee
#

title: 'Generic'
uuid:  'universally unique identifier'
realize: (step) -> 

    before all: ->

        @count = 0
        @notice.use (msg, next) -> 
            if msg.event.match /^run::/ 
                console.log msg.event, msg.progress
            else 
                console.log msg.event, msg
            next()

    before each: -> @count++    
    step 'A', (done) -> done()
    step 'B', (done) -> done()
    step 'C', (done) -> 

        @notice.event 'doing step C', {}
        done()
    
