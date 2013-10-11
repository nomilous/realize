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

    before all: (done) -> 

        #
        # integrated middleware message bus
        # 

        @notice.use

            #
            # TODO: problem here for an uplinked realizer,
            # 
            #       before all runs ahead of each job run
            #       as requested by the remote objective
            # 
            #       this registraion will error on the second
            #       run with: 
            # 
            #       notice: middleware 'EavesDropper' already exists, use the force()
            #       
            #       perhaps @notice.force() is an appropriate solution 
            # 

            title: 'EavesDropper',
            (next, capsule) -> 
            
                type = capsule._type
                console.log "[#{type}] #{capsule[type]}"
                next()

        @notice.use

            title: 'EavesDropper', ->



        @notice.fetch 'Jill', (err, @Jill) => done()
        @fter = 500

    

    roll 'up the hill', (to) -> 

        to 'fetch a pail of water', (done, also) -> 

            @notice.alert 'fell down'
            @notice.alert 'broke crown'
            done()

            # also.pipeline([

            #     => @notice.event 'fell down'
            #     => @notice.event 'broke crown'

            # ]).then => 

            #     setTimeout @Jill.tumble, @fter
            #     done()