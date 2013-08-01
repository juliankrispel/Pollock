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

  null

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
