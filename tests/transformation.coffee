describe '2D Transformation test', ->

    #Setup and teardown Object
    beforeEach ->

    afterEach ->

    it 'Creates 2D Transformation', ->
        m = new Mat3().createTranslation(5,5)
        expect(typeof m).toBe 'object'

    it 'translates point', ->
        T = new Mat3().translate(5,5)
        result = T.multVec([1,2,1])
        expect(result[0]).toBe(5+1)
        expect(result[1]).toBe(5+2)

    it 'scales point', ->
        T = new Mat3().scale(1,1,2,3)
        result = T.multVec([3,4,1])
        expect(result[0]).toBe((3-1)*2+1)
        expect(result[1]).toBe((4-1)*2+1)

    it 'rotates point', ->
        T = new Mat3().
        result = T.multVec([1,2,1])
        expect(result[0]).toBe(5+1)
        expect(result[1]).toBe(5+2)

