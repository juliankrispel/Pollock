angular.module 'PainterApp', []

angular.module('PainterApp').controller 'PainterCtrl', ($scope) ->
    $scope.chanceRespawn = 'hello'

angular.module('PainterApp').directive 'canvasPainter', ->
    (scope, element, attrs) ->
        startPainter element[0], (myPainter) ->
            scope.$watch(
                (changes)-> console.log('hello', changes) 
                console.log myPainter
            )
