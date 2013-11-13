angular.module 'PainterApp', ['uiSlider']

body = document.getElementById('body')

window.addEventListener('dragover', (event)->
  event.preventDefault()
, false)

painter.PS.setValue('arr', 'gui', [])

painter.PS.subscribe('cow', 'painter', (value)->
  console.log('mooh', value)
)

painter.PS.subscribe('images','painter', (value)->
  console.log( 'dwq', value )
  console.log painter.PS.getValue('images')
)
angular.module('PainterApp').controller 'PainterCtrl', ($scope) ->
  $scope.painter = {
    images: [
    ]
  }
  $scope.brushTypes = ['circle', 'scircle', 'square', 'weird', 'sort']
  $scope.brushMovements = ['Random', 'HalfPipe']
  $scope.removeImage = (index) ->
    $scope.painter.images.splice(index, 1)

  window.addEventListener('drop', (event)->
    onImageDrop(event, (img)->
      images = painter.PS.getValue('images')
      $scope.painter.images.push({url: img.src})
      images.push(document.querySelectorAll('.image'))

      painter.PS.setValue 'arr', 'gui', ['dwq']
      
      painter.PS.setValue('images', 'gui', images)
      $scope.$apply();
    )
  , false)


angular.module('PainterApp').directive 'canvasPainter', ->
  (scope, element, attrs) ->
    scope.start = ->
      if(scope.painter.images.length < 1)
        return false

      startPainter element[0], document.querySelectorAll('.image'), (painter) ->
        bindPainter(painter, scope)


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
