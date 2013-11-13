
class CImage 

# Painter needs to manage:
# - the background/painting canvas (+public channels)
# - the list of input images + their transformations

# an image consists of width/height/imageData

# A transformation consists of rotation and scale around an image center
# and a translation
class Transformation extends Base
  
  defaults:
    tx: 100
    ty: -100        # translation
    sx: 0.5
    sy: 0.5      # scale
    angle: 45*Math.PI/180   # rotation
  
  transformImage: (context, image) ->
    context.setTransform
    #context.translate(-image.width/2,-image.height/2)
    #context.scale(@sx,@sy)
    context.translate(@tx,@ty)
    context.rotate(@angle)
    #context.translate(image.width/2+@tx,image.height/2+@ty)
    context.drawImage(image,0,0)


# CImage holds an Image + the pixel array
class CImage extends Base
  defaults:
    width: 0
    height: 0

  init: () ->
    @canvas = document.createElement 'canvas'
    if @image != undefined
      @width = @image.width
      @height = @image.height
    @canvas.width = @width
    @canvas.height = @height
    context2d = @canvas.getContext '2d'
    if @image != undefined
      context2d.drawImage @image, 0, 0
    @imgData = context2d.getImageData 0, 0, @width, @height

  drawToCanvas: (canvas) ->
    canvas.getContext('2d').putImageData @imgData, 0, 0

# TransformedImage 
class TransformedImage extends CImage
  defaults:
    transwidth: 100
    transheight: 100
    transformation: new Transformation

  init: () ->
    @applyTransformation()

  applyTransformation: () ->
    # create empty image
    @transformed = new CImage
      width: @transwidth
      height: @transheight
    ctx = @transformed.canvas.getContext('2d')
    @transformation.transformImage(ctx, @image)
    @transformed.imgData = ctx.getImageData 0, 0, @transformed.width, @transformed.height

  getPixelData: (x, y, size) ->

    imgData = {
      width: size
      height: size
      data: new Uint8ClampedArray(size*size*4)
    }

    row = 0
    srcoffset = (x + (y*@transformed.width))*4
    dstoffset = 0
    while row < size
      imgData.data.set( @transformed.imgData.data.subarray(srcoffset, srcoffset+size*4), dstoffset )
      srcoffset += @transformed.width*4
      dstoffset += size*4
      ++row

    imgData


# class Image extends Base
#   defaults:
#     width: 0
#     height: 0

#   getImageData: ->
#     @imageData

#   init: () ->
#     unless @image
#       throw new Error('Required attributes missing')

#     canvasWidth = @PS.getValue('canvasWidth')
#     canvasHeight = @PS.getValue('canvasHeight')

#     if(canvasWidth > @image.width)
#       @width = @image.width
#       @offsetX = (canvasWidth - @width)/2
#     else
#       @width = canvasWidth

#     if(canvasHeight > @image.height)
#       @height = @image.height
#       @offsetY = (canvasHeight - @height)/2
#     else
#       @height = canvasHeight

#     @imageData = @imageToImageData @image

#   getPixelData: (x, y, size) ->

#     imgData = {
#       width: size
#       height: size
#       data: new Uint8ClampedArray(size*size*4)
#     }

#     row = 0
#     srcoffset = (x + (y*@width))*4
#     dstoffset = 0
#     while row < size
#       imgData.data.set( @imageData.data.subarray(srcoffset, srcoffset+size*4), dstoffset )
#       srcoffset += @width*4
#       dstoffset += size*4
#       ++row

#     imgData

#   imageToImageData: (image) ->
#     canvas = document.createElement 'canvas'
#     canvas.width = @width
#     canvas.height = @height

#     context2d = canvas.getContext '2d'
#     context2d.drawImage image, 0, 0
#     imgData = context2d.getImageData 0, 0, canvas.width, canvas.height
#     imgData


# ImageSource abstracts a set of images, accesible by index
# width and height of ImageSource correspond to 
# the maximal width and height of images it contains
class ImageSource extends Base
  public:
    'canvasWidth': 'width'
    'canvasHeight': 'height'
    'images': 'domImages'

  defaults: 
    width: 600
    height: 400
    images: []
    domImages: []

  getRandomImageCanvas: ->
    @images[Math.round Math.random() * (@images.length-1)]

  getImageCanvas:(index) ->
    @images[index]


  # img is CImage
  addImage: (img) ->
    @images.push new TransformedImage
      width: img.width
      height: img.height
      image: img.image
      transwidth: @width
      transheight: @height

  init: ->
    @PS.subscribe('images', 'ImageSource', (value)->
      console.log 'images have changed', value
    )

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

  public: 
    'brushCount': 'brushCount'

  start: =>
    # initialize brushes
    @brushes = []
    i = 0
    while i <= @brushCount
      @brushes[i] =  new Brush()
      ++i
  @

  paint: (renderer, dest) ->
    i = 0
    imgIndex = 0
    while i < @brushCount
      if(!@brushes[i])
        @brushes[i] = new Brush()
      renderer.renderBrush @brushes[i], @imgSrc.getImageCanvas(imgIndex++), dest
      imgIndex = 0 if imgIndex==@imgSrc.images.length
      ++i

  update: ->
    for br in @brushes
      br.update()
    @
