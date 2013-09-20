
# Brush Class
#class Brush extends Base
#  defaults: 
#    x: 0
#    y: 0
#    size: 0
#    type: 0

class Brush 
  constructor : (l,r,t,b,typ) ->
    @pos = new Mutable().setType(RandomPosition().setRange(l,r,t,b))
    @pos.setIrregular(20,100,'linp')
    @size = new Mutable().setType(RandomInterValNumber().setRange(1,5))
    @size.setIrregular(20,100,'linp')
    @type = typ

  update : ->
    @pos.update()
    @size.update()

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
#    minBrushSize: 1
#    maxBrushSize: 15
#    brushSize: 3
#    brushDx: 1
#    brushDy: 1
#    chanceDirection: 20
#    chanceSize: 20
#    chanceRespawn: 20

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
      @brushes[i] = new Brush(0,0,
        @state.imgSrc.state.width,@state.imgSrc.state.height,'circle')
        # dx: @state.brushDx
        # dy: @state.brushDy
        # x: getRandom 0, @state.imgSrc.state.width - 1
        # y: getRandom 0, @state.imgSrc.state.height - 1
        # size: @state.brushSize
        # type: @state.brushType
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

    # clamp = (val, delta, min, max) ->
    #    v = val + delta
    #    v = min if v < min
    #    v = max if v > max
    #    v

    for br in @brushes
      br.update()
      # brush = br.state
      # imgState = @state.imgSrc.state

      # # move brush within image area limits
      # brush.x = clamp(brush.x,brush.dx,0,imgState.width)
      # brush.y = clamp(brush.y,brush.dy,0,imgState.height)
      
      # brush.type = @state.brushType
      
      # # Reset brushsize every now and then
      # if percentTrue @state.chanceSize
      #   brush.size = getRandomInt(@state.minBrushSize, @state.maxBrushSize) 

      # # Respawn every now and then
      # if percentTrue @state.chanceRespawn
      #   brush.x = getRandom 1, imgState.width
      #   brush.y = getRandom 1, imgState.height

      # # Change direction every now and then
      # if percentTrue @state.chanceDirection
      #   brush.dx = getRandom(-1, 1) * (brush.size / 2)
      #   brush.dy = getRandom(-1, 1) * (brush.size / 2)
    @


