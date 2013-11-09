angular.module 'PainterApp', ['uiSlider']

angular.module('PainterApp').controller 'PainterCtrl', ($scope) ->
  $scope.painter = {
    images: [
      {url: "img/02.jpg"},
      {url: "img/03.jpg"},
      {url: "img/04.jpg"},
      {url: "img/05.jpg"},
      {url: "img/07.jpg"},
      {url: "img/08.jpg"}
    ]
  }
  $scope.brushTypes = ['circle', 'scircle', 'square', 'weird', 'sort']
  $scope.brushMovements = ['Random', 'HalfPipe']
  $scope.removeImage = (index) ->
    $scope.painter.images.splice(index, 1)
  $scope.addImage = ->
    $scope.painter.images.push { url: '' }

angular.module('PainterApp').directive 'canvasPainter', ->
  (scope, element, attrs) ->
    scope.start = ->
      startPainter element[0], scope.painter.images, (myPainter) ->
        scope.painter = {
          hasLoaded: true
        }

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

        scope.$apply()
