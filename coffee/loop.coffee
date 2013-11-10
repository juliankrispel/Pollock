myPainter = new MovingBrushPainter

loadImages = (imageFiles, callback) ->
  images = []
  i = 0

  while i < imageFiles.length
    img = new Image()
    img.onload = ->
      images.push this

      # Call callback when done loading images and pass images as argument
      callback images if images.length is imageFiles.length

    img.src = imageFiles[i].url
    i++

  null

mainLoop = (images) ->
  imgSource = new ImageSource
  imgSource.setSize images[0].width, images[0].height
  i = 0

  while i < images.length
    imgCanvas = new ImageCanvas
      image: images[i]
      width: images[i].width
      height: images[i].height

    imgSource.addImage imgCanvas
    ++i

  myPainter.setImageSource imgSource
  myPainter.start()

  myRenderer = new SimpleRenderer
  dstContext = dstCanvas.getContext("2d")
  dstContext.fillRect 0, 0, dstCanvas.width, dstCanvas.height

  iterate = =>
    myPainter.paint myRenderer, dstContext
    myPainter.update()
    window.requestAnimationFrame iterate

  window.requestAnimationFrame iterate
  null

dstCanvas = null

# main application
window.startPainter = (renderTarget, images, callback) ->
  dstCanvas = renderTarget
  loadImages images, 
    (images) ->
        mainLoop images
        # Pass the reference to myPainter back to UI
        callback(myPainter) if callback
