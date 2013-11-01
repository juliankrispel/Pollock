angular.module 'PainterApp', []

body = document.getElementById('body')

window.addEventListener('dragover', (event)->
  event.preventDefault()
, false)


angular.module('PainterApp').controller 'PainterCtrl', ($scope) ->
  $scope.painter = {
    images: [
    ]
  }
  $scope.brushTypes = ['circle', 'scircle', 'square', 'weird', 'sort']
  $scope.removeImage = (index) ->
    $scope.painter.images.splice(index, 1)

  window.addEventListener('drop', (event)->
    onImageDrop(event, (img)->
      console.log img.src
      $scope.painter.images.push({url: img.src})
      $scope.$apply();
    )
  , false)


angular.module('PainterApp').directive 'canvasPainter', ->
  (scope, element, attrs) ->
    scope.start = ->
      if(scope.painter.images.length < 1)
        return false

      startPainter element[0], scope.painter.images, (myPainter) ->
        scope.painter = {
          hasLoaded: true
        }

        list = [ 'brushMinSize', 'brushMaxSize', 'brushCount', 'brushType' ]

        for name in list
          do(name) ->
            scope.painter[name] = myPainter.PS.getValue(name)

            myPainter.PS.subscribe(name, 'gui', () -> 
              scope.painter[name] = myPainter.PS.getValue(name))

            scope.$watch('painter.' + name, ()->
              myPainter.PS.setValue(name, 'gui', scope.painter[name])
            )

        scope.$apply()

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

    _inputImage.onload = (a,b,c)->
      callback(_inputImage)

  reader.readAsDataURL(file);

  console.log file

