PS = new PublishSubscriber
# Base Class
class Base
  PS: PS

  constructor: () ->
    mixin = {}
    initArgs = []

    isFirst = true
    for arg in arguments
        # If the first argument is an object
        # use it to extend this new Instance
        if typeof arg == 'object' && isFirst
            mixin = arg
        # Otherwise add it to an array that we'll
        # pass to the objects init method 
        else
            initArgs.push arg
        isFirst = false

    _(@).extend _(@defaults).clone(), mixin

    # If this class has an init method it will
    # it will be called with initArgs
    if(@['init'])
        @init.apply(@, initArgs)

    # publishAll all variables defined in
    # class member 'public'. Public class variables 
    # are declared like this
    #
    # class ExampleClass
    #   name: 'I\'m an Example Class'
    #   public: 
    #     'name': 'exampleClassName'
    @PS.publishAll(@)

window.PS = PS
