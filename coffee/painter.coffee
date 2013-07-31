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
  each Array::slice.call(arguments_, 1), (source) ->
    if source
      for prop of source
        obj[prop] = source[prop]
  obj

# Base Class
class Base
  constructor: (options) -> 
    extend @config, options

# Brush Class
class Brush extends Base
  config: 
    x: 0
    y: 0
    size: 0
    shape: 0

  setState: () =>
    extend @config, arguments
    @


# ImageSource abstracts a set of images, accesible by index
# width and height of ImageSource correspond to 
# the maximal width and height of images it contains
class ImageSource extends Base
  config: 
    w: 0
    h: 0
    images: []

  setSize: (width, height) =>
    @config.w = width
    @config.h = height

  getNumImages: =>
    @config.images.length

  getImage: (index) ->
    @images[index]

  addImage: (img) ->
    @images.push img

# a Painter is responsible for what is going to get drawn where
# this object just defines the interface
Painter = Base.extend(
  
  # the Painter interface
  config:
    
    #Defaults
    imgSrc: null

  init: ->

  paint: (renderer, destination) ->

  update: ->

  setImageSource: (input) ->
    @imgSrc = input
)

# the MovingBrushPainter is a simple painter that just copies
# brushes from multiple input images to a destination image
MovingBrushPainer = createNew: ->
  painter = new Painter
  painter.myBrushes = null
  painter.N = 10
  painter.setBrushes = (num) ->
    @N = num
    @init()

  
  # implements painter interface
  # ------------------------------- init
  painter.init = ->
    
    # initialize brushes
    @myBrushes = []
    i = 0
    while i < @N
      @myBrushes.push Brush.createNew()
      @myBrushes[i].dx = 1
      @myBrushes[i].dy = 1
      @myBrushes[i].setState getRandom(0, @imgSrc.W - 1), getRandom(0, @imgSrc.H - 1), 10, "circle"
      ++i


  
  # ------------------------------- paint
  painter.paint = (renderer, dest) ->
    
    #var imgIndex = getRandomInt(0,this.imgSrc.getNumImages()-1);
    imgIndex = 0
    
    # render each brush, cycling through input images
    i = 0
    while i < @N
      src = @imgSrc.getImage(imgIndex)
      renderer.renderBrush @myBrushes[i], src, dest
      imgIndex++
      imgIndex = 0  if imgIndex is @imgSrc.getNumImages()
      ++i

  
  # ------------------------------- update
  painter.update = ->
    
    # update the state of each brush
    i = 0
    while i < @N
      brush = @myBrushes[i]
      
      # move brush within image area limits
      brush.x = brush.x + brush.dx
      brush.x = 0  if brush.x < 0
      brush.x = @imgSrc.W  if brush.x > @imgSrc.W
      brush.y = brush.y + brush.dy
      brush.y = 0  if brush.y < 0
      brush.y = @imgSrc.H  if brush.y > @imgSrc.H
      
      #Reset brush every now and then
      brush.size = getRandomInt(7, 15)  if percentTrue(30)
      
      #Respawn every now and then
      if percentTrue(5)
        brush.x = getRandom(1, @imgSrc.W)
        brush.y = getRandom(1, @imgSrc.H)
      
      #Change direction every now and then
      if percentTrue(80)
        brush.dx = getRandom(-1, 1) * (brush.size / 2)
        brush.dy = getRandom(-1, 1) * (brush.size / 2)
      alert brush  if brush.x is NaN or brush.y is NaN or brush.dx is NaN or brush.dy is NaN or brush.size is NaN
      ++i

  painter

ImageLoader = (imageFiles, callback) ->
  images = []
  i = 0

  while i < imageFiles.length
    img = new Image()
    img.onload = ->
      images.push this
      
      # Call callback when done loading images and pass images as argument
      callback images  if images.length is imageFiles.length

    img.src = imageFiles[i]
    i++


# the renderer is actually responsible for copying pixels
SimpleRenderer = createNew: ->
  renderer = {}
  renderer.blendBlock = (src, dst) ->
    i = 0

    while i < src.length
      
      # simple blend: use dst[i] for everyone for a interesting effect
      dst[i] = (src[i] + dst[i]) / 2
      dst[i + 1] = (src[i + 1] + dst[i + 1]) / 2
      dst[i + 2] = (src[i + 2] + dst[i + 2]) / 2
      i += 4

  renderer.getBrushData = (brush, context) ->
    context.getImageData Math.round(brush.x), Math.round(brush.y), Math.round(brush.size), Math.round(brush.size)

  renderer.blend = (src, dst, alpha) ->
    Math.round alpha * src + (1 - alpha) * dst

  renderer.renderBrush = (brush, source, destination) ->
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

  renderer

MainLoop = (images) ->
  imgSource = ImageSource.createNew()
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
  myPainter = MovingBrushPainter.createNew()
  myPainter.setImageSource imgSource
  myPainter.init()
  myRenderer = SimpleRenderer.createNew()
  dstContext = dstCanvas.getContext("2d")
  dstContext.fillRect 0, 0, dstCanvas.width, dstCanvas.height
  
  # // - start main loop
  # window.requestAnimationFrame(function(){
  #    myPainter.paint(myRenderer, dstCanvas);
  #    myPainter.update();
  # });
  # testPos = 0;
  Loop = ->
    
    #dstContext.fillRect(testPos,testPos,testPos+10,testPos+10);
    #testPos++;
    myPainter.paint myRenderer, dstContext
    myPainter.update()
    window.requestAnimationFrame Loop

  window.requestAnimationFrame Loop

dstCanvas = null

# main application
StartApp = (renderTarget) ->
  dstCanvas = renderTarget
  ImageLoader new Array("img/03.jpg", "img/04.jpg", "img/05.jpg"), MainLoop

StartApp document.getElementById("canvas")
