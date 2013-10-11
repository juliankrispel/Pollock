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
        isNotified = false

        ps.registerChannel 'FOO', value: 'bar'
        ps.subscribe 'FOO', 'A', ->
            isNotified = true

        ps.setValue('FOO', 'A', 'BAZ')

        waits 200

        runs ->
            expect(isNotified).toBe true
