# -----------------------------------------------------------------------------
# Brush Interface:
# .x() | .y() -> get position
# .size()     -> get brush size
# .type       -> get brush type

class Brush 
  constructor : (w,h) ->
    @pos   = new Mutable().setType(new RandomPosition().setRange(0,w,0,h))
    @pos.setIrregular(20,100,'linp')
    @bsize = new Mutable().setType(new RandomIntervalNumber().setRange(10,20))
    @bsize.setIrregular(20,100,'linp')
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
    @pos = new Mutable().setType(new RandomPosition().setRange(0,w,0,h))
    @pos.setIrregular(100,200,'discrete')
    @delta = new  Mutable().setType(new RandomPosition().setRange(-10,10,-10,10))
    @delta.setIrregular(1,10,'linp')
    @type = 'circle'
    @update()
    
  update : ->
    @pos.update()
    @delta.update()
    @pos.value.x.setValue(@pos.value.x + @delta.value.x)
    @pos.value.y.setValue(@pos.value.y + @delta.value.y)
    d=@delta.valueOf()
    @bsize = (Math.round(Math.sqrt(d.x*d.x+d.y*d.y))*2)+1

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
  # the Painter interface
  defaults:
    imgSrc: null

  init: ->
  paint: (renderer, destination) ->
  update: ->
  setImageSource: (image) ->
    @state.imgSrc = image

# The MovingBrushPainter is a simple painter that just copies
# brushes from multiple input images to a destination image
class MovingBrushPainter extends Painter
  defaults:
   brushCount: 10
   brushType: 'circle'
   brushBlend: 'alpha'

  setBrushes: (num) ->
    @state.brushCount = num
    @init

  init: ->
    # initialize brushes
    @brushes = []
    i = 0
    while i <= @state.brushCount
      @brushes[i] = new Brush2(@state.imgSrc.state.width,@state.imgSrc.state.height)
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


