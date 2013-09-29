#
# ../bin/realize -xf generic.coffee
#

title: 'Generic Realizer'
uuid:  'universally unique identifier'

realize: (step) -> 

    before all: ->

        @count = 0
        @notice.use (msg, next) -> 

            #
            # integrated middleware message bus
            # 

            if msg.event.match /^run::/
                console.log msg.event, msg.progress
                return next()
            
            console.log msg.event, msg
            next()
            

    before each: -> 

        #
        # @ (this) - References to the running `job` context
        #            in all `hooks` and `phrases`.
        #

        @count++


    step 'A', (done) -> @arbitraryResult = 42; done()
    step 'B', (done) -> done()
    step 'C', (done) -> 

        #
        # this is a `phrase`, it has access to 
        # the message bus
        #

        @notice.event 'RUNNING step C', count: @count
        done()
