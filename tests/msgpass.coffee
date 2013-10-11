describe 'test publish/subscribe mechanism', ->
    ps = {}

    #Setup and teardown Object
    beforeEach ->
        ps = new PublishSubscriber

    afterEach ->
        ps = {}

    it 'instantiates PublishSubscriber', ->
        expect(typeof ps).toBe 'object'

    it 'registers channel', ->
        ps.registerChannel 'FOO', value: 'bar'
        expect(ps.getValue 'FOO', '').toBe 'bar'

    it 'subscribes to change event on channel', ->
        channelBIsNotified = false
        channelAIsNotified = false

        ps.registerChannel 'FOO', value: 'bar'

        ps.subscribe 'FOO', 'A', -> channelAIsNotified = true
        ps.subscribe 'FOO', 'B', -> channelBIsNotified = true

        ps.setValue('FOO', 'A', 'BAZ')
        ps.setValue('FOO', 'B', 'FAZ')

        waits 200

        runs ->
            expect(channelAIsNotified).toBe true
            expect(channelBIsNotified).toBe true
