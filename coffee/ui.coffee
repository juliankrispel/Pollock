angular.module 'PainterApp', []

angular.module('PainterApp').controller 'PainterCtrl', ($scope) ->
    $scope.painter = {}
    $scope.painter.chanceRespawn = 'hello'

angular.module('PainterApp').directive 'canvasPainter', ->
    (scope, element, attrs) ->
        startPainter element[0], (myPainter) ->
            scope.$watch (changes)-> 
                _(myPainter.state).extend changes.painter
