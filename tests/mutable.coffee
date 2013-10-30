describe 'test Mutables', ->
    mc = {}

    beforeEach ->
        mc = new MutableController

    afterEach ->
        mc = {}

    it 'successfully instantiates MutableController', ->
        expect(typeof mc).toBe 'object'

    it 'registers a Mutable with a RandomIntervalNumber and update Mutable via MutableController', ->
        m = new Mutable
          value: new RandomIntervalNumber 0, 1

        m.cycle.setValue(3)
        mc.registerMutable(m)

        expect(m.valueOf()).toBeLessThan 1.01
        expect(m.valueOf()).toBeGreaterThan -0.01

        value = m.valueOf()
        mc.update()

        expect(m.valueOf()).not.toEqual value

    it 'registers a Mutable with a RandomPosition and update Mutable via MutableController', ->
        m = new Mutable
            value: new RandomPosition 1, 20, 10, 30
            cycle: 
                min: 1
                max: 4
        mc.registerMutable(m)

        value = m.valueOf()

        expect(value.x).toBeGreaterThan 0.99
        expect(value.x).toBeLessThan 20.01
        expect(value.y).toBeGreaterThan 9.99
        expect(value.y).toBeLessThan 30.01

        mc.update()
        newValue = m.valueOf()

        expect(value.x).not.toEqual newValue.x
        expect(value.y).not.toEqual newValue.y

