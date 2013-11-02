#
# simple publish/subscriber message passing
# a PublishSubscriber instance contains a set of unique _channels
# and a list of _subscribers. 
# - each subscriber can subscribe only  once to a channel. 
# - each subscriber can set a callback function per channel

class window.PublishSubscriber 

    constructor: () ->
        @_channels = {};
        @_subscribers = {};

    registerChannel: (name, metadata) ->
        if @_channels.hasOwnProperty(name)
            console.error("[PublishSubscriber ERR]: channel " + name + " already exists.")
            return @
        @_channels[name] = metadata;
        @_channels[name]._subscribers = {};
        @

    unregisterChannel: (name) ->
        if @_channels.hasOwnProperty(name)
            delete @_channels[name];
        else
            console.error("[PublishSubscriber ERR]: tried to unregister channel " + name + ", which is unknown to me.")
        @

    getChannel: (name) ->
        if @_channels.hasOwnProperty(name)
            return @_channels[name]
        null

    subscribe: (channel, subscriber, callback) ->
        if not @_channels.hasOwnProperty(channel)
            #console.error("[PublishSubscriber ERR]: " + subscriber + " tried to subscribe to channel " + channel + ", which doesn't exist.")
            @registerChannel(channel, { value: "" })

        # initialize subscriber if not existent
        if not @_subscribers.hasOwnProperty(subscriber)
            @_subscribers[subscriber] = { _channels : {} }

        # subscribe
        try 
            callback()
        catch error
            console.log('[PublishSubscriber ERR]: ' + subscriber + " tried to register an invalid callback.")
            callback = ->
        @_channels[channel]._subscribers[subscriber] = callback;
        @_subscribers[subscriber]._channels[channel] = @_channels[channel];
        @

    unsubscribe: (channel, subscriber) ->
       if not @_subscribers.hasOwnProperty(subscriber)
           console.error("[PublishSubscriber ERR]: " + subscriber + " tried to unsubscribe from " + channel + ", but i don't know him.")
           return @

       if not @_channels.hasOwnProperty(channel)
           console.error("[PublishSubscriber ERR]: " + subscriber + " tried to unsubscribe from " + channel + ", which doesn't exist.")
           return @

        delete @_subscribers[subscriber]._channels[channel];
        delete @_channels[channel]._subscribers[subscriber];
        @

    getValue: (channel, subscriber) ->
        if @_channels.hasOwnProperty(channel)
            return @_channels[channel].value
        console.error("[PublishSubscriber ERR]: " + subscriber + " tried to read from non-existant channel " + channel)
        null

    setValue: (channel, subscriber, value) =>
        if not @_channels.hasOwnProperty(channel)
            @registerChannel(channel, { value: value })

        # notify only if value actually changes
        if  @_channels[channel].value != value
            @_channels[channel].value = value
            # notify all _subscribers of a channel but the callee
            for listener, callback of @_channels[channel]._subscribers
                callback() if listener != subscriber
        @

    publishSubscribe: (obj)->
        # Cancel operation if object doesn't have a 
        # public declaration
        if obj['public']
            # To register everything in public, loop
            # through the declaration
            for param, value of obj['public']
                # Because it can be declared as a string
                # 'brush.size.value': 'brushMinSize' we have
                # to split up the path and loop over it 
                # to find the variable.
                publicMember = obj
                paths = param.split('.')
                lastPath = paths.pop()
                # Don't loop over an array smaller than 1
                if paths.length > 1
                    # don't loop over last item in array which needs
                    # to be passed on to makePublic
                    for path in paths 
                        # Catch invalid variable names
                        if(!publicMember[path])
                            throw new Error('object ' + publicMember + ' has no member called ' + path)
                        publicMember = publicMember[path]

                # bind object member to PublishSubscriber with makePublic
                @makePublic(publicMember, lastPath, value)

    makePublic: (obj, property, channel) ->
        PS = @

        if obj.hasOwnProperty(property)
            defaultValue = obj[property]
        Object.defineProperty(obj, property, {
            get: () -> PS.getValue(channel,obj.constructor.name)
            set: (val) -> PS.setValue(channel,obj.constructor.name,val)
        })

        isNewChannel = not @_channels.hasOwnProperty(channel)

        @subscribe(channel, obj.constructor.name,()->)
        if defaultValue != undefined and isNewChannel
           @setValue(channel, obj.constructor.name, defaultValue)
        @
