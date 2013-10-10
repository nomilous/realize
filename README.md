`npm install -g realize` 0.0.3 [license](./license)

realize
=======

A realization [phrase](https://github.com/nomilous/phrase) runner.<br />

### example

**the realizer file** `jack_and_jill.coffee`

```coffee

title: 'Fetch a Pail of Water'
uuid:  '8a618c00-31e4-11e3-94c8-11feca0da255'
realize: (roll) -> 

    before each: (done) -> 

        #
        # integrated middleware message bus
        # 

        @notice.person 'Jill', (err, @Jill) => done()
        


    roll 'up the hill', (to) -> 

        to 'fetch a pail of water', (done) -> 

            #
            # * this is a leaf `phrase` because it has `done` at arg
            # * `this`, a.k.a @ (context) is shared across all hooks and phrases
            # 

            pipeline([

                => @notice.event 'fall down'
                => @notice.event 'break crown'

            ]).then => @Jill.tumbleAfter -> done()


```

**to run it** `realize -xf jack_and_jill.coffee` <br />



### pending functionality

```coffee

title: 'Fetch a Pail of Water'
uuid:  '8a618c00-31e4-11e3-94c8-11feca0da255'

realize: (roll) -> 

    roll 'up the hill', (to, jill) -> 

        #
        # dynamically inject jill as node_module
        # 

```
<br />
See also: [objective](https://github.com/nomilous/objective)

