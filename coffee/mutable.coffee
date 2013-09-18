# alterable properties
# mode is one of
# - discrete : 
class Mutable

  constructor: (min, max, val) ->
     @min = min
     @max = max
     @value = val
     @current = val
     @target  = val
     @ctr = 1
     @cycleLength = 3
     @cycleMin = 5
     @cycleMax = 20
     @mode = 'discrete'
     @cycle = 'regular'

  update : ->
    switch(@mode)
      when "discrete" 
        --@ctr
        if @ctr == 0
          @newValue()
          @ctr = @cycleLength
          @current = @target
      when "linp" 
        --@ctr
        if @ctr == 0
          @newValue()
          @ctr = @cycleLength
        @current = @value + (@target-@value)*(@ctr/@cycleLength);
    @

  newValue : ->
    @value=@target
    @target=getRandom(@min,@max)

  newCycle : ->
    switch(cycle)
      when "irregular"
        @cycleLength = getRandomInt(@cycleMin,@cycleMax);

    @ctr = @cycleLength

  valueOf : ->
    @current

class MutableInteger extends Mutable
  valueOf : ->
    Math.round(@current)

# MutableController is global
class MutableController
   mutables : []

   registerMutable: ( m ) ->
      @mutables.push(m)

   removeMutable:   ( m ) ->
      i = @mutables.indexOf(m)
      @mutables.splice(i, 1) if i != -1

   update : ->
      m.update() for m in @mutables


class MutableTest
  constructor: ->

  runTest: ->
    @mc = new MutableController()
    @A = new Mutable(1,10,5)
    @A.cycleLength = 3
    @B = new MutableInteger(1,10,5)
    @B.cycleLength = 4
    @mc.registerMutable(@A)
    @mc.registerMutable(@B)

    for i in [1..10]
      @mc.update()
      console.log("A:" + @A.valueOf() + " B:" + @B.valueOf())

window.MutableTest = new MutableTest()