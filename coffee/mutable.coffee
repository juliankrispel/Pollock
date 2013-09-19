# helpers
extendOBJ = (obj, mixin) ->
  obj[name] = method for name, method of mixin        
  obj

includePROT = (klass, mixin) ->
  extend klass.prototype, mixin


class Module
  @extend: (obj) ->
    for key, value of obj when key not in moduleKeywords
      @[key] = value

    obj.extended?.apply(@)
    this

  @include: (obj) ->
    for key, value of obj when key not in moduleKeywords
      # Assign properties to the prototype
      @::[key] = value

    obj.included?.apply(@)
    this

# TODO: maybe also make a normaldistributed number?
# TODO: maybe implement exchangeable number type in position?

# classes that are combinable with a Mutable have to implement
# the following interface:
#   * the constructor does not take any parameters and sets the member 'myClass'
#   * the assign() method inherits the state of another instance of this class
#   * the newValue() method generates a new value of the type
#   * the interpolate() method interpolates between two class instances, 
#     given t=0..1

class RandomIntervalNumber
  
  constructor : () ->
    @myClass = RandomIntervalNumber

  assign : (from) ->
    @setRange(from.min,from.max)
    @val = from.val

  setRange : (min, max) ->
    @min = min
    @max = max
    @
  
  newValue : ->
    @val = getRandom(@min, @max)

  setValue : (v) ->
    @val = v
  
  # t=1..0, from..to
  interpolate : (from, to, t) ->
    @setValue(from.val*(t) + to.val*(1-t))
    @val

  intValue : ->
    Math.round(@val)

  valueOf : ->
    @val

class RandomPosition

  constructor : () ->
    @myClass = RandomPosition
  
  setRange : (l,r,t,b) ->
    @x = new RandomIntervalNumber(l,r)
    @y = new RandomIntervalNumber(t,b)
    @

  assign : (from) ->
    @x.assign(from.x)
    @y.assign(from.y)

  newValue : ->
    @x.newValue()
    @y.newValue()
  
  #interpolate between two positions
  interpolate : (from, to, t) ->
    @x.interpolate(from.x.val, to.x.val, t)
    @y.interpolate(from.y.val, to.y.val, t)
    @valueOf()

  valueOf : ->
    { x: @x.val, y: @y.val }
    
# ----------------------------------------------------
# "Mutable" abstracts a changing behavior over time.
# it features the following "change" modes:
#   'discrete', 'linp'
# and the following repetition behavior:
#   'regular', 'irregular'

class Mutable
  # members:
  constructor: () ->
    @ctr = 1       # will trigger evaluation on first update
    @cycle = new RandomIntervalNumber().setRange(5,20)
    @cycle.setValue(10)         # default
    @upmode = 'discrete'        # default update mode
    @cymode = 'regular'         # default cycle mode
    @value = NaN;
    @lastValue = NaN;          

  # setType has to be called until mutable is valid!
  setType: ( val ) ->
    @value = val;
    @lastValue = new @value.myClass()
    @lastValue.assign(@value)
    @currentValue = new @value.myClass()
    @currentValue.assign(@value)
    @

  update : ->
    --@ctr
    if @ctr == 0
      @lastValue.assign(@value)
      @value.newValue()
      @newCycle()

  newCycle : ->
    switch @cymode
      when 'irregular'
        @cycle.newValue()

    @ctr = @cycle.intValue()

  valueOf : ->
    switch @upmode
      when 'discrete'
        v = @value.valueOf()
      when 'linp'
        v = currentValue.interpolate(@lastValue.val, @value.val, @ctr/@cycle.val)
    v

# --------------------------------------------------------
# The MutableController holds references to all mutables
class MutableController
   mutables : []

   registerMutable : ( m ) ->
      @mutables.push(m)

   removeMutable : ( m ) ->
      i = @mutables.indexOf(m)
      @mutables.splice(i, 1) if i != -1

   update : ->
      m.update() for m in @mutables

   log : ->
      for m in @mutables
        console.log(m.constructor.name + ":" + m.valueOf())
      #console.log(@mutables)
        

# --------------------------------------------------------
# simple test case
class MutableTest
  constructor: ->

  runTest: ->
    @mc = new MutableController()
    @A = new Mutable().setType(new RandomIntervalNumber().setRange(0,1))
    @A.cycle.setValue(3)
    @mc.registerMutable(@A)
    @B = new Mutable().setType(new RandomIntervalNumber().setRange(0,10))
    @B.cycle.setValue(2)
    @mc.registerMutable(@B)

    for i in [1..10]
      @mc.update()
#      @mc.log()
      console.log("A:" + @A.valueOf() + " B:" + @B.valueOf())

window.MutableTest = new MutableTest()
