class ImageCanvas extends Base
  defaults:
    offsetX: 0
    offsety: 0

  getImageData: ->
    @imageData

  getPixelData: (x,y,size) ->
    index = (x + (y*@width))*4
    data = new Uint8ClampedArray(size*size*4)

    row = 0
    column = 0

    while row < size
      index += (row * @width)
      while column <= ((row + 1)*size)*4
        data[column+row*size] = @imageData[index]
        index++
        column++
      row++

    data

  imageToImageData: (image) ->
    canvas = document.createElement 'canvas'
    canvas.width = image.width
    canvas.height = image.height
    context2d = canvas.getContext '2d'
    context2d.drawImage image, 0, 0
    imgData = context2d.getImageData 0, 0, image.width, image.height
    imgData.data

  init: () ->
    unless @image
      throw new Error('Required attributes missing')

    @width = @image.width
    @height = @image.height

    @imageData = @imageToImageData @image

# ImageSource abstracts a set of images, accesible by index
# width and height of ImageSource correspond to 
# the maximal width and height of images it contains
class ImageSource extends Base
  public:
    'canvasWidth': 'width'
    'canvasHeight': 'height'

  defaults: 
    width: 600
    height: 400
    images: []

  getRandomImageCanvas: ->
    @images[Math.round Math.random() * (@images.length-1)]

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

  public: 
    'brushCount': 'brushCount'

  start: =>
    # initialize brushes
    @brushes = []
    i = 0
    while i <= @brushCount
      @brushes[i] =  new Brush({imgSrc: @imgSrc.getRandomImageCanvas()})
      ++i
  @

  paint: (renderer, dest) ->
    i = 0
    while i < @brushCount
      if(!@brushes[i])
        console.log 'brush doesn\'t exist really?'
        @brushes[i] = new Brush({imgSrc: @imgSrc.getRandomImageCanvas()})
      renderer.renderBrush @brushes[i], dest
      ++i

  update: ->
    for br in @brushes
      br.update()
    @
