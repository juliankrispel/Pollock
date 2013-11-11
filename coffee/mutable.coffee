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

# Range is an ordered tuple of two values: min < max
class Range
  constructor: (v1, v2) ->
    @setRange(v1, v2)

  setRange: (v1, v2) ->
    if v1<=v2
      @min = v1
      @max = v2
    else 
      @min = v2
      @max = v1

  mid: () ->
    (@min+@max)/2

  clone: () ->
    return new Range(@min, @max)

# An IntervalNumber makes sure its value is between a specific interval
# that is defined by a Range
class RandomIntervalNumber
  constructor: (range)->
    @myClass = RandomIntervalNumber
    @range = range.clone()
    @val = @range.mid()

  clone : () ->
    cloned = new RandomIntervalNumber(@range)
    cloned.val = @val
    cloned

  assign : (from) ->
    @range = from.range.clone()
    @val = from.val

  clamp : () ->
    @val = @min if @val < @min
    @val = @max if @val > @max

  setRange : (range) ->
    @range = range.clone()
    @clamp()
    @

  newValue : ->
    if (@range.min < @range.max)
      @val = getRandom(@range.min, @range.max)
    else 
      @val = @range.min
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


# RandomPosition's value is a tuple { x:<x>, y:<x> }
class RandomPosition
  constructor : (xrng,yrng) ->
    unless (xrng or yrng)
      throw(new Error('x and y range must be defined'))

    @myClass = RandomPosition
    @x = new RandomIntervalNumber(xrng)
    @y = new RandomIntervalNumber(yrng)

  setRange : (xrng,yrng) ->
    @x.setRange(xrng)
    @y.setRange(yrng)
    @

  clone : () ->
    cloned = new RandomPosition(@x.range, @y.range)
    cloned.x.val = @x.val
    cloned.y.val = @y.val
    cloned

  assign : (from) ->
    @setRange(from.x.range, from.y.range)
    @x.val = from.x.val
    @y.val = from.y.val

  newValue : ->
    @x.newValue()
    @y.newValue()
    @

  setValue : (v) ->
    @x.setValue(v.x)
    @y.setValue(v.y)

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
    cycle: -> new RandomIntervalNumber(new Range(20,100))

  init: () ->
    @setType(@value)

  # setType has to be called until mutable is valid!
  setType: ( val ) ->
    @value = val
    @lastValue = @value.clone()
    @currentValue = @value.clone()
    @

  update : ->
    --@ctr
    if @ctr <= 0
      @lastValue.assign(@value)   # backup last state (for interpolation)
      @value.newValue()           # create new value
      @cycle.newValue()           # update cycle
      @ctr = @cycle.intValue()    # start new cycle

  setRegularCycle : ( value ) ->
    @cycle.setRange(value, value)

  setIrregularCycle : ( min, max ) ->
    @cycle.setRange(min, max)

  valueOf : ->
    switch @upmode
      when 'discrete'
        v = @value.valueOf()
      when 'linp'
        v = @currentValue.interpolate(@lastValue, @value, @ctr/@cycle.intValue())
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

window.Mutable = Mutable
window.RandomIntervalNumber = RandomIntervalNumber;
