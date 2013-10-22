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
    Math.round(@pos.valueOf().x)

  y : ->
    Math.round(@pos.valueOf().y)

  size : ->
    Math.round(@bsize.value.val)

class Brush2
  constructor : (w,h) ->
    @pos = new Mutable().setType(new RandomPosition().setRange(0,w-50,0,h-50))
    @pos.cycle.setRange(100,200)
    @delta = new Mutable().setType(new RandomPosition().setRange(-10,10,-10,10))
    @delta.cycle.setRange(1,20)
    @sizem = new Mutable().setType(new RandomIntervalNumber().setRange(5,30))
    @delta.cycle.setRange(1,20)
    @type = 'circle'
    @update()

  update : ->
    @pos.update()
    @delta.update()
    @sizem.update()
    @pos.value.x.setValue(@pos.value.x + @delta.value.x)
    @pos.value.y.setValue(@pos.value.y + @delta.value.y)
    d=@delta.valueOf()
    @bsize = Math.round(+@sizem.value)
    if @bsize == 0
      console.log 'min:'+@sizem.value.min+' max:'+@sizem.value.max+' val:'+ (0+@sizem.value)
      console.log 'brak'
    #@bsize = (Math.round(Math.sqrt(d.x*d.x+d.y*d.y))*2)+1

  x : ->
    Math.round(@pos.valueOf().x)

  y : ->
    Math.round(@pos.valueOf().y)

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

  init: =>
    @PS = new PublishSubscriber();
    # initialize brushes
    @brushes = []
    i = 0
    while i <= @state.brushCount
      @brushes[i] = new Brush2(
          @state.imgSrc.state.width, 
          @state.imgSrc.state.height)
      # make brush state public
      @PS.makePublic(@brushes[i].sizem.value,'min','Brush.minSize')
      @PS.makePublic(@brushes[i].sizem.value,'max','Brush.maxSize')
      ++i
  @

  paint: (renderer, dest) ->
    imgIndex = 0
    imgCount = @state.imgSrc.getImageCount()

    # render each brush, cycling through input images
    i = 0
    while i < @state.brushCount
      src = @state.imgSrc.getImage imgIndex
      renderer.renderBrush @brushes[i], src, dest
      imgIndex++
      imgIndex = 0 if imgIndex is imgCount
      ++i

  update: ->
    for br in @brushes
      br.update()
    @
