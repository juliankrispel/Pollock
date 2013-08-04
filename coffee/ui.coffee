angular.module 'PainterApp', []

angular.module('PainterApp').controller 'PainterCtrl', ($scope) ->
    $scope.painter = {}

angular.module('PainterApp').directive 'canvasPainter', ->
    (scope, element, attrs) ->
        startPainter element[0], (myPainter) ->
            scope.painter = {}
            scope.painter = myPainter.state
            scope.$apply()
            scope.$watch (changes)-> 
                _(myPainter.state).extend changes.painter
