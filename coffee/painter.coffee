# -----------------------------------------------------------------------------
# Brush Interface:
# .x() | .y() -> get position
# .size()     -> get brush size
# .type       -> get brush type

class Brush 
  constructor : (w,h) ->
    @pos = new Mutable().setType(new RandomPosition().setRange(0,w,0,h))
    @pos.cycle.setRange(20,100)
    @bsize = new Mutable().setType(new RandomIntervalNumber().setRange(10,20))
    @bsize.cycle.setRange(20,100)
    @type = 'circle'

  update : ->
    @pos.update()
    @bsize.update()
    @

  x : ->
    @pos.valueOf().x | 0

  y : ->
    @pos.valueOf().y | 0

  size : ->
    @bsize.value.val | 0

class Brush2
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

    @update()

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


# -----------------------------------------------------------------------------
# ImageSource abstracts a set of images, accesible by index
# width and height of ImageSource correspond to 
# the maximal width and height of images it contains
class ImageSource extends Base
  defaults: 
    width: 0
    height: 0
    images: []

  setSize: (width, height) =>
    @state.width = width
    @state.height = height

  getImageCount: =>
    @state.images.length

  getImage: (index) ->
    @state.images[index]

  addImage: (img) ->
    @state.images.push img

# -----------------------------------------------------------------------------
# The painter is responsible for what is going to get drawn where

# This object just defines the interface
class Painter extends Base
  #constructor: () ->
  #  @PS = new PublishSubscriber();

  # the Painter interface
  defaults:
    #Defaults
    imgSrc: null
    brushCount: 6

  init: ->
  paint: (renderer, destination) ->
  update: ->
  setImageSource: (image) ->
    @state.imgSrc = image

# The MovingBrushPainter is a simple painter that just copies
# brushes from multiple input images to a destination image
class MovingBrushPainter extends Painter

  setBrushes: (num) ->
    @state.brushCount = num
    @init

  createBrush: (type) ->
    brush = new type(
      @state.imgSrc.state.width, 
      @state.imgSrc.state.height)
    # public brush state (can be manipulated by GUI)
    @PS.makePublic(brush.sizem.value,'min','brushMinSize')
    @PS.makePublic(brush.sizem.value,'max','brushMaxSize')
    @PS.makePublic(brush,'type','brushType')
    brush

  init: =>
    @PS = new PublishSubscriber();
    # initialize brushes
    @brushes = []
    i = 0
    while i <= @state.brushCount
      @brushes[i] =  @createBrush(Brush2)
      ++i

    @PS.makePublic(@state, 'brushCount', 'brushCount')
  @

  paint: (renderer, dest) ->
    imgIndex = 0
    imgCount = @state.imgSrc.getImageCount()

    # render each brush, cycling through input images
    i = 0
    while i < @state.brushCount
      src = @state.imgSrc.getImage imgIndex
      if(!@brushes[i])
        @brushes[i] = @createBrush(Brush2)
      renderer.renderBrush @brushes[i], src, dest
      imgIndex++
      imgIndex = 0 if imgIndex is imgCount
      ++i

  update: ->
    for br in @brushes
      br.update()
    @
