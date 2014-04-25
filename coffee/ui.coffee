angular.module 'PainterApp', ['uiSlider']

$canvas = document.querySelector('canvas')

window.addEventListener('dragover', (event)->
  event.preventDefault()
, false)

#painter.PS.subscribe('images','painter', (value)->
#  console.log painter.PS.getValue('images')
#)

angular.module('PainterApp').controller 'PainterCtrl', ($scope) ->
  bbox = document.body.getBoundingClientRect()
  $scope.painter = {
    canvasHeight: bbox.height
    canvasWidth: bbox.width
    images: [
    ]
  }

  window.onresize = ()->
    bbox = document.body.getBoundingClientRect()
    $scope.painter.canvasHeight = bbox.height
    $scope.painter.canvasWidth = bbox.width
    $scope.$apply()

  $scope.brushTypes = ['circle', 'scircle', 'square', 'weird', 'sort']
  $scope.brushMovements = ['Random', 'HalfPipe']
  $scope.removeImage = (index) ->
    $scope.painter.images.splice(index, 1)

  window.addEventListener('drop', (event)->
    onImageDrop(event, (img)->
      $scope.painter.images.push({url: img.src})
      $scope.$apply();
    )
  , false)

  $scope.start = ->
    if($scope.painter.images.length < 1)
      return false

    startPainter $canvas, document.querySelectorAll('.image'), (painter) ->
      bindPainter(painter, $scope)

    setTimeout(()->
      $scope.painter.canvasHeight = bbox.height
      $scope.painter.canvasWidth = bbox.width
      $scope.$apply()
    ,1)

bindPainter = (myPainter, scope) ->
  scope.painter['hasLoaded'] = true
  list = myPainter.PS.getAllChannels()

  for name in list
    do(name) ->
      myPainter.PS.subscribe(name, 'gui', (value) -> 
        scope.painter[name] = value
        scope.$apply()
      )
      scope.painter[name] = myPainter.PS.getValue(name)
      scope.$watch 'painter.' + name, ()->
        myPainter.PS.setValue(name, 'gui', scope.painter[name])


onImageDrop = (event, callback)->
  event.preventDefault()
  file = event.dataTransfer.files[0]
  fileType = file.type

  if (!fileType.match(/image\/\w+/))
    console.log("Only image files supported.")
    return false

  reader = new FileReader()
  reader.onload = () ->
    _inputImage = new Image();
    _inputImage.src = reader.result;
    _inputImage.onload = ->
      callback(_inputImage)

  reader.readAsDataURL(file);
