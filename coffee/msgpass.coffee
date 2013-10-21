#
# simple publish/subscriber message passing
# a PublishSubscriber instance contains a set of unique channels
# and a list of subscribers. 
# - each subscriber can subscribe only  once to a channel. 
# - each subscriber can set a callback function per channel

class window.PublishSubscriber 

    constructor: () ->
        @channels = {};
        @subscribers = {};

    registerChannel: (name, metadata) ->
        if @channels.hasOwnProperty(name)
            console.error("[PublishSubscriber ERR]: channel " + name + " already exists.")
            return @
        @channels[name] = metadata;
        @channels[name].subscribers = {};
        @

    unregisterChannel: (name) ->
        if @channels.hasOwnProperty(name)
            delete @channels[name];
        else
            console.error("[PublishSubscriber ERR]: tried to unregister channel " + name + ", which is unknown to me.")
        @

    getChannel: (name) ->
        if @channels.hasOwnProperty(name)
            return @channels[name]
        null

    subscribe: (channel, subscriber, callback) ->
        if not @channels.hasOwnProperty(channel)
            #console.error("[PublishSubscriber ERR]: " + subscriber + " tried to subscribe to channel " + channel + ", which doesn't exist.")
            @registerChannel(channel, { value: "" })

        # initialize subscriber if not existent
        if not @subscribers.hasOwnProperty(subscriber)
            @subscribers[subscriber] = { channels : {} }

        # subscribe
        @channels[channel].subscribers[subscriber] = callback;
        @subscribers[subscriber].channels[channel] = @channels[channel];
        @

    unsubscribe: (channel, subscriber) ->
       if not @subscribers.hasOwnProperty(subscriber)
           console.error("[PublishSubscriber ERR]: " + subscriber + " tried to unsubscribe from " + channel + ", but i don't know him.")
           return @

       if not @channels.hasOwnProperty(channel)
           console.error("[PublishSubscriber ERR]: " + subscriber + " tried to unsubscribe from " + channel + ", which doesn't exist.")
           return @

        delete @subscribers[subscriber].channels[channel];
        delete @channels[channel].subscribers[subscriber];
        @

    getValue: (channel, subscriber) ->
        if @channels.hasOwnProperty(channel)
            return @channels[channel].value
        console.error("[PublishSubscriber ERR]: " + subscriber + " tried to read from non-existant channel " + channel)
        null

    setValue: (channel, subscriber, value) =>
        if not @channels.hasOwnProperty(channel)
            @registerChannel(channel, { value: value })      
        # notify only if value actually changes
        if  @channels[channel].value != value       
            @channels[channel].value = value
            # notify all subscribers of a channel but the callee
            for listener, callback of @channels[channel].subscribers
                callback() if listener != subscriber 
        @

    makePublic: (obj, property, channel) ->
        PS = this
        Object.defineProperty(obj, property, {
            get: () -> PS.getValue(channel,obj.constructor.name)
            set: (val) -> PS.setValue(channel,obj.constructor.name,val)          
        })
        @subscribe(channel, obj.constructor.name, {})
        @        
