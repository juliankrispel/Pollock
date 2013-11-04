class Movement extends Base

class MovementOne extends Movement
  public:
    'movementDescription': 'description'
    'movementMinSize': 'minSize'
    'movementOneAttribute': 'maxSize'
  defaults:
    description: 'Movement 1'
    maxSize: 50
    minSize: 3
  init: ()->
    console.log 'hello I\'m Movement 1'

class MovementTwo extends Movement
  public:
    'movementDescription': 'description'
    'movementMinSize': 'minSize'
    'movementTwoAttribute': 'maxSize'
  defaults:
    description: 'Movement 2'
    maxSize: 90
    minSize: 1
  init: ()->
    console.log 'hello I\'m Movement 2'

class MovementThree extends Movement
  public:
    'movementDescription': 'description'
    'movementMinSize': 'minSize'
    'movementThreeAttribute': 'maxSize'
  defaults:
    description: 'Movement 1'
    maxSize: 20
    minSize: 6
  init: ()->
    console.log 'hello I\'m Movement 3'

# -----------------------------------------------------------------------------
# Brush Interface:
# .x() | .y() -> get position
# .size()     -> get brush size
# .type       -> get brush type
class Brush extends Base
  defaults:
    type: 'circle'
    movementType: 'Movement 1'
    _oldMovement: 'Movement 1'
    movement: {}

  public: 
    'brushMinSize': 'sizem.value.min',
    'brushMaxSize': 'sizem.value.max',
    'brushMovementType': 'movementType',
    'brushType': 'type'

  startMovement: (movementClass) ->
    movementClass = movementClass or MovementOne
    @movement = new movementClass

  switchMovement: () =>
    switch @movementType
      when 'Movement 1' then @startMovement(MovementOne)
      when 'Movement 2' then @startMovement(MovementTwo)
      when 'Movement 3' then @startMovement(MovementThree)
      else @startMovement()

  init: (w, h) ->
    @pos = new Mutable
      value: new RandomPosition(0, w, 0, h)
      upmode: 'discrete'
      cycle: {
        mode: 'irregular'
        min: 900
        max: 2000
      }

    # locally change update behavior of position randomintervalnumber
    setValue = (v) -> 
      @val = if v<@min then @max else if v>@max then @min else v
      @

    @pos.value.x.setValue = setValue;
    @pos.value.y.setValue = setValue;

    @delta = new Mutable
      value: new RandomPosition -10, 10, -10, 10
      upmode: 'linp'
      cycle: 
        mode: 'irregular'
        min: 10
        max: 50

    @sizem = new Mutable
      value: new RandomIntervalNumber 2, 15
      upmode: 'linp'
      cycle: 
        mode: 'irregular'
        min: 20
        max: 100


    # initialize state (and use bound values)
    @.update() 
    @.startMovement()

  changeMovement: (movement)->

  update : ->
    @pos.update()                 # randomly spawn a new position
    @sizem.update()               # randomly set a new brush size now and then
    S = +@sizem.value
    @delta.value.setRange(-S/2,S/2,-S/2,S/2)
    @delta.update()               # interpolate moving direction
    D = @delta.valueOf()
    @pos.value.x.setValue(@pos.value.x + D.x)
    @pos.value.y.setValue(@pos.value.y + D.y)
    @bsize = S | 0
    #d=@delta.valueOf()
    #@bsize = (Math.round(Math.sqrt(d.x*d.x+d.y*d.y))*2)+1
    if(@_oldMovement isnt @movementType)
      @switchMovement()
      @_oldMovement = @movementType

  x : ->
    @pos.valueOf().x | 0

  y : ->
    @pos.valueOf().y | 0

  size : ->
    @bsize


