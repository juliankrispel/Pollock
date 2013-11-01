# -----------------------------------------------------------------------------
# Brush Interface:
# .x() | .y() -> get position
# .size()     -> get brush size
# .type       -> get brush type
class Brush
  constructor : (w,h) ->
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
    @width = width
    @height = height

  getImageCount: =>
    @images.length

  getImage: (index) ->
    @images[index]

  addImage: (img) ->
    @images.push img

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

  start: ->
  paint: (renderer, destination) ->
  update: ->
  setImageSource: (image) ->
    @imgSrc = image

# The MovingBrushPainter is a simple painter that just copies
# brushes from multiple input images to a destination image
class MovingBrushPainter extends Painter
  setBrushes: (num) ->
    @brushCount = num
    @init

  createBrush: (type) ->
    brush = new type(
      @imgSrc.width, 
      @imgSrc.height)

    # public brush state (can be manipulated by GUI)
    @PS.makePublic(brush.sizem.value, 'min', 'brushMinSize')
    @PS.makePublic(brush.sizem.value, 'max', 'brushMaxSize')
    @PS.makePublic(brush, 'type', 'brushType')
    brush.update() # initialize state (and use bound values)
    brush

  start: =>
    @PS = new PublishSubscriber();
    # initialize brushes
    @brushes = []
    i = 0
    while i <= @brushCount
      @brushes[i] =  @createBrush(Brush)
      ++i

    @PS.makePublic(@, 'brushCount', 'brushCount')
  @

  paint: (renderer, dest) ->
    imgIndex = 0
    imgCount = @imgSrc.getImageCount()

    # render each brush, cycling through input images
    i = 0
    while i < @brushCount
      src = @imgSrc.getImage imgIndex
      if(!@brushes[i])
        @brushes[i] = @createBrush(Brush)
      renderer.renderBrush @brushes[i], src, dest
      imgIndex++
      imgIndex = 0 if imgIndex is imgCount
      ++i

  update: ->
    for br in @brushes
      br.update()
    @
