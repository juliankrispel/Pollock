# movements need to reside in global namespace to be available
# to the class switcher
class Movement extends Base
 defaults:
   width: 10
   height: 10

class RandomMovement extends Movement
  public:
    'brushMinSize': 'sizem.value.range.min'
    'brushMaxSize': 'sizem.value.range.max'
    'movementChangeDirectionMin': 'delta.cycle.range.min'
    'movementChangeDirectionMax': 'delta.cycle.range.max'
    'movementInterpolation': 'delta.upmode'
#    'canvasWidth': 'pos.value.x.range.max'
#    'canvasHeight': 'pos.value.y.range.max'

  init: () ->
    @pos = new Mutable
      value: new RandomPosition(new Range(0, @width), new Range(0, @height))
      upmode: 'discrete'
      cycle: new RandomIntervalNumber(new Range(50,1000))

    # locally change update behavior of position randomintervalnumber
    setValue = (v) -> 
      @val = if v<@range.min then @range.max else if v>@range.max then @range.min else v
      @

    @pos.value.x.setValue = setValue;
    @pos.value.y.setValue = setValue;

    @delta = new Mutable
      value: new RandomPosition new Range(-10, 10), new Range(-10, 10)
      upmode: 'linp'
      cycle: new RandomIntervalNumber(new Range(10,50))

    @sizem = new Mutable
      value: new RandomIntervalNumber new Range(2, 15)
      upmode: 'linp'
      cycle: new RandomIntervalNumber new Range(20, 100)

    # initialize state (and use bound values)
    @.update() 

  update: () ->
    @pos.update()                 # randomly spawn a new position
    @sizem.update()               # randomly set a new brush size now and then
    S = +@sizem.value
    @delta.value.setRange(new Range(-S/2,S/2),new Range(-S/2,S/2))
    @delta.update()               # interpolate moving direction
    D = @delta.valueOf()
    @pos.value.x.setValue(@pos.value.x + D.x)
    @pos.value.y.setValue(@pos.value.y + D.y)
    @bsize = S | 0

  x: () ->
     @pos.valueOf().x | 0   

  y: () ->
    @pos.valueOf().y | 0

  size: () ->
    @bsize


# Movement two: move in half-circles
# State is : center, radius, starting angle
class HalfPipeMovement extends Movement
  public:
    'movementDescription': 'description'
    'movementMinSize': 'minSize'
    'movementTwoAttribute': 'maxSize'

  defaults:
    description: 'Half Circle Movement'

  init: ()->
    @center = new Mutable
      value: new RandomPosition(new Range(0, @width), new Range(0, @height))
      upmode: 'discrete'
      cycle: new RandomIntervalNumber(new Range(1,1))

    @radius = new Mutable
      value: new RandomIntervalNumber(new Range(10, 50))
      upmode: 'discrete'
      cycle: new RandomIntervalNumber(new Range(1,1))

    @sizem = new Mutable
      value: new RandomIntervalNumber new Range(3, 8)
      upmode: 'discrete'
      cycle: new RandomIntervalNumber new Range(1, 1)

    # initialize values
    @counter = 1
    @update()

  update: () ->
    if --@counter <= 0
       @sizem.update()
       @radius.update()
       r = @radius.value.intValue()
       # set a new center
       @center.value.setRange(new Range(r,@width-r), new Range(r, @height-r))
       @center.update()
       @counter = Math.PI * @radius.valueOf() / (@sizem.valueOf()/2)   # half circle arc length

    # calculate current position
    angle = (@sizem.valueOf()/2) * @counter / @radius.valueOf()
    @xPos = (@center.value.x.valueOf() + @radius * Math.cos(angle))|0
    @yPos = (@center.value.y.valueOf() + @radius * Math.sin(angle))|0

  x: () ->
    @xPos

  y: () ->
    @yPos

  size: () ->
    +@sizem.value


# --------------------------------------------------------------------
# ClassSwitcher using the PublishSubscriber mechanism

class ClassSwitcher extends Base
  defaults:
    channel: 'ClassSwitcherChannel'
    default: 'name1'
    params: {}
    classes: 
      'Random' : RandomMovement
      'HalfPipe' : HalfPipeMovement

  init : () ->
    @_class = @default
    @update()
    PS.publish(this, '_class' , @channel)

  update : () ->
    if @_class != @_oldClass
      if @classes.hasOwnProperty(@_class)
        @_oldClass = @_class
        @_value = new @classes[@_class]( @params )

  val : () ->
    @_value

# -----------------------------------------------------------------------------
# The Brush contains a (switchable) Movement and the Brush type (circle, sort, ..)
#
class Brush extends Base
  defaults:
    type: 'circle'

  public: 
    'brushType': 'type'

  init: () ->
    @movement = new ClassSwitcher
      channel: 'brushMovementType'
      default: 'Random'
      params:
        width: @imgSrc.width
        height: @imgSrc.height
        offsetX: @imgSrc.offsetX
        offsetY: @imgSrc.offsetY

  update : ->
    @movement.update()         # switches class
    @movement.val().update()   # update movement

  x : (isRelative) ->
    if(isRelative)
      @movement.val().x()
    else
      @movement.val().x() + @imgSrc.offsetX

  y : (isRelative) ->
    if(isRelative)
      @movement.val().y()
    else
      @movement.val().y() + @imgSrc.offsetY

  size : ->
    @movement.val().size()
