`npm install -g realize` 0.0.3 [license](./license)

realize
=======

A realization [phrase](https://github.com/nomilous/phrase) runner.<br />

### example

**the realizer file** `realizer.coffee`

```coffee

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

### pending functionality

```coffee

title: 'Another Realizer'
uuid:  'universally unique identifier too'

realize: (step) -> 

    step 'get records', (done, https) -> 

        #
        # use injected node module (https) to get stuff
        # 

        @records = ['array']
        done()

    step 'do some thing with them', (done, LocalModule) -> 

        #
        # CamelCase injections are loaded from local modules 
        # 
        #    ie. 'lib/local_module'
        #

        LocalModule.process record for record in @records
        done()


```
<br />
See also: [objective](https://github.com/nomilous/objective)

