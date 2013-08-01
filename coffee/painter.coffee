# Brush Class
class Brush extends Base
  state: 
    x: 0
    y: 0
    size: 0
    shape: 0

  setState: () =>
    extend @state, arguments
    @

# ImageSource abstracts a set of images, accesible by index
# width and height of ImageSource correspond to 
# the maximal width and height of images it contains
class ImageSource extends Base
  state: 
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
  state:
    #Defaults
    imgSrc: null
    brushes: null
    brushCount: 10

  init: ->
  paint: (renderer, destination) ->
  update: ->
  setImageSource: (@imgSrc) ->

# the MovingBrushPainter is a simple painter that just copies
# brushes from multiple input images to a destination image
class MovingBrushPainter extends Painter
  setBrushes: (num) ->
    @state.brushCount
    @init

  init: =>
    # initialize brushes
    @brushes = []
    i = 0
    while i <= @state.brushCount
      @brushes.push new Brush
        dx: .5
        dy: .5
        x: getRandom 0, @imgSrc.state.width - 1
        y: getRandom 0, @imgSrc.state.height - 1
        size: 3
        shape: 'circle'
      ++i

  paint: (renderer, dest) =>
    imgIndex = 0
    imgCount = @imgSrc.getImageCount()

    # render each brush, cycling through input images
    i = 0
    while i < @state.brushCount
      src = @imgSrc.getImage imgIndex
      renderer.renderBrush @brushes[i].state, src, dest
      imgIndex++
      imgIndex = 0 if imgIndex is imgCount
      ++i

  update: ->
    # update the state of each brush
    i = 0
    while i < @state.brushCount
      brushState = @brushes[i].state
      imgState = @imgSrc.state

      # move brush within image area limits
      brushState.x = brushState.x + brushState.dx
      brushState.x = 0 if brushState.x < 0
      brushState.x = imgState.width if brushState.x > imgState.width

      brushState.y = brushState.y + brushState.dy
      brushState.y = 0 if brushState.y < 0
      brushState.y = imgState.height if brushState.y > imgState.height

      #Reset brushState every now and then
      brushState.size = getRandomInt(2, 15) if percentTrue(30)

      #Respawn every now and then
      if percentTrue .5
        brushState.x = getRandom 1, imgState.width
        brushState.y = getRandom 1, imgState.height

      #Change direction every now and then
      if percentTrue 80
        brushState.dx = getRandom(-1, 1) * (brushState.size / 2)
        brushState.dy = getRandom(-1, 1) * (brushState.size / 2)
      throw 'Brushstate has NAN - ' + brushState if brushState.x is NaN or brushState.y is NaN or brushState.dx is NaN or brushState.dy is NaN or brushState.size is NaN
      ++i
    @
