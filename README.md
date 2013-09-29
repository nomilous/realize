`npm install -g realize`

#### Version 0.0.1 (unstable)

realize
=======

A realization [phrase](https://github.com/nomilous/phrase) runner.<br />

### example

**the realizer file** `realizer.coffee`

```coffee

title: 'Generic'
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

        @count++

        #
        # @ (this) - References to the running `job` context
        #            in all `hooks` and `phrases`.
        #


    step 'A', (done) -> @arbitraryResult = 42; done()
    step 'B', (done) -> done()
    step 'C', (done) -> 

        #
        # this is a `phrase`, it has access to 
        # the message bus
        #

        @notice.event 'RUNNING step C', count: @count
        done()


```

**to run it** `realize -xf realizer.coffee` <br />
<br />
See also: [objective](https://github.com/nomilous/objective)

