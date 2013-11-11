myPainter = new MovingBrushPainter
imgSource = new ImageSource
dstCanvas = null

mainLoop = (images) ->
  for image in images
    imgCanvas = new ImageCanvas
      image: image
      width: image.width
      height: image.height

    imgSource.addImage imgCanvas

  myPainter.setImageSource imgSource
  myPainter.start()

  myRenderer = new Renderer
  dstContext = dstCanvas.getContext("2d")
  dstContext.fillRect 0, 0, dstCanvas.width, dstCanvas.height

  iterate = =>
    myPainter.paint myRenderer, dstContext
    myPainter.update()
    window.requestAnimationFrame iterate

  window.requestAnimationFrame iterate
  null

# main application
window.startPainter = (renderTarget, images, callback) ->
  dstCanvas = renderTarget
  mainLoop images
  # Pass the reference to myPainter back to UI
  callback(myPainter) if callback
