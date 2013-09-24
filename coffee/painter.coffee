
# Brush Class
#class Brush extends Base
#  defaults: 
#    x: 0
#    y: 0
#    size: 0
#    type: 0

class Brush 
  constructor : (l,r,t,b,typ) ->
    @pos = new Mutable().setType(new RandomPosition().setRange(l,r,t,b))
    @pos.setIrregular(20,100,'linp')
    @bsize = new Mutable().setType(new RandomIntervalNumber().setRange(10,20))
    @bsize.value.setValue(1)
    @bsize.setIrregular(20,100,'linp')
    @type = typ

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

# a Painter is responsible for what is going to get drawn where
# this object just defines the interface
class Painter extends Base
  # the Painter interface
  defaults:
    imgSrc: null

  init: ->
  paint: (renderer, destination) ->
  update: ->
  setImageSource: (image) ->
    @state.imgSrc = image

# the MovingBrushPainter is a simple painter that just copies
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
      @brushes[i] = new Brush(0,@state.imgSrc.state.width,
        0,@state.imgSrc.state.height,'circle')
      ++i
  @

  paint: (renderer, dest) =>
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


