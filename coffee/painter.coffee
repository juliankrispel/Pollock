# ----------------------- utility
# Get a random number
getRandom = (lo, hi) ->
  Math.random() * (hi - lo) + lo

percentTrue = (p) ->
  Math.random() < (p / 100.0)

# Returns a random integer
getRandomInt = (lo, hi) ->
  Math.round getRandom(lo, hi)

# Extend function taken from underscore
extend = (obj) ->
  for source in Array::slice.call(arguments, 1)
    if source
      for prop of source
        obj[prop] = source[prop]
  obj

# Base Class
class Base
  constructor: (options) -> 
    extend @state, options

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
        x: getRandom(0, @imgSrc.state.width - 1)
        y: getRandom(0, @imgSrc.state.height - 1)
        size: 3
        shape: 'circle'
      ++i

  paint: (renderer, dest) =>
    imgIndex = 0
    imgCount = @imgSrc.getImageCount()

    # render each brush, cycling through input images
    i = 0
    while i < @state.brushCount
      src = @imgSrc.getImage(imgIndex)
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
      if percentTrue(.5)
        brushState.x = getRandom(1, imgState.width)
        brushState.y = getRandom(1, imgState.height)

      #Change direction every now and then
      if percentTrue(80)
        brushState.dx = getRandom(-1, 1) * (brushState.size / 2)
        brushState.dy = getRandom(-1, 1) * (brushState.size / 2)
      alert brushState  if brushState.x is NaN or brushState.y is NaN or brushState.dx is NaN or brushState.dy is NaN or brushState.size is NaN
      ++i
    @

loadImages = (imageFiles, callback) ->
  images = []
  i = 0

  while i < imageFiles.length
    img = new Image()
    img.onload = ->
      images.push this
      
      # Call callback when done loading images and pass images as argument
      callback images if images.length is imageFiles.length

    img.src = imageFiles[i]
    i++


# the renderer is actually responsible for copying pixels
class SimpleRenderer extends Base
  blendBlock: (src, dst) ->
    i = 0

    while i < src.length
      
      # simple blend: use dst[i] for everyone for a interesting effect
      dst[i] = (src[i] + dst[i]) / 2
      dst[i + 1] = (src[i + 1] + dst[i + 1]) / 2
      dst[i + 2] = (src[i + 2] + dst[i + 2]) / 2
      i += 4

  getBrushData: (brush, context) ->
    context.getImageData Math.round(brush.x), 
      Math.round(brush.y), 
      Math.round(brush.size), 
      Math.round(brush.size)

  blend: (src, dst, alpha) ->
    Math.round alpha * src + (1 - alpha) * dst

  renderBrush: (brush, source, destination) ->
    srcContext = source.imca.getContext("2d")
    srcData = @getBrushData(brush, srcContext)
    dstData = @getBrushData(brush, destination)
    @blendBlock srcData.data, dstData.data  if brush.shape is "square"
    if brush.shape is "circle"
      x = 0
      y = 0
      cnt = brush.size / 2
      i = 0
      y = 0

      while y < brush.size
        x = 0

        while x < brush.size
          dx = x - cnt
          dy = y - cnt
          d = Math.sqrt(dx * dx + dy * dy)
          alpha = (cnt - d) / cnt
          alpha = 0  if alpha < 0
          r = @blend(srcData.data[i], dstData.data[i], alpha)
          g = @blend(srcData.data[i + 1], dstData.data[i + 1], alpha)
          b = @blend(srcData.data[i + 2], dstData.data[i + 2], alpha)
          dstData.data[i] = r
          dstData.data[i + 1] = g
          dstData.data[i + 2] = b
          i += 4
          ++x
        ++y
    destination.putImageData dstData, brush.x, brush.y
    @

mainLoop = (images) ->
  imgSource = new ImageSource
  imgSource.setSize images[0].width, images[0].height
  i = 0

  while i < images.length
    images[i].imca = document.createElement("canvas")
    images[i].imca.width = images[i].width
    images[i].imca.height = images[i].height
    context = images[i].imca.getContext("2d")
    context.drawImage images[i], 0, 0
    imgSource.addImage images[i]
    ++i
  myPainter = new MovingBrushPainter
  myPainter.setImageSource imgSource
  myPainter.init()

  myRenderer = new SimpleRenderer
  dstContext = dstCanvas.getContext("2d")
  dstContext.fillRect 0, 0, dstCanvas.width, dstCanvas.height
  
  iterate = =>
    
    #dstContext.fillRect(testPos,testPos,testPos+10,testPos+10);
    #testPos++;
    myPainter.paint myRenderer, dstContext
    myPainter.update()
    window.requestAnimationFrame iterate

  window.requestAnimationFrame iterate
  null

dstCanvas = null

# main application
startApp = (renderTarget) ->
  dstCanvas = renderTarget
  loadImages ["img/03.jpg", "img/04.jpg", "img/05.jpg"], mainLoop

startApp document.getElementById("canvas")
