#
# ../bin/realize -xf generic.coffee
#

title: 'Fetch a Pail of Water'
uuid:  '8a618c00-31e4-11e3-94c8-11feca0da255'

#
# define additional capsules this realizer will emit
# 

capsules: 
    fetch: {}
    alert: {}

realize: (roll) -> 

    before 

        all: (done) -> 

            #
            # integrated middleware message bus
            # 

            @notice.use

                title: 'EavesDropper',
                (next, capsule) -> 
                
                    type = capsule._type
                    console.log "[#{type}] #{capsule[type]}"
                    next()


            @notice.fetch 'Jill', (err, @Jill) => done()
            @fter = 500


        each: (done) -> 

            setTimeout done, @eachWaits



    roll 'up the hill', (to) -> 

        to 'fetch a pail of water', (done) -> #, also) -> 

            {sequence} = require 'also'

            sequence([

                => @notice.alert 'fell down'
                => @notice.alert 'broke crown'

            ]).then => 

                setTimeout @Jill.tumble, @fter
                done()
