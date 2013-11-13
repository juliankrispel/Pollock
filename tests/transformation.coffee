describe '2D Transformation test', ->

    #Setup and teardown Object
    beforeEach ->

    afterEach ->

    it 'Creates 2D Transformation', ->
        m = new Mat3().createTranslation(5,5)
        expect(typeof m).toBe 'object'

    it 'translate point', ->
        T = new Mat3().createTranslation(5,5)
        result = T.multVec([1,2,1])
        expect(result[0]).toBe(5+1)
        expect(result[1]).toBe(5+2)
