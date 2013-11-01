#
# Brush Movement Behavior Interface
#
# .x() | .y() -> getPosition
# .update()   -> update internal state
#
# internal state parameters: Name / Type / [Defaults] / [Member Vars] ] / Channel

class MovementBehavior

    constructor : () ->
        @type = 'none'

    x : () ->
        0

    y : () ->
        0

    update : () ->
        @
    

class RandomMovementBehavior extends MovementBehavior
    
    PublicStateParameters: [
        [ 'Brush Size', 'interval', [1.0, 5.0, 10.0, 200.0], ['bsize.value.min','bsize.value.max'] ,'brushSize' ]
        [ 'Brush Speed', 'interval', [1, 20, 100, 300], ['bsize.cycle.min','bsize.cycle.max'] ,'brushSpeed' ]
    ]

    constructor : () ->
        setValue = (v) -> 
          @val = if v<@min then @max else if v>@max then @min else v
          @

        @pos = new Mutable().setType(new RandomPosition().setRange(0,w,0,h))
        @pos.cymode = 'irregular'
        @pos.upmode = 'discrete'
        @pos.cycle.setRange(900,2000)
        # locally change update behavior of position randomintervalnumber
        @pos.value.x.setValue = setValue;
        @pos.value.y.setValue = setValue;

        @bsize = new Mutable().setType(new RandomIntervalNumber().setRange(2,15))
        @bsize.upmode = 'linp'
        @bsize.cymode = 'irregular'
        @bsize.cycle.setRange(20,100)

# -----------------------------------------------------------------------------
# Brush Interface:
# .x() | .y() -> get position
# .size()     -> get brush size
# .type       -> get brush type


class OldBrush
  constructor : (w,h) ->
    setValue = (v) -> 
      @val = if v<@min then @max else if v>@max then @min else v
      @

    @pos = new Mutable().setType(new RandomPosition().setRange(0,w,0,h))
    @pos.cymode = 'irregular'
    @pos.upmode = 'discrete'
    @pos.cycle.setRange(900,2000)
    # locally change update behavior of position randomintervalnumber
    @pos.value.x.setValue = setValue;
    @pos.value.y.setValue = setValue;

    @delta = new Mutable().setType(new RandomPosition().setRange(-10,10,-10,10))
    @delta.cymode = 'irregular'
    @delta.upmode = 'linp'
    @delta.cycle.setRange(10,50)

    @sizem = new Mutable().setType(new RandomIntervalNumber().setRange(2,15))
    @sizem.upmode = 'linp'
    @sizem.cymode = 'irregular'
    @sizem.cycle.setRange(20,100)

    @type = 'circle'


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

  x : ->
    @pos.valueOf().x | 0

  y : ->
    @pos.valueOf().y | 0

  size : ->
    @bsize
