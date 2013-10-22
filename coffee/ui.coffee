angular.module 'PainterApp', []

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
    $scope.removeImage = (index) ->
        $scope.painter.images.splice(index, 1)
    $scope.addImage = ->
        $scope.painter.images.push { url: '' }

angular.module('PainterApp').directive 'canvasPainter', ->
    (scope, element, attrs) ->
        scope.start = ->
            startPainter element[0], scope.painter.images, (myPainter) ->
                scope.painter = {}
                # initalize and subscribe
                scope.painter.minSize = myPainter.PS.getValue('Brush.minSize')
                myPainter.PS.subscribe('Brush.minSize', 'gui', () -> scope.painter.minSize = myPainter.PS.getValue('Brush.minSize'))
                scope.painter.maxSize = myPainter.PS.getValue('Brush.maxSize')
                myPainter.PS.subscribe('Brush.maxSize', 'gui', () -> scope.painter.maxSize = myPainter.PS.getValue('Brush.maxSize'))
                console.log()
                scope.$watch('painter.maxSize', ()->
                    myPainter.PS.setValue('Brush.maxSize', 'gui', scope.painter.maxSize)
                )

                scope.$watch('painter.minSize', ()->
                    myPainter.PS.setValue('Brush.minSize', 'gui', scope.painter.minSize)
                )

                scope.$apply()
