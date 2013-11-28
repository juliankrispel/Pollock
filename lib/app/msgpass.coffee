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
            @registerChannel(channel, { value: undefined })

        # initialize subscriber if not existent
        if not @_subscribers.hasOwnProperty(subscriber)
            @_subscribers[subscriber] = { _channels : {} }

        # subscribe
        if(typeof callback != 'function')
            console.log('[PublishSubscriber ERR]: `typeof` callback != function')
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
      # Create a channel if it doesn't exist
      # for future subscribers
      if not @_channels.hasOwnProperty(channel)
        @registerChannel(channel, { value: value })

      # notify only if value actually changes
      if @_channels[channel].value != value
        @_channels[channel].value = value
        # notify all _subscribers of a channel but the callee
        for listener, callback of @_channels[channel]._subscribers
            callback(value) if listener != subscriber
      @

    publishAll: (obj)->
      # Cancel operation if object doesn't have a 
      # public declaration
      if obj['public'] and typeof obj['public'] == 'object'
        # To register everything in public, loop
        # through the declaration
        for publicVar, memberVar of obj['public']
          paths = memberVar.split('.')
          lastPath = paths.pop()

          memberVar = useArrayAsDirectory(obj, paths)

          @publish(memberVar, lastPath, publicVar)

    getAllChannels: () ->
      chanlist = []
      for name, channel of @_channels
        chanlist.push(name) #if channel.hasOwnProperty('published')
      chanlist

    publish: (obj, property, channel) ->
        PS = @

        if obj.hasOwnProperty(property)
            defaultValue = obj[property]

        subName = obj.constructor.name + "_" + property

        Object.defineProperty(obj, property, {
            get: () -> PS.getValue(channel,subName)
            set: (val) -> PS.setValue(channel,subName,val)
        })

        isNewChannel = not @_channels.hasOwnProperty(channel) or @_channels[channel].value == undefined

        @subscribe(channel, subName,()->)
        @_channels[channel].published = true
        if defaultValue isnt undefined and isNewChannel
          @setValue(channel, subName, defaultValue)
        subName
