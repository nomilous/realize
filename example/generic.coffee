#
# ../bin/realize -xf generic.coffee
#

title: 'Generic'
uuid:  'universally unique identifier'
realize: (step) -> 

    step 'one', (end) -> 


        console.log run: 1
        end()
