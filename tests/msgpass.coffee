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

    it 'unregisters channel', ->
        ps.registerChannel 'FOO', value: 'bar'
        expect(ps.getChannel('FOO')).toNotBe null
        ps.unregisterChannel 'FOO'
        expect(ps.getChannel('FOO')).toBe null

    it 'changes channel value', ->
        ps.registerChannel 'FOO', value: 'BAR'
        ps.setValue 'FOO', 'JOHN', 'BAZ'
        expect(ps.getValue 'FOO', 'JOHN').toBe 'BAZ'

    it 'notify on channel change', ->
        isNotified = false
        ps.registerChannel 'FOO', value: 'bar'
        ps.subscribe 'FOO', 'ME', -> isNotified = true
        ps.setValue 'FOO', '', 'baz'
        expect(isNotified).toBe true

    it 'multiple subscribers', ->
        channelAIsNotified = false
        channelBIsNotified = false

        ps.registerChannel 'FOO', value: 'bar'

        ps.subscribe 'FOO', 'A', -> channelAIsNotified = true
        ps.subscribe 'FOO', 'B', -> channelBIsNotified = true

        ps.setValue('FOO', '', 'BAZ')

        expect(channelAIsNotified).toBe true
        expect(channelBIsNotified).toBe true

    it 'does not get self-notified on change', ->
        channelAIsNotified = false
        channelBIsNotified = false

        ps.registerChannel 'FOO', value: 'bar'

        ps.subscribe 'FOO', 'A', -> channelAIsNotified = true
        ps.subscribe 'FOO', 'B', -> channelBIsNotified = true

        ps.setValue('FOO', 'A', 'BAZ')

        expect(channelAIsNotified).toBe false
        expect(channelBIsNotified).toBe true

    it 'unregister channel', ->

        notifyCount = 0    
        ps.registerChannel 'FOO', value: 'bar'
        ps.subscribe 'FOO', 'ITSME', -> notifyCount++

        ps.setValue('FOO', '', 'baz')
        expect(notifyCount).toBe 1
        ps.setValue('FOO', '', 'barr')
        expect(notifyCount).toBe 2

        ps.unsubscribe 'FOO', 'ITSME'
        ps.setValue('FOO', '', 'bla')
        expect(notifyCount).toBe 2
