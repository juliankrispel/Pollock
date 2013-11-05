# helpers
#extendOBJ = (obj, mixin) ->
#  obj[name] = method for name, method of mixin        
#  obj
#
#includePROT = (klass, mixin) ->
#  extend klass.prototype, mixin

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
  constructor: (min, max)->
    @myClass = RandomIntervalNumber
    @val = 0
    @min = min
    @max = max

  clone : () ->
    cloned = new RandomIntervalNumber(@val.min, @val.max)
    cloned.val = @val
    cloned

  assign : (from) ->
    @setRange(from.min,from.max)
    @val = from.val

  clamp : () ->
    @val = @min if @val < @min
    @val = @max if @val > @max

  setRange : (min, max) ->
    @min = min
    @max = max
    @clamp()
    @

  newValue : ->
    @val = getRandom(@min, @max)
    @

  setValue : (v) ->
    @val = v 
    @clamp()
    @

  # t=1..0, from..to
  interpolate : (from, to, t) ->
    @setValue(from.val*(t) + to.val*(1-t))
    @val

  intValue : ->
    @val | 0

  valueOf : ->
    @val

class RandomPosition
  constructor : (l, r, t, b) ->
    unless l or r or t or b
      throw(new Error('l,r,t,b all must be defined'))

    @myClass = RandomPosition
    @x = new RandomIntervalNumber(l, r)
    @y = new RandomIntervalNumber(t, b)

  setRange : (l,r,t,b) ->
    #@x = new RandomIntervalNumber().setRange(l,r)
    #@y = new RandomIntervalNumber().setRange(t,b)
    @x.setRange(l,r)
    @y.setRange(t,b)
    @

  clone : () ->
    cloned = new RandomPosition(@x.min, @x.max, @y.min, @y.max)
    cloned.x.val = @x.val
    cloned.y.val = @y.val
    cloned

  assign : (from) ->
    @setRange(from.x.min,from.x.max,from.y.min,from.y.max)
    @x.val = from.x.val
    @y.val = from.y.val

  newValue : ->
    @x.newValue()
    @y.newValue()
    @

  #interpolate between two positions
  interpolate : (from, to, t) ->
    @x.interpolate(from.x, to.x, t)
    @y.interpolate(from.y, to.y, t)
    @valueOf()

  valueOf : ->
    { x: @x.val, y: @y.val }

# ----------------------------------------------------
# "Mutable" abstracts a changing behavior over time.
# it features the following "change" modes:
#   'discrete', 'linp'
# and the following repetition behavior:
#   'regular', 'irregular'

class Mutable extends Base
  # members:
  defaults:
    ctr: 1       # will trigger evaluation on first update
    upmode: 'discrete'        # default update mode
    value: NaN
    lastValue: NaN
    cycle:
      mode: 'regular'
      min: 20
      max: 100
      interval: 5

  init: () ->
    @_cycle = new RandomIntervalNumber(@cycle.min, @cycle.max)
    @_cycle.setValue(10)
    @setType(@value)

  # setType has to be called until mutable is valid!
  setType: ( val ) ->
    @value = val
    @lastValue = @value.clone()
    @currentValue = @value.clone()
    @

  update : ->
    --@ctr
    if @ctr == 0
      @lastValue.assign(@value)
      @value.newValue()
      @newCycle()

  setCycle : ( value ) ->


  newCycle : ->
    switch @cycle.mode
      when 'irregular'
        @_cycle.newValue()

      when 'regular'
        @ctr = @cycle.interval
    @ctr = @_cycle.intValue()

  valueOf : ->
    switch @upmode
      when 'discrete'
        v = @value.valueOf()
      when 'linp'
        v = @currentValue.interpolate(@lastValue, @value, @ctr/@_cycle.val)
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

window.Mutable = Mutable
window.RandomIntervalNumber = RandomIntervalNumber;
