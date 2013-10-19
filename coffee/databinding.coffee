# Example Schema
# schema = [
#     {
#         "type": "dropdown"
#         "id": "this_dropdown"
#     }
# ]

class FormElement
    constructor: (widget, selector) ->

class DataBinder extends Base
    defaults:
        # By default, DataBinder is using our
        # publish/subscribe mechanism, these are 
        # defaults however and can be overridden by
        # passing an init and an onChange function
        # into the constructor
        init: () ->
            unless window.ps
                window.ps = new PublishSubscriber
        onChange: (widget, newValue)->
            if widget.channel
                window.ps.setValue newValue, widget.channel

    buildSchema: (schema) ->
        for item in schema
            el = new FormElement item.widget, item.selector, @onchange

            if ps && item.widget['channel']
                window.ps.registerChannel item.widget.channel
        null

binder = new FormBinder

