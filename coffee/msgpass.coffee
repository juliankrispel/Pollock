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
    @

    registerChannel: (name, metadata) ->
        if @channels.hasOwnProperty(name)
            console.error("[PublishSubscriber ERR]: channel " + name + " already exists.")
            return @
        @channels[name] = metadata;
        @channels[name].subscribers = {};
    @


    subscribe: (channel, subscriber, callback) ->
        if !@channels.hasOwnProperty(channel)
            console.error("[PublishSubscriber ERR]: " + subscriber + " tried to subscribe to channel " + channel + ", which doesn't exist.")
            return @

        # initialize subscriber if not existent
        if !@subscribers.hasOwnProperty(subscriber)
            @subscribers[subscriber] = { channels : {} }

        # subscribe
        @channels[channel].subscribers[subscriber] = callback;
        @subscribers[subscriber].channels[channel] = @channels[channel];
    @

    unsubscribe: (channel, subscriber) ->
       if not subscriber.hasOwnProperty(subscriber)
           console.error("[PublishSubscriber ERR]: " + subscriber + " tried to unsubscribe from " + channel + ", but i don't know him.")
           return @

       if not channels.hasOwnProperty(channel)
           console.error("[PublishSubscriber ERR]: " + subscriber + " tried to unsubscribe from " + channel + ", which doesn't exist.")
           return @

        @subscribers[subscriber].channels[channel] = null;
        @channels[channel].subscribers[subscriber] = null;
    @

    getValue: (channel, subscriber) ->
       @channels[channel].value

    setValue: (channel, subscriber, value) =>
        @channels[channel].value = value

        # notify
        #@subscribers['A'].channels['FOO'].
        for listener, callback of @channels[channel].subscribers
            callback() if listener != subscriber 
    @
