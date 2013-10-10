`npm install -g realize` 0.0.3 [license](./license)

realize
=======

An actualizer. <br />

### example

**the realizer file** `jack_and_jill.coffee`

```coffee

title: 'Fetch a Pail of Water'
uuid:  '8a618c00-31e4-11e3-94c8-11feca0da255'
realize: (roll) -> 

    before all: (done) -> 

        #
        # integrated middleware message bus
        # 

        @notice.find 'Jill', (err, @Jill) => done()
        @fter = 500
        


    roll 'up the hill', (to) -> 

        to 'fetch a pail of water', (done, also) -> 
                                            #
                                            # todo: node module injection
                                            #

            also.pipeline([

                => @notice.alert 'fell down'
                => @notice.alert 'broke crown'

            ]).then => 

                setTimeout @Jill.tumbling, @fter


```

**to run it** `realize -xf jack_and_jill.coffee` <br />
<br />
See also: [objective](https://github.com/nomilous/objective)

