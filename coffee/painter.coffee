l = 0;
# Brush Class
class Brush extends Base
  defaults: 
    x: 0
    y: 0
    size: 0
    shape: 0

  setState: () =>
    @state = extend @defaults, arguments
    @

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
    #Defaults
    imgSrc: null
    brushes: null
    brushCount: 10
    brushShape: 'circle'
    minBrushSize: 3
    maxBrushSize: 10
    brushSize: 3
    brushDx: 1
    brushDy: 1
    chanceDirection: 20
    chanceSize: 20
    chanceRespawn: 20

  init: ->
  paint: (renderer, destination) ->
  update: ->
  setImageSource: (image) ->
    @state.imgSrc = image

# the MovingBrushPainter is a simple painter that just copies
# brushes from multiple input images to a destination image
class MovingBrushPainter extends Painter
  setBrushes: (num) ->
    @state.brushCount = num
    @init

  init: ->
    # initialize brushes
    @brushes = []
    i = 0
    while i <= @state.brushCount
      @brushes[i] = new Brush
        dx: @state.brushDx
        dy: @state.brushDy
        x: getRandom 0, @state.imgSrc.state.width - 1
        y: getRandom 0, @state.imgSrc.state.height - 1
        size: @state.brushSize
        shape: @state.brushShape
      ++i

  paint: (renderer, dest) =>
    imgIndex = 0
    imgCount = @state.imgSrc.getImageCount()

    # render each brush, cycling through input images
    i = 0
    while i < @state.brushCount
      src = @state.imgSrc.getImage imgIndex
      renderer.renderBrush @brushes[i].state, src, dest
      imgIndex++
      imgIndex = 0 if imgIndex is imgCount
      ++i

  update: ->
    # update the state of each brush
    i = 0
    while i < @state.brushCount
      imgState = @state.imgSrc.state

      # move brush within image area limits
      @brushes[i].state.x = @brushes[i].state.x + @brushes[i].state.dx
      @brushes[i].state.x = 0 if @brushes[i].state.x < 0
      @brushes[i].state.x = imgState.width if @brushes[i].state.x > imgState.width

      @brushes[i].state.y = @brushes[i].state.y + @brushes[i].state.dy
      @brushes[i].state.y = 0 if @brushes[i].state.y < 0
      @brushes[i].state.y = imgState.height if @brushes[i].state.y > imgState.height

      @brushes[i].state.shape = @state.brushShape

      #Reset brushsize every now and then
      @brushes[i].state.size = getRandomInt(@state.minBrushSize, @state.maxBrushSize) if percentTrue @state.chanceSize

      #Respawn every now and then
      if percentTrue @state.chanceRespawn
        @brushes[i].state.x = getRandom 1, imgState.width
        @brushes[i].state.y = getRandom 1, imgState.height

      #Change direction every now and then
      if percentTrue @state.chanceDirection
        @brushes[i].state.dx = getRandom(-1, 1) * (@brushes[i].state.size / 2)
        @brushes[i].state.dy = getRandom(-1, 1) * (@brushes[i].state.size / 2)
      throw 'Brushstate has NAN - ' + @brushes[i].state if @brushes[i].state.x is NaN or @brushes[i].state.y is NaN or @brushes[i].state.dx is NaN or @brushes[i].state.dy is NaN or @brushes[i].state.size is NaN
      ++i
    @
