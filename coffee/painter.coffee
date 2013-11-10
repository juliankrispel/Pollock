class ImageCanvas extends Base
  init: () ->
    unless @width || @height || @image
      throw new Error('Required attributes missing')
    @$canvas = document.createElement 'canvas'
    @$canvas.width = @width
    @$canvas.height = @height
    @context2d = @$canvas.getContext '2d'
    @context2d.drawImage @image, 0, 0

# ImageSource abstracts a set of images, accesible by index
# width and height of ImageSource correspond to 
# the maximal width and height of images it contains
class ImageSource extends Base
  defaults: 
    width: 0
    height: 0
    images: []

  setSize: (width, height) =>
    @width = width
    @height = height

  getImageCount: =>
    @images.length

  getImage: (index) ->
    @images[index]

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
      @brushes[i] =  new Brush(@imgSrc.width, @imgSrc.height)
      ++i
  @

  paint: (renderer, dest) ->
    imgIndex = 0
    imgCount = @imgSrc.getImageCount()

    # render each brush, cycling through input images
    i = 0
    while i < @brushCount
      src = @imgSrc.getImage imgIndex
      if(!@brushes[i])
        @brushes[i] = new Brush(@imgSrc.width, @imgSrc.height)
      renderer.renderBrush @brushes[i], src, dest
      imgIndex++
      imgIndex = 0 if imgIndex is imgCount
      ++i

  update: ->
    for br in @brushes
      br.update()
    @
