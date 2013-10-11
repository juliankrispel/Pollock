describe 'test publish/subscribe mechanism', ->
    ps = {}

    #Setup and teardown Object
    beforeEach ->
        ps = new PublishSubscriber

    afterEach ->
        ps = {}

    it 'PublishSubscriber correctly instantiates', ->
        expect(typeof ps).toBe 'object'

    it 'register channel', ->
        ps.registerChannel 'FOO', value: 'bar'
        expect(ps.getValue 'FOO', '').toBe 'bar'

    it 'subscribe to channel change on channel', ->
        isNotified = false

        ps.registerChannel 'FOO', value: 'bar'
        ps.subscribe 'FOO', 'A', ->
            isNotified = true

        ps.setValue('FOO', 'A', 'BAZ')
        console.log ps.getValue 'FOO', ''
        waits 200

        runs ->
            expect(isNotified).toBe true
